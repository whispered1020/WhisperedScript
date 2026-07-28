--Abyssal Dread Neoneel
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
	--Battle and effect destruction protection
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.protcon)
    e1:SetCost(s.protcost)
	e1:SetOperation(s.protop)
	c:RegisterEffect(e1)
	--Target Protection when used as material for a water monster
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.matcon)
    e2:SetTarget(s.mattg)
    e2:SetOperation(s.matop)
    c:RegisterEffect(e2)
end
s.listed_series={0xf18}

function s.filter(c,e,tp)
	return c:IsSetCard(0xf18)
end
function s.protcon(e,tp,eg,ep,ev,re,r,rp)
	local ch=Chain.GetCurrentLink()-1
	return ch>0 and ep==1-tp and re:IsMonsterEffect() and not Duel.HasFlagEffect(tp,id)
		and Chain.IsTriggeringControler(ch,tp) and Chain.IsTriggeringType(ch,TYPE_MONSTER)
        and Chain.IsTriggeringAttribute(ch,ATTRIBUTE_WATER)
end
function s.protcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsDiscardable()
	end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.protop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local tc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT):GetHandler()
	if not Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,2)) then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	Duel.Hint(HINT_CARD,0,id)
	if tc then
        --cannot be destroyed by battle
		local e0a=Effect.CreateEffect(c)
		e0a:SetType(EFFECT_TYPE_SINGLE)
		e0a:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e0a:SetValue(1)
		e0a:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e0a)
		--cannot be destroyed by card effects
		local e0b=Effect.CreateEffect(c)
		e0b:SetType(EFFECT_TYPE_SINGLE)
		e0b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e0b:SetValue(1)
		e0b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e0b)
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