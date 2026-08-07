--Dasiphora the Wise Rikka Queen
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon Procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PLANT),10,2)
	--detach 1 or more materials and apply the appropriate effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--attach tributed monster to itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.attachcon)
	e2:SetTarget(s.attachtg)
	e2:SetOperation(s.attachop)
	c:RegisterEffect(e2)
	--Negate chain 1 effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.discon)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local b1=c:CheckRemoveOverlayCard(tp,1,REASON_COST)
        and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
    local b2=c:CheckRemoveOverlayCard(tp,2,REASON_COST)
        and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil)
    if chk==0 then return b1 or b2 end
    local op
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))+1
    elseif b1 and not b2 then
        op=1
	elseif not b1 and b2 then
		op=2
    end
    c:RemoveOverlayCard(tp,op,op,REASON_COST)
    e:SetLabel(op)
end
function s.thfilter(c)
    return c:IsSetCard(0x141) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
			return true 
	end
	local ct=e:GetLabel()
	if ct==1 then  
		--Add 1 "Rikka" monster from GY
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
	elseif ct==2 then 
		--return to hand 1 card your opponent controls
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,1-tp,LOCATION_ONFIELD)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if ct==1 then
		-- Add 1 "Rikka" monster from GY
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		end
	elseif ct==2 then
		--return to hand 1 card your opponent controls
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
-- If a Plant monster(s) you control is Tributed: Attach 1 of those monsters
function s.attfilter(c,tp)
	return c:GetPreviousRaceOnField()&RACE_PLANT==RACE_PLANT and c:IsPreviousControler(tp)
end
function s.attachfilter(c,tp)
	return c:GetPreviousRaceOnField()&RACE_PLANT==RACE_PLANT
		and c:IsPreviousControler(tp)
		and c:IsCanBeXyzMaterial()
end
function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.attfilter,1,nil,tp)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return eg:IsExists(s.attachfilter,1,nil,tp,e:GetHandler())
	end
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=eg:Filter(s.attachfilter,nil,tp,c)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if tc then
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
--negate chain 1
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain(true)>1 and Duel.IsChainDisablable(1)
end

function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST)
	end
	e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local eff=Duel.GetChainInfo(1,CHAININFO_TRIGGERING_EFFECT)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eff:GetHandler(),1,0,0)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(1)
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end