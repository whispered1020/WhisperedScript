--Blooming Rose Accord
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_names={CARD_GARDEN_ROSE_FLORA}
s.listed_series={SET_ROSE}

--
function s.synfilter(c,e,tp)
    return c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_TUNER) and c:IsSetCard(SET_ROSE)
        and (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
            or c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsSetCard(SET_ROSE_DRAGON)
end
function s.rosefilter(c,e,tp)
    return c:IsSetCard(SET_ROSE) and (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsSetCard(SET_ROSE_DRAGON)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
    local b2=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,76524506),tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.rosefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
    if chk==0 then return b1 or b2 end
    if b2 then
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
    else
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
    end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local b2=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,76524506),tp,LOCATION_MZONE,0,1,nil)
    if b2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.rosefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
        if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
            if #dg>0 then
                Duel.Destroy(dg,REASON_EFFECT)
            end
        end
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    end
    --Cannot Special Summon for the rest of this turn, except Plant or Dragon monsters
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,1))
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e0:SetTargetRange(1,0)
    e0:SetTarget(function(e,c) return c:IsRaceExcept(RACE_DRAGON|RACE_PLANT) end)
    e0:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e0,tp)
end
