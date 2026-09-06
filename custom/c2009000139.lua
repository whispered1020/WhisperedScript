--The Aftershock of The Eonwheel
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
	--Return a Special Summoned monster to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(s.rthtg)
	e1:SetOperation(s.rthop)
	c:RegisterEffect(e1)
	--Activate this card from the hand if it was Set and returned
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2a:SetCode(EVENT_TO_HAND)
	e2a:SetOperation(s.flagop)
	c:RegisterEffect(e2a)
	local e2b=Effect.CreateEffect(c)
	e2b:SetDescription(aux.Stringid(id,1))
	e2b:SetType(EFFECT_TYPE_SINGLE)
	e2b:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e2b:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e2b:SetCondition(s.handcon)
	c:RegisterEffect(e2b)
end

function s.cfilter2(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.cfilter2(chkc,e,tp) and eg:IsContains(chkc) end
	if chk==0 then return eg and eg:IsExists(s.cfilter2,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tg=eg:FilterSelect(tp,s.cfilter2,1,1,nil,e,tp)
    Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,1,0,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsOnField() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
--
function s.flagop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_SZONE)
		and c:IsPreviousPosition(POS_FACEDOWN) then
		c:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.handcon(e)
	return e:GetHandler():GetFlagEffect(id)>0
end