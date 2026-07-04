--Mirror Penguin Duke
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--Copy level 4 or lower Penguin's flip effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.drcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--Add 1 "Penguin" to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function (_,tp) return Duel.IsTurnPlayer(1-tp) end)
	e3:SetTarget(s.addtarget)
	e3:SetOperation(s.addoperation)
	c:RegisterEffect(e3)
end
s.listed_series={SET_PENGUIN}

--Copy Penguin's flip effect
function s.flipfilter(c,e,tp)
    if not (c:IsSetCard(SET_PENGUIN)
        and c:IsMonster()
        and c:IsLevelBelow(4)
        and c:IsAbleToRemoveAsCost()) then
        return false
    end
    for _,eff in ipairs({c:GetOwnEffects()}) do
        local typ=eff:GetType()
        if (typ & EFFECT_TYPE_FLIP)~=0 or eff:GetCode()==EVENT_FLIP then
            return true
        end
    end
    return false
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.flipfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local rc=Duel.SelectMatchingCard(tp,s.flipfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    Duel.Remove(rc,POS_FACEUP,REASON_COST)
    local copied=nil
    for _,eff in ipairs({rc:GetOwnEffects()}) do
        local typ=eff:GetType()
        if (typ & EFFECT_TYPE_FLIP)~=0 or eff:GetCode()==EVENT_FLIP then
            copied=eff
            break
        end
    end
    e:SetLabelObject(copied)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then
        return true
    end
    local eff=e:GetLabelObject()
    if not eff then return end
    e:SetLabel(eff:GetLabel())
    e:SetLabelObject(eff:GetLabelObject())
    e:SetProperty(
        eff:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
        and EFFECT_FLAG_CARD_TARGET
        or 0
    )
    local tg=eff:GetTarget()
    if tg then
        tg(e,tp,eg,ep,ev,re,r,rp,1,chkc)
    end
    eff:SetLabel(e:GetLabel())
    eff:SetLabelObject(e:GetLabelObject())
    e:SetLabelObject(eff)
    Duel.ClearOperationInfo(0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local eff=e:GetLabelObject()
    if not eff then return end
    e:SetLabel(eff:GetLabel())
    e:SetLabelObject(eff:GetLabelObject())
    local op=eff:GetOperation()
    if op then
        op(e,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE)
    end
    e:SetLabel(0)
    e:SetLabelObject(nil)
end
--Draw
function s.drcostfilter(c)
    return c:IsRace(RACE_AQUA) and c:IsAbleToRemoveAsCost()
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.drcostfilter,tp,LOCATION_GRAVE,0,2,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.drcostfilter),tp,LOCATION_GRAVE,0,2,2,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Draw(tp,1,REASON_EFFECT)
end
-- Add 1 "Penguin" monster to hand
function s.addfilter(c)
	return c:IsSetCard(SET_PENGUIN) and c:IsMonster() and c:IsAbleToHand()
end
function s.addtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.addoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end