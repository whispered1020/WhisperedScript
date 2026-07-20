--Bloomfang Rose
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon itself if Rose/Rose Dragon is Special Summoned
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --Send Rose to GY, increase Level, then summon Token
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_LVCHANGE+CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.lvcost)
    e2:SetTarget(s.lvtg)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)
end
s.listed_series={SET_ROSE}
s.listed_names={TOKEN_ROSE}

--Special Summon itself
function s.cfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(SET_ROSE) and not c:IsSetCard(SET_ROSE_DRAGON) and c:IsControler(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end
--
function s.tgfilter(c)
    return c:IsSetCard(SET_ROSE) and c:IsAbleToGrave() and c:IsMonster()
end
function s.lvfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_ROSE) and not c:IsSetCard(SET_ROSE_DRAGON) and c:HasLevel()
end
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ROSE,0,TYPES_TOKEN,800,800,2,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,tp) end
    Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,nil,1,tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ROSE,0,TYPES_TOKEN,800,800,2,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,tp) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local tc=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    if tc then
        local lv=Duel.AnnounceNumber(tp,1,2)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_LEVEL)
        e1:SetValue(lv)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local token=Duel.CreateToken(tp,TOKEN_ROSE)
        Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
    end
end
