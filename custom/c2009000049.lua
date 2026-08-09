--Dracalyptus, the Sylvan High Sentinel
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon Procedure
	Xyz.AddProcedure(c,nil,7,2)
	--Excavate 3 cards from your Deck, send 1 excavated plant monster to the gy, then target 1 "sylvan" monster in the gy, add it to your hand 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(Cost.DetachFromSelf(1,1,nil))
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--Trigger when Plant monster(s) excavated
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end

function s.thfilter(c)
	return c:IsSetCard(0x90) and c:IsMonster() and c:IsAbleToHand()
end
function s.tgfilter(c,tp)
	return c:IsAbleToGrave() and c:IsRace(RACE_PLANT)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	local ct=math.min(3,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0))
	if ct==0 then return end
	Duel.ConfirmDecktop(tp,ct)
	local g=Duel.GetDecktopGroup(tp,ct)
	local sg=g:FilterSelect(tp,s.tgfilter,1,1,nil,tp):GetFirst()
	Duel.DisableShuffleCheck()
	if not sg then
		Duel.MoveToDeckBottom(g)
		Duel.SortDeckbottom(tp,tp,#g)
		return
	end
	if sg and Duel.SendtoGrave(sg,REASON_EFFECT+REASON_EXCAVATE)~=0 then
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
		if ct>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
			if #tg>0 then
				Duel.BreakEffect()
				Duel.DisableShuffleCheck(false)
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tg)
			end
		end
	end
	g=g-sg
	if #g>0 then
		Duel.MoveToDeckBottom(g)
		Duel.SortDeckbottom(tp,tp,#g)
	end
end
--target 1 face-up card your opponent controls, choose 1 or 2, excavate that many cards, then send 1 excavated plant monster to the gy, and if you do, destroy that target
function s.desfilter(c)
	return c:IsFaceup() and c:IsDestructable()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,e:GetHandler())
	end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,e:GetHandler())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=g:Select(tp,1,1,nil)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DECKDES,nil,1,tp,3)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	local ct=math.min(2,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0))
	if ct==0 then return end
	local t={}
	for i=1,ct do t[i]=i end
	Duel.Hint(HINTMSG_NUMBER,tp,HINT_NUMBER)
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	Duel.ConfirmDecktop(tp,ac)
	local g=Duel.GetDecktopGroup(tp,ac)
	local pg=g:Filter(s.tgfilter,nil,e,tp)
	local tc=Duel.GetFirstTarget()
	Duel.DisableShuffleCheck()
	if #pg>0 and Duel.SendtoGrave(pg,REASON_EFFECT+REASON_EXCAVATE)~=0 then
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			Duel.BreakEffect()
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
--if a plant monster is excavated and sent to the gy, target 1 plant monster in your gy, place it on the top of the deck
function s.exccfilter(c,tp)
    return c:IsRace(RACE_PLANT) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)
        and (c:GetReason()&REASON_EXCAVATE)~=0
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.exccfilter,1,nil,tp)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsRace(RACE_PLANT) end
    if chk==0 then return Duel.IsExistingTarget(Card.IsRace,tp,LOCATION_GRAVE,0,1,nil,RACE_PLANT) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,Card.IsRace,tp,LOCATION_GRAVE,0,1,1,nil,RACE_PLANT)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
