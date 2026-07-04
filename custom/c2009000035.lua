--Abyssal Dread Neoneel
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
	--Negate an opponent's effect activated in response to the activation of your WATER card or effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--Protection when used as material for a water monster
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_BE_MATERIAL)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.matcon)
    e1:SetTarget(s.mattg)
    e1:SetOperation(s.matop)
    c:RegisterEffect(e1)
end
s.listed_series={0xf18}

function s.filter(c,e,tp)
	return c:IsSetCard(0xf18)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local ch=Chain.GetCurrentLink()-1
	return ch>0 and ep==1-tp and re:IsMonsterEffect() and not Duel.HasFlagEffect(tp,id)
		and Duel.IsChainDisablable(ev) and Chain.IsTriggeringControler(ch,tp)
		and Chain.IsTriggeringType(ch,TYPE_MONSTER) and Chain.IsTriggeringAttribute(ch,ATTRIBUTE_WATER)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,2)) then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	Duel.Hint(HINT_CARD,0,id)
	if Duel.NegateEffect(ev) then
		Duel.BreakEffect()
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
		--Cannot Special Summon, except Aqua, Sea Serpent or Fish monsters
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
--special summon only Aqua, Sea Serpent or Fish monsters
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_AQUA|RACE_SEASERPENT|RACE_FISH)
end
--
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=c:GetReasonCard()
    return c:IsLocation(LOCATION_GRAVE)
        and rc and rc:IsAttribute(ATTRIBUTE_WATER)
        and (r & REASON_FUSION)==REASON_FUSION
            or (r & REASON_SYNCHRO)==REASON_SYNCHRO
            or (r & REASON_LINK)==REASON_LINK
end
function s.banishfilter(c)
    return c:IsRace(RACE_AQUA+RACE_SEASERPENT+RACE_FISH) and c:IsAbleToRemove()
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
    local rc=e:GetHandler():GetReasonCard()
    if chk==0 then return rc and Duel.IsExistingMatchingCard(s.banishfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=c:GetReasonCard()
    if not rc or not rc:IsFaceup() then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.banishfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
        --Gain 500 ATK
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(500)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        rc:RegisterEffect(e1)
        --Cannot be targeted
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e2:SetRange(LOCATION_MZONE)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e2:SetValue(aux.tgval)
        rc:RegisterEffect(e2)
    end
end