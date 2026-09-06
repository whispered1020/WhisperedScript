--Into The Void of The Eonwheel
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
	--Reveal 1 face-down card you control; return it to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.rthtg)
	e1:SetOperation(s.rthop)
	c:RegisterEffect(e1)
	--Banish from GY; add 1 "Eonwheel" monster, then Set 1 "Eonwheel" Trap
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetHintTiming(TIMING_END_PHASE,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

function s.fdfilter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.fdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.fdfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.fdfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.ConfirmCards(1-tp,g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
--
function s.gyfilter(c)
	return c:IsSetCard(0xf22) and c:IsMonster() and c:IsAbleToHand()
end
function s.trapfilter(c)
	return c:IsSetCard(0xf22) and c:IsTrap() and c:IsSSetable()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and Duel.IsExistingMatchingCard(s.trapfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
	    if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
	        local tg=Duel.GetMatchingGroup(s.trapfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	        local sg=tg:Select(tp,1,1,nil):GetFirst()
	        if sg then
		        Duel.SSet(tp,sg)
		        Duel.ConfirmCards(1-tp,sg)
		    end
        end
    else return
    end
end