-- Imprisoned Archfiend Ketsui
-- Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon: 2+ Level 5 Fiend monsters
    c:EnableReviveLimit()
    Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),5,2,nil,nil,Xyz.InfiniteMats)
    --Banish 1 card on the field
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e1:SetCountLimit(1,id)
    e1:SetCost(Cost.DetachFromSelf(1,1,nil))
    e1:SetTarget(s.rmtg)
    e1:SetOperation(s.rmop)
    c:RegisterEffect(e1)
    --Add to hand OR Special Summon monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(Cost.DetachFromSelf(2,2,nil))
    e2:SetCondition(function() return Duel.IsMainPhase() end)
    e2:SetTarget(s.tstg)
    e2:SetOperation(s.tsop)
    c:RegisterEffect(e2)
end

--
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
    end
end
--
function s.bfilter(c)
    return c:IsSetCard(0x2045) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)
end
function s.thfilter(c)
    return c:IsSetCard(SET_ARCHFIEND) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x2045) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil)
        or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp))
        and Duel.IsExistingMatchingCard(s.bfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.tsop(e,tp,eg,ep,ev,re,r,rp)
    local thg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil)
    local spg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
    local bg=Duel.SelectTarget(tp,aux.NecroValleyFilter(s.bfilter),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
    local b1=#thg>0
    local b2=#spg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    if bg and Duel.Remove(bg,POS_FACEUP,REASON_EFFECT) then
        local op=Duel.SelectEffect(tp,
            {b1,aux.Stringid(id,2)},
            {b2,aux.Stringid(id,3)})
        if op==1 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g=thg:Select(tp,1,1,nil)
            if #g==0 then return end
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        elseif op==2 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=spg:Select(tp,1,1,nil)
            if #g==0 then return end
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end