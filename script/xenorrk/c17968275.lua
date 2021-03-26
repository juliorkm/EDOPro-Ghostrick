--Ghostrick Pumpkingdom
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atklimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(aux.TargetBoolFunction(Card.IsFacedown))
	c:RegisterEffect(e2)
	--direct attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.dirtg)
	c:RegisterEffect(e3)
	--double damage
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e4:SetCondition(s.dcon)
	e4:SetOperation(s.dop)
	c:RegisterEffect(e4)
	--activate trap in hand
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x8d))
	e5:SetTargetRange(LOCATION_HAND,0)
	c:RegisterEffect(e5)
	--destroy
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_POSITION)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCountLimit(1)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetTarget(s.fliptg)
	e6:SetOperation(s.flipop)
	c:RegisterEffect(e6)
end
s.listed_series={0x8d}
function s.dirtg(e,c)
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
function s.dcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	local dam=Duel.GetBattleDamage(ep)
	Duel.ChangeBattleDamage(ep,dam*2)
end
function s.fliptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,Duel.GetTurnPlayer(),LOCATION_MZONE,0,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,Duel.GetTurnPlayer(),LOCATION_MZONE,0,e:GetHandler())
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
