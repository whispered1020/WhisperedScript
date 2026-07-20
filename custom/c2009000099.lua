--Edge Imp Scissors
--Made by: Creepie
--Scripted by: Whispered
--Modified by: Whispered
local s,id=GetID()
function s.initial_effect(c)
	--(Quick Effect): You can Fusion Summon 1 "Frightfur" Fusion Monster from your Extra Deck, by shuffling its materials from your hand and/or GY into the Deck
	local fusion_params={
		fusfilter=function(c)
			return c:IsSetCard(SET_FRIGHTFUR)
		end,
		extratg=function(e,tp,eg,ep,ev,re,r,rp,chk)
			if chk==0 then return true end
			Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
		end,
		extraop=Fusion.ShuffleMaterial,
		extrafil=s.extramaterial,gc=c
	}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.fuscost)
	e1:SetTarget(Fusion.SummonEffTG(fusion_params))
	e1:SetOperation(Fusion.SummonEffOP(fusion_params))
	c:RegisterEffect(e1)
	--add
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_FRIGHTFUR,SET_EDGE_IMP}

function s.extramaterial(e,tp,mg)
    local g=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE,0,nil)
    g:AddCard(e:GetHandler())
    return g
end
function s.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
end
--add
function s.thfilter(c)
	return c:IsSetCard({SET_FRIGHTFUR,SET_EDGE_IMP}) and c:IsMonster() and not c:IsCode(2009000099)
	and c:IsAbleToHand() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_EXTRA) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end