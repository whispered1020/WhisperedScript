--Lentic-waters Biome Predaplant Aldrocrab
local s,id=GetID()
function s.initial_effect(c)
	--Discard then Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Can be used as a non-Tuner for the Synchro Summon of a Plant monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_NONTUNER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(e,sc) return sc:IsRace(RACE_PLANT) end)
	c:RegisterEffect(e2)
	--if discarded SSummon from GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.sp2con)
	e3:SetTarget(s.sp2tg)
	e3:SetOperation(s.sp2op)
	c:RegisterEffect(e3)
end
s.listed_series={SET_PREDAPLANT}
s.counter_place_list={COUNTER_PREDATOR}
--Discard then Special Summon
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xf19) and c:IsMonster() and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
	--Reveal until the end of opponent's turn.
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_PUBLIC)
	e5:SetReset(RESETS_STANDARD_PHASE_END,2)
	c:RegisterEffect(e5)
end
function s.dsfilter(c,e,tp)
	return c:IsSetCard(SET_PREDAPLANT) and c:IsAbleToHand()
end
function s.ds2filter(c)
	return (c:IsSetCard(0xf19) or (c:IsSetCard(SET_PREDAPLANT) and c:IsMonster())) and c:IsAbleToGrave()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT)>0 then
		--Cannot Special Summon for the rest of this turn, except Plant or Dragon monsters
		local e0=Effect.CreateEffect(c)
		e0:SetDescription(aux.Stringid(id,3))
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e0:SetTargetRange(1,0)
		e0:SetTarget(function(e,c) return c:IsRaceExcept(RACE_DRAGON|RACE_PLANT) end)
		e0:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e0,tp)
		--Special Summon from Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,e:GetHandler(),e,tp)
		if #g>0 then
			g:AddCard(e:GetHandler())
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
--if discarded SSummon from GY
function s.sp2con(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	return re:GetHandler():IsRace(RACE_PLANT) and re:GetOwner()~=c and re:IsMonsterEffect()
end
function s.sp2filter(c,e,tp)
	return c:IsSetCard(SET_PREDAPLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.sp2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return
		Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,COUNTER_PREDATOR,1)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0,COUNTER_PREDATOR)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.sp2op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if tc:AddCounter(COUNTER_PREDATOR,1) and tc:GetLevel()>1 then
			local e6=Effect.CreateEffect(e:GetHandler())
			e6:SetType(EFFECT_TYPE_SINGLE)
			e6:SetCode(EFFECT_CHANGE_LEVEL)
			e6:SetReset(RESET_EVENT|RESETS_STANDARD)
			e6:SetCondition(s.lvcon)
			e6:SetValue(1)
			tc:RegisterEffect(e6)
		end
		Duel.BreakEffect()
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.sp2filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function s.lvcon(e)
	return e:GetHandler():GetCounter(COUNTER_PREDATOR)>0
end