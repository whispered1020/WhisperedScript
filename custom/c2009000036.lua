--Penguin Apostle
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Penguin" monster from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Special Summon token
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3,false,CUSTOM_REGISTER_FLIP)
end
s.listed_series={SET_PENGUIN}
s.listed_names={2009000038,73640163}
--Add then
function s.thfilter(c)
	return c:IsSetCard(SET_PENGUIN) and c:IsAbleToHand() and c:IsMonster()
end
function s.th2filter(c)
	return c:IsCode(73640163) and c:IsAbleToHand()
end
function s.setfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x5a) and c:IsCanTurnSet()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp,chkc)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if g and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		--flip if a Tuner was added
		if g:IsType(TYPE_TUNER) and s.setfilter(c) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
			--local fg=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
			if c:IsFaceup() and c:IsRelateToEffect(e) then
				Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
			end
		end
		local break_chk=false
		--Add 1 "Penguin Cleric" if added a non-Tuner
			if not g:IsType(TYPE_TUNER) then
				local dg=Duel.SelectMatchingCard(tp,s.th2filter,tp,LOCATION_DECK,0,1,1,nil)
				break_chk=true
				Duel.BreakEffect()
				Duel.SendtoHand(dg,nil,REASON_EFFECT)
			end
end
end
--flip and Special Summon token
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,2009000038,0,TYPES_TOKEN,300,600,3,RACE_AQUA,ATTRIBUTE_WATER,POS_FACEUP_ATTACK,tp) then
		local token=Duel.CreateToken(tp,2009000038)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		Duel.SpecialSummonComplete()
	end
end