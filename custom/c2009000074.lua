-- Imprisoned Archfiend Tatetsu
-- Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x2045),tp,LOCATION_MZONE,0,1,nil) end)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)
	--Ritual Summon 1 LIGHT Fiend Ritual Monster from your hand or banishment
	local e2=Ritual.CreateProc(c,RITPROC_GREATER,
		function(rit_c) return rit_c:IsAttribute(ATTRIBUTE_LIGHT) and rit_c:IsRace(RACE_FIEND) end,
		nil,aux.Stringid(id,1),s.extrafil,nil,nil,nil,LOCATION_HAND|LOCATION_REMOVED)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	c:RegisterEffect(e2)
    --If this card is used for the Synchro Summon of a LIGHT/DARK monster, it can be treated as a Level 6 monster
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetCode(EFFECT_SYNCHRO_LEVEL)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.synlv)
    c:RegisterEffect(e3)
end

function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
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