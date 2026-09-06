--The Turning of The Eonwheel
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0xf22}

--Target 1 face-down card on the field; apply 1 of these effects depending on who controls it. You: Return it to the hand, then you can add 1 "Eonwheel" Spell/Trap from your Deck to your hand. Your opponent: It cannot be flipped face-up or activated this turn.
function s.filter(c,tp)
    return (c:IsFacedown() and c:IsControler(1-tp)) or (c:IsFacedown() and c:IsAbleToHand() and c:IsControler(tp))
end
function s.thfilter(c)
    return c:IsSetCard(0xf22) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and s.filter(chkc,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFacedown() then
        if tc:IsControler(tp) then
            Duel.ConfirmCards(1-tp,tc)
            if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
                if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
                    if #g>0 then
                        Duel.SendtoHand(g,nil,REASON_EFFECT)
                        Duel.ConfirmCards(1-tp,g)
                    end
                end
            end
        elseif tc:IsControler(1-tp) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_TRIGGER)
            e1:SetReset(RESETS_STANDARD_PHASE_END)
		    e1:SetValue(1)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
            e2:SetReset(RESETS_STANDARD_PHASE_END)
            tc:RegisterEffect(e2)
        end
    end
end