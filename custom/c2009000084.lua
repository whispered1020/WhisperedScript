--Gentian the Rikka Fairy Princess
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
	--draw 1 card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e1:SetCondition(s.drcon)
    e1:SetCost(s.drcost)
    e1:SetTarget(s.drtg)
    e1:SetOperation(s.drop)
    c:RegisterEffect(e1)
    --Set "Rikka" Trap from GY
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

function s.confilter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRace(RACE_PLANT)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) end
    Duel.SendtoGrave(c,REASON_COST)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
--
function s.setfilter(c)
    return c:IsSetCard(0x141) and c:IsTrap() and c:IsSSetable()
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,tp,LOCATION_GRAVE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
		if tc then
			Duel.SSet(tp,tc)
			Duel.ConfirmCards(1-tp,tc)
			-- Allow activation this turn
        	local e1=Effect.CreateEffect(c)
        	e1:SetType(EFFECT_TYPE_SINGLE)
        	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
        	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        	tc:RegisterEffect(e1)
		end
end