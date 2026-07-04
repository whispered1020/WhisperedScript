--Jungle Biome Sunseed Sproutling
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
    Pendulum.AddProcedure(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Discard then delayed SpSummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.spcost)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
    --if sent to gy by a plant monster's effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.sp2con)
	e3:SetTarget(s.sp2tg)
	e3:SetOperation(s.sp2op)
	c:RegisterEffect(e3)
end

function s.thfilter(c)
	return (c:IsMonster() and c:IsAbleToHand() and c:IsSetCard(SET_SUNVINE)) or (c:IsSetCard(0xf19) and c:IsLocation(LOCATION_GRAVE) and c:IsMonster() and c:IsAbleToHand() and not c:IsRitualMonster())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		--Cannot Special Summon for the rest of this turn, except Plant monsters
		local e0=Effect.CreateEffect(c)
		e0:SetDescription(aux.Stringid(id,3))
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e0:SetTargetRange(1,0)
		e0:SetTarget(function(_,c) return not c:IsRace(RACE_PLANT) end)
		e0:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e0,tp)
	end
end
--
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
	--Reveal until the end of opponent's turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetReset(RESETS_STANDARD_PHASE_END,2)
	c:RegisterEffect(e1)
end
--Delayed SSummon effect
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE_START+PHASE_MAIN1)
        e1:SetCountLimit(1)
        e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
        e1:SetOperation(function(e,tp)
            if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
            if #g>0 then
                Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
            end
        end)
        e1:SetReset(RESET_PHASE+PHASE_END,2)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.filter(c,e,tp)
	return c:IsSetCard(0xf19) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--
function s.sp2con(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsRace(RACE_PLANT) and re:IsMonsterEffect() and re:GetOwner()~=c
end
function s.sp2filter(c,e,tp,zone)
	return c:IsSetCard(SET_SUNSEED) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) and not c:IsNonEffectMonster()
end
function s.sp2tg(e,tp,eg,ep,ev,re,r,rp,chk)
    local zone=aux.GetMMZonesPointedTo(tp)
    if chk==0 then return zone>0 and Duel.IsExistingMatchingCard(s.sp2filter,tp,LOCATION_DECK,0,1,nil,e,tp,zone) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.sp2op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local zone=aux.GetMMZonesPointedTo(tp)
    if zone<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.sp2filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,zone)
    local tc=g:GetFirst()
    if tc then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone)
        --Cannot Special Summon monsters from the Extra Deck, except Link Monsters
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,5))
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetTargetRange(1,0)
        e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_LINK) end)
        e1:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end
