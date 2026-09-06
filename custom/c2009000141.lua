--Eonwheel, The New Age
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
	--Return all monsters to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rthcon)
	e1:SetTarget(s.rthtg)
	e1:SetOperation(s.rthop)
	c:RegisterEffect(e1)
	--Banish from GY; add "Eonwheel" Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end


--During the Main Phase, if you control an "Eonwheel" card, and have at least 1 "Eonwheel" card in your GY and banishment
function s.rthcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0xf22),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,nil,0xf22)
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_REMOVED,0,1,nil,0xf22)
end
function s.rthfilter(c)
	return c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.trapfilter2(c)
    return c:IsTrap() and c:IsAbleToHand()
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rthfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.rthfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rthfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
	if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		--You can return 1 of your banished "Eonwheel" cards to the GY, and if you do, banish 1 card from your opponent's GY.
		if Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_REMOVED,0,1,nil,0xf22) then
			
			if Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local rg=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_REMOVED,0,1,1,nil,0xf22)
				if #rg>0 and Duel.SendtoGrave(rg,REASON_EFFECT+REASON_RETURN)~=0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
					local og=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
					if #og>0 then
						Duel.Remove(og,POS_FACEUP,REASON_EFFECT)
					end
				end
			end
		end
		--Your opponent can Special Summon 1 monster from their hand in face-down Defense Position.
		if Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_HAND,1,nil,e,tp) then
			if Duel.SelectYesNo(1-tp,aux.Stringid(id,5)) then
				Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
				local sg=Duel.SelectMatchingCard(1-tp,s.spfilter,tp,0,LOCATION_HAND,1,1,nil,e,tp)
				if #sg>0 then
					if Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
						Duel.ConfirmCards(tp,sg)
					--Add 1 Trap Card from your GY or that is banished to your hand.
						if Duel.IsExistingMatchingCard(s.trapfilter2,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) then
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
							local tg=Duel.SelectMatchingCard(tp,s.trapfilter2,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
							if #tg>0 then
								Duel.SendtoHand(tg,nil,REASON_EFFECT)
							end
						end
					end
				end
			end
		end
	end
end
--
function s.gyfilter(c)
	return c:IsSetCard(0xf22) and c:IsSpell() and c:IsAbleToHand()
end
function s.trapfilter(c)
	return c:IsSetCard(0xf22) and c:IsTrap() and c:IsSSetable()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
	    if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
            local sg=Duel.SelectMatchingCard(tp,s.trapfilter,tp,LOCATION_DECK,0,1,1,nil)
            if sg then
				Duel.SSet(tp,sg)
				Duel.ConfirmCards(1-tp,sg)
		    end
	    end
	else return
    end
end