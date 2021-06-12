--Ghostrick Ectoplasm Fortification
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x2f,LOCATION_SZONE)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--add counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP)
	c:RegisterEffect(e4)
	--atkup
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x8d))
	e5:SetValue(s.atkval)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e6)
	--summon
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetCountLimit(1,id)
	e7:SetRange(LOCATION_SZONE)
	e7:SetTarget(s.spstg)
	e7:SetOperation(s.spsop)
	c:RegisterEffect(e7)
end
s.listed_series={0x8d}
s.counter_place_list={0x2f}
function s.ctfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsPreviousLocation(LOCATION_MZONE) and not c:IsType(TYPE_TOKEN) and c:IsSetCard(0x8d)
end
function s.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x2f)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local count=eg:FilterCount(s.ctfilter,nil)
	if count>0 then
		e:GetHandler():AddCounter(0x2f,count,true)
	end
end
function s.atkval(e,c)
	return e:GetHandler():GetCounter(0x2f)*200
	--return Duel.GetCounter(0,1,1,0x2f)*200
end
function s.spfilter(c,e,tp)
	local lv=0
	if c:IsType(TYPE_XYZ) then
		lv=c:GetRank()
	else
		lv=c:GetLevel()
	end
	return lv<3 and Duel.IsCanRemoveCounter(tp,1,0,0x2f,lv,REASON_COST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and c:IsSetCard(0x8d)
end
function s.spsfilter(c,e,tp)
	local lv=0
	if c:IsType(TYPE_XYZ) then
		lv=c:GetRank()
	else
		lv=c:GetLevel()
	end
	return c:IsSetCard(0x8d) and lv>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		and e:GetHandler():IsCanRemoveCounter(tp,0x2f,lv,REASON_COST)
end
function s.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spsfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) and
		Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	local g=Duel.GetMatchingGroup(s.spsfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	local lvt={}
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local tlv=0
		if tc:IsType(TYPE_XYZ) then
			tlv=tc:GetRank()
		else
			tlv=tc:GetLevel()
		end
		if tlv<=3 then lvt[tlv]=tlv end
	end
	local pc=1
	for i=1,3 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	e:GetHandler():RemoveCounter(tp,0x2f,lv,REASON_COST)
	e:SetLabel(lv)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.filter(c,e,tp,lv)
	local clv=0
	if c:IsType(TYPE_XYZ) then
		clv=c:GetRank()
	else
		clv=c:GetLevel()
	end
	return c:IsSetCard(0x8d) and clv==lv
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.spsop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		Duel.ConfirmCards(1-tp,g)
	end
end