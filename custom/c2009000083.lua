--Gentian the Rikka Counselor
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
    --special summon
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_RELEASE)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0,1)
    e3:SetTarget(s.rellimit)
    c:RegisterEffect(e3)
    --Return 1 plant monster from gy to bottom deck for each monster Tributed
	local e4a=Effect.CreateEffect(c)
	e4a:SetDescription(aux.Stringid(id,1))
	e4a:SetCategory(CATEGORY_TOHAND)
	e4a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4a:SetCode(EVENT_RELEASE)
    e4a:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4a:SetRange(LOCATION_MZONE)
    e4a:SetCountLimit(1,{id,1})
    e4a:SetCondition(s.thcon)
    e4a:SetTarget(s.thtg)
	e4a:SetOperation(s.thop)
	c:RegisterEffect(e4a)
end

function s.rfilter(c,tp)
    return c:IsRace(RACE_PLANT) and c:IsLevelAbove(6) and c:IsControler(tp)
end
function s.spfilter(c,tp)
    return c:IsSetCard(0x141) and c:IsRace(RACE_PLANT) and c:IsLevelAbove(6) and c:IsControler(tp)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=e:GetHandlerPlayer()
    local rg=Duel.GetReleaseGroup(tp)
    -- Must be able to select 2 Level 6+ Plants, at least 1 Rikka
    return rg:IsExists(s.spfilter,1,nil,tp) and rg:FilterCount(s.rfilter,nil,tp)>=2
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
    local rg=Duel.GetReleaseGroup(tp):Filter(s.rfilter,nil,tp)
    if #rg<2 or not rg:IsExists(s.spfilter,1,nil,tp) then return false end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=rg:Select(tp,2,2,nil)
    if not g:IsExists(s.spfilter,1,nil,tp) then return false end
    g:KeepAlive()
    e:SetLabelObject(g)
    return true
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if not g then return end
    Duel.Release(g,REASON_COST)
    g:DeleteGroup()
end
--
function s.rellimit(e,c)
    return not c:IsRace(RACE_PLANT)
end
--
function s.thconfilter(c)
	return c:IsMonster() or c:GetPreviousTypeOnField()&TYPE_MONSTER==TYPE_MONSTER
end
function s.thfilter(c)
    return c:IsAbleToHand() and c:IsMonster() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thconfilter,1,nil)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end