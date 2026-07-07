--Pendulum Shards
--Scripted by Whispered
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

--
function s.filter(c)
	return c:IsSetCard(0xf2) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.plfilter(c)
	return c:IsSetCard(0xf2) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.filter2(c)
	return (c:IsSpellTrap() or c:IsType(TYPE_PENDULUM) or c:IsMonster()) and c:IsDestructable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_PZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
        -- check if there is a valid destructible Pendulum card first
        if Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_PZONE,0,1,nil) then
            if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
                local dg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_PZONE,0,1,1,nil)
                if #dg>0 and Duel.Destroy(dg,REASON_EFFECT)>0 and dg:GetFirst():IsSetCard(0xf2) then
                    Duel.BreakEffect()
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
                    local sg=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil)
                    if #sg>0 then
                        Duel.SendtoExtraP(sg:GetFirst(),tp,REASON_EFFECT)
                    end
                end
            end
        end
    end
end
