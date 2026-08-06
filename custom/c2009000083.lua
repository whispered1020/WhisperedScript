--Saxifrage the Rikka Counselor
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:AddMustBeSpecialSummoned()
    --special summon itself
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --Opponent tributes own monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.tbcon)
	e2:SetTarget(s.tbtg)
	e2:SetOperation(s.tbop)
	c:RegisterEffect(e2)
	--disable Spell/Trap
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end

--Special Summon procedure
function s.rfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsReleasable()
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetMZoneCount(tp,sg)>0 and sg:IsExists(Card.IsSetCard,1,nil,SET_RIKKA)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_FZONE,0,1,nil,76869711) then
		local g1=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_MZONE,0,nil)
		local g2=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
		local tg=g1+g2
		e:SetLabel(0)
		return #tg>=2 and aux.SelectUnselectGroup(tg,e,tp,2,2,s.rescon,0)
	else
		local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_MZONE,0,nil)
		e:SetLabel(1)
		return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local tg=e:GetLabel()
	if tg==0 then
		local g1=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_MZONE,0,nil)
		local g2=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
		local rc=g1+g2
		local sg=aux.SelectUnselectGroup(rc,e,tp,2,2,s.rescon,1,tp,HINTMSG_RELEASE,nil,nil,true)
		if sg and #sg>0 then
			e:SetLabelObject(sg)
			return true
		end
	else
		local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_MZONE,0,nil)
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_RELEASE,nil,nil,true)
		if sg and #sg>0 then
			e:SetLabelObject(sg)
			return true
		end
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if sg and #sg==2 then
		Duel.Release(sg,REASON_COST)
	end
end
--
function s.tbcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.NOT(Card.IsSummonPlayer),1,nil,tp) and Duel.IsMainPhase()
end
function s.tbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and Duel.IsExistingMatchingCard(Card.IsReleasable,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,LOCATION_MZONE)
end
function s.tbop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and aux.RemoveUntil(c,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp) then
		local g=Duel.GetMatchingGroup(Card.IsReleasable,1-tp,LOCATION_MZONE,0,nil)
		if #g>0 then
		    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_RELEASE)
		    local sg=g:Select(1-tp,1,1,nil)
		    Duel.HintSelection(sg)
		    Duel.Release(sg,REASON_RULE,1-tp)
	    end
	end
end
--
function s.negconfilter(c,tp)
	return c:GetPreviousRaceOnField()&RACE_PLANT==RACE_PLANT and c:IsPreviousControler(tp)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.negconfilter,1,nil,tp)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_SZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dg=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_SZONE,nil)
	if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local dc=dg:Select(tp,1,1,nil):GetFirst()
		if not dc then return end
		Duel.HintSelection(dc,true)
		Duel.BreakEffect()
		Duel.NegateRelatedChain(dc,RESET_TURN_SET)
		--Negate its effects
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		dc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		dc:RegisterEffect(e2)
	end
end
