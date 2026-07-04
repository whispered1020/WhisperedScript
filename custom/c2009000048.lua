--Coryphora, the Sylvan High Watcher
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PLANT),5,2,s.matfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
	--Excavate on Xyz Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.excacon)
	e1:SetTarget(s.excatg)
	e1:SetOperation(s.excaop)
	c:RegisterEffect(e1)
	--Detach to set Sylvan Trap from Deck or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.DetachFromSelf(1,1,nil))
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	--Quick Effect: excavate, if Plant, manipulate opponent hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_BATTLE_PHASE+TIMING_END_PHASE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.qecond)
	e3:SetTarget(s.qetg)
	e3:SetOperation(s.qeop)
	c:RegisterEffect(e3)
end
--Alternative Xyz Summon using a Sylvan Xyz Monster
function s.matfilter(c,tp,lc)
	return c:IsFaceup() and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp) and c:IsSetCard(0x90,lc,SUMMON_TYPE_XYZ,tp)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
	return true
end
--Excavate on Xyz Summon
function s.setsfilter(c)
	return c:IsCode(70222318) and c:IsSSetable()
end
function s.excacon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.excatg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.IsExistingMatchingCard(s.setsfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
end
function s.excaop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=math.min(c:GetOverlayCount(),Duel.GetFieldGroupCount(tp,LOCATION_DECK,0))
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	if ct==0 then return end
	local ac=1
	Duel.ConfirmDecktop(tp,ct)
	local td=Duel.GetDecktopGroup(tp,ct)
	local tg=td:Filter(Card.IsRace,nil,RACE_PLANT)
	if Duel.SendtoGrave(tg,REASON_EFFECT+REASON_EXCAVATE)~=0 then
		Duel.DisableShuffleCheck()
		local gc=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
		if gc>0 then
		local g=Duel.SelectMatchingCard(tp,s.setsfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
			if #g>0 then
			Duel.BreakEffect()
			Duel.SSet(tp,g)
			end
		end
	ct=ct-#tg
	if ct>0 then
		Duel.MoveToDeckBottom(td)
		Duel.SortDeckbottom(tp,tp,ct)
	end
	end
end
--Detach to set Sylvan Trap from Deck or GY
function s.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(SET_SYLVAN) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
			and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SSet(tp,g)
		end
end
--Quick Effect Condition (opponent’s turn)
function s.qecond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.qetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetDecktopGroup(tp,1)
	if #g==0 then return end
	Duel.ConfirmCards(1-tp,g)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		--look at 1 random card in opponent’s hand
		local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #hg>0 then
			local sg=hg:RandomSelect(tp,1)
			Duel.ConfirmCards(tp,sg)
			local hc=sg:GetFirst()
			--choose top or bottom
			local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3)) -- top or bottom
			if opt==0 then
				Duel.SendtoDeck(hc,nil,SEQ_DECKTOP,REASON_EFFECT)
			else
				Duel.SendtoDeck(hc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		end
	else
		--Place the excavated card on the bottom of your Deck
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end