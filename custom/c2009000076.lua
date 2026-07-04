--Pendulum Resonance
--Scripted by Whispered
local s,id=GetID()
function s.initial_effect(c)
	--Place 1 "Pendulum" Pendulum Monster from your Deck or face-up Extra Deck face-up in your Pendulum Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetValue(s.zones)
	c:RegisterEffect(e1)
	--Place 1 "Magician" Pendulum Monster from your Deck or face-up Extra Deck face-up in your Pendulum Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.mcon)
	e2:SetTarget(s.mtg)
	e2:SetOperation(s.mop)
	e2:SetValue(s.zones)
	c:RegisterEffect(e2)
	--Place 1 "Odd-eyes" Pendulum Monster from your Deck or face-up Extra Deck face-up in your Pendulum Zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SET)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.ocon)
	e3:SetTarget(s.otg)
	e3:SetOperation(s.oop)
	e3:SetValue(s.zones)
	c:RegisterEffect(e3)
	--Place 1 "Performapal" Pendulum Monster from your Deck or face-up Extra Deck face-up in your Pendulum Zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_SET)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.pcon)
	e4:SetTarget(s.ptg)
	e4:SetOperation(s.pop)
	e4:SetValue(s.zones)
	c:RegisterEffect(e4)
	--Place 1 "Dracoslayer" Pendulum Monster from your Deck or face-up Extra Deck face-up in your Pendulum Zone
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,4))
	e5:SetCategory(CATEGORY_SET)
	e5:SetType(EFFECT_TYPE_ACTIVATE)
	e5:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e5:SetCondition(s.dscon)
	e5:SetTarget(s.dstg)
	e5:SetOperation(s.dsop)
	e5:SetValue(s.zones)
	c:RegisterEffect(e5)
	--Place 1 "Dracoverlord" Pendulum Monster from your Deck or face-up Extra Deck face-up in your Pendulum Zone
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,5))
	e6:SetCategory(CATEGORY_SET)
	e6:SetType(EFFECT_TYPE_ACTIVATE)
	e6:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e6:SetCondition(s.docon)
	e6:SetTarget(s.dotg)
	e6:SetOperation(s.doop)
	e6:SetValue(s.zones)
	c:RegisterEffect(e6)
end

--
function s.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff --all S/T zones
	local left_pend=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	local right_pend=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	if left_pend and right_pend then
		return zone
	elseif left_pend then
		--Remove the left-most Spell & Trap Zone
		zone=zone-0x1
	elseif right_pend then
		--Remove the right-most Spell & Trap Zone
		zone=zone-0x10
	end
	return zone
end
function s.plfilter(c)
	return c:IsSetCard(SET_PENDULUM) and c:IsType(TYPE_PENDULUM) and not (c:IsForbidden() and c:IsSetCard(id))
end
function s.mfilter(c)
    return c:IsSetCard(0x98) and not c:IsForbidden()
end
function s.ofilter(c)
	return c:IsSetCard(0x99) and not c:IsForbidden()
end
function s.pfilter(c)
	return c:IsSetCard(0x9f) and not c:IsForbidden()
end
function s.dsfilter(c)
	return c:IsSetCard(0xc7) and not c:IsForbidden()
end
function s.dofilter(c)
	return c:IsSetCard(0xda) and not c:IsForbidden()
end
function s.plmfilter(c)
    return c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.plofilter(c)
	return c:IsSetCard(0x99) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.plpfilter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pldsfilter(c)
	return c:IsSetCard(0xc7) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pldofilter(c)
	return c:IsSetCard(0xda) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.setfilter(c)
	return c:IsSetCard(0xf2) and c:IsSpell() and c:IsSSetable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 and Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true) and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
        	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
            local sg=g:Select(tp,1,1,nil)
		    Duel.BreakEffect()
		    Duel.SSet(tp,sg)
	end
end
-- Magician condition
function s.mcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.mtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and Duel.IsExistingMatchingCard(s.plmfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
end
function s.mop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.plmfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
			local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil):Select(tp,1,1,nil)
			Duel.BreakEffect()
			Duel.SSet(tp,sg)
		end
	end
end
--Odd-eyes condition
function s.ocon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.ofilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.otg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and Duel.IsExistingMatchingCard(s.plofilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
end
function s.oop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.plofilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
			local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil):Select(tp,1,1,nil)
			Duel.BreakEffect()
			Duel.SSet(tp,sg)
		end
	end
end
--Performapal condition
function s.pcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and Duel.IsExistingMatchingCard(s.plpfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
end
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.plpfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
			local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil):Select(tp,1,1,nil)
			Duel.BreakEffect()
			Duel.SSet(tp,sg)
		end
	end
end
--Dracoslayer condition
function s.dscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.dsfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.dstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and Duel.IsExistingMatchingCard(s.pldsfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
end
function s.dsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pldsfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
			local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil):Select(tp,1,1,nil)
			Duel.BreakEffect()
			Duel.SSet(tp,sg)
		end
	end
end
--Dracoverlord condition
function s.docon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.dofilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.dotg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and Duel.IsExistingMatchingCard(s.pldofilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
end
function s.doop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pldofilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
			local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil):Select(tp,1,1,nil)
			Duel.BreakEffect()
			Duel.SSet(tp,sg)
		end
	end
end