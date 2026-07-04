-- Imprisoned Archfiend Himiken
-- Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--atkdown and blanket negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsRitualSummoned() end)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
    --If this card is used for the Synchro Summon of a LIGHT/DARK monster, it can be treated as a Level 6 monster
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetCode(EFFECT_SYNCHRO_LEVEL)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.synlv)
    c:RegisterEffect(e2)
	--Banish this card (from hand or GY); Special Summon or add
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

function s.filter(c)
	return c:IsFaceup()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
    local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
    for tc in aux.Next(g) do
        -- disable
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        -- disable effects
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)
        -- atk reduction
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_UPDATE_ATTACK)
        e3:SetValue(-500)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e3)
    end
end
--synchro material level change
function s.synlv(e,c)
    local lv=e:GetHandler():GetLevel()
    if (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)) then
        return 6,lv
    else
        return lv
    end
end
--
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x2045) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
		and not c:IsType(TYPE_RITUAL)
end
function s.thfilter(c,e,tp)
	return c:IsSetCard(0x45) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and c:IsLevelBelow(4)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return (Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)) or (Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp))  end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND+HINTMSG_SPSUMMON)
    local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4)) -- 3 = "Add to hand", 4 = "Special Summon"
    if op==0 then
    	    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    	    local tc=g:GetFirst()
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
            --You cannot Special Summon DARK Monsters for the rest of this turn, except "Archfiend" monsters
            local e0=Effect.CreateEffect(e:GetHandler())
            e0:SetDescription(aux.Stringid(id,5))
            e0:SetType(EFFECT_TYPE_FIELD)
            e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
            e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e0:SetTargetRange(1,0)
            e0:SetTarget(function(e,c) return c:IsAttribute(ATTRIBUTE_DARK)
                and not c:IsSetCard(SET_ARCHFIEND) and not c:ListsArchetype(SET_ARCHFIEND) and not c:ListsCode(CARD_RED_DRAGON_ARCHFIEND) end)
            e0:SetReset(RESET_PHASE|PHASE_END)
            Duel.RegisterEffect(e0,tp)
    	else
    		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    		local tc=g:GetFirst()
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)
            --You cannot Special Summon DARK Monsters for the rest of this turn, except "Archfiend" monsters
            local e0=Effect.CreateEffect(e:GetHandler())
            e0:SetDescription(aux.Stringid(id,5))
            e0:SetType(EFFECT_TYPE_FIELD)
            e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
            e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e0:SetTargetRange(1,0)
            e0:SetTarget(function(e,c) return c:IsAttribute(ATTRIBUTE_DARK)
                and not c:IsSetCard(SET_ARCHFIEND) and not c:ListsArchetype(SET_ARCHFIEND) and not c:ListsCode(CARD_RED_DRAGON_ARCHFIEND) end)
            e0:SetReset(RESET_PHASE|PHASE_END)
            Duel.RegisterEffect(e0,tp)
    end
end