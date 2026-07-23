--Elegant Rose
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
    --banish opponent's GY card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.gytg)
    e1:SetOperation(s.gyop)
    c:RegisterEffect(e1)
    --token
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_REMOVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.tktg)
    e2:SetOperation(s.tkop)
    c:RegisterEffect(e2)
end
s.listed_series={SET_ROSE}

--
function s.gyfilter(c)
    return c:IsAbleToRemove()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and s.gyfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,0,LOCATION_GRAVE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,s.gyfilter,tp,0,LOCATION_GRAVE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
            if Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_ONFIELD,0,1,nil,SET_ROSE) then
                Duel.Damage(1-tp,300,REASON_EFFECT)
            end
        end
    end
end
--token
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local oft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
    if chk==0 then return ft>0 or oft>0 end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=1
    if Duel.IsExistingMatchingCard(function(c) return c:IsSetCard(SET_ROSE) and c:IsType(TYPE_SYNCHRO) and c:IsLevel(5) end,tp,LOCATION_MZONE,0,1,nil) then
        ct=2
    end
    for i=1,ct do
        --Choose side of field
        local side=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
        local targetp=tp
        if side==1 then targetp=1-tp end
        if Duel.GetLocationCount(targetp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ROSE,0,TYPES_TOKEN,800,800,2,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,targetp) then
            local token=Duel.CreateToken(tp,TOKEN_ROSE)
            Duel.SpecialSummonStep(token,0,tp,targetp,false,false,POS_FACEUP_ATTACK)
        end
    end
    Duel.SpecialSummonComplete()
end
