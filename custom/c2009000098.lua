--Heavymetalfoes Hihiirokane
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
    --Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,2,2,s.lcheck)
    --Place 1 Metalfoes Pendulum in Extra Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.plcon)
    e1:SetTarget(s.pltg)
    e1:SetOperation(s.plop)
    c:RegisterEffect(e1)
    -- Fusion Effect
    local params = {fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_METALFOES),matfilter=aux.FALSE,extrafil=s.extramaterial}
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.fuscost)
    e2:SetTarget(Fusion.SummonEffTG(params))
    e2:SetOperation(Fusion.SummonEffOP(params))
    c:RegisterEffect(e2)
end

--
function s.matfilter(c,lc,sumtype,tp)
    return c:IsRace(RACE_PSYCHIC,lc,sumtype,tp)
end
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsSetCard,1,nil,SET_METALFOES,lc,sumtype,tp)
end
--Place Pendulum
function s.plcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.plfilter(c)
    return c:IsSetCard(SET_METALFOES) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    local g=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoExtraP(g,tp,REASON_EFFECT)
    end
end
--Fusion Summon
function s.costfilter(c)
    return c:IsSetCard(SET_METALFOES) and c:IsDestructable()
end
function s.fusfilter(c)
    return c:IsMonster() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
function s.extramaterial(e,tp,mg)
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAbleToGrave),tp,LOCATION_EXTRA,0,nil)
    local g2=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_HAND,0,nil)
    g:AddCard(g2)
    return g
end
function s.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,2,nil)
        and Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA|LOCATION_HAND,0,2,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,2,2,nil)
    Duel.Destroy(g,REASON_COST)
end
