-- Sylvan Tropical Forest Biome Descendant
local s,id=GetID()
function s.initial_effect(c)
	--Add to hand or Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.exccost)
	e1:SetTarget(s.exctg)
	e1:SetOperation(s.excop)
	c:RegisterEffect(e1)
	--If discarded add 1 "Biome" or "Sylvan" Spell/Trap from your deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0xf19,0x90}
--Excavate
function s.exccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
	--Reveal until the end of opponent's turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetReset(RESETS_STANDARD_PHASE_END,2)
	c:RegisterEffect(e1)
end
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 and Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c,tp)
	return c:IsMonster() and not c:IsRitualMonster() and (c:IsSetCard(0x90) or c:IsSetCard(0xf19)) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false)) and not c:IsLocation(LOCATION_GRAVE)
end
function s.tgfilter(c,tp)
	return c:IsAbleToGrave()
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
    Duel.ConfirmDecktop(tp,3)
    local dg=Duel.GetDecktopGroup(tp,3)
    --Send 1 excavated card to the GY
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tc=dg:FilterSelect(tp,Card.IsAbleToGrave,1,1,nil,tp):GetFirst()
    if tc then
        Duel.DisableShuffleCheck()
        Duel.SendtoGrave(tc,REASON_EFFECT|REASON_EXCAVATE)
        dg:Sub(tc)
    end
    local break_chk=false
    --Add to hand or Special Summon 1 excavated monster
    local thg=dg:Filter(s.thfilter,nil,tp)
    if #thg>0 then
        local thc=thg:Select(tp,1,1,nil):GetFirst()
        break_chk=true
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        aux.ToHandOrElse(thc,tp,function(c)
                return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end,
                function(c)
                Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end,
                aux.Stringid(id,2))
        dg:Sub(thc)
    end
    if break_chk then Duel.BreakEffect() end
    --Return the remaining card to the top of the Deck
    Duel.MoveToDeckTop(dg)
end
--Add 1 "Biome" or "Sylvan" Spell/Trap from your deck to your hand
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (e:GetHandler():IsPreviousLocation(LOCATION_DECK) and e:GetHandler():IsReason(REASON_EXCAVATE))
	or (re and re:GetHandler():IsRace(RACE_PLANT) and re:GetOwner()~=c and re:IsMonsterEffect())
end
function s.th2filter(c)
	return (c:IsSetCard(0xf19) and c:IsSpell() and c:IsAbleToHand() and not c:IsType(TYPE_CONTINUOUS|TYPE_FIELD)) or (c:IsSetCard(0x90) and c:IsSpellTrap() and c:IsAbleToHand())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.th2filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.th2filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end