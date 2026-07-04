--Sylvan Mikoblessin
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

function s.sylvanfilter(c)
    return c:IsSetCard(0x90)
end
function s.sylvansfilter(c)
    return c:IsSetCard(0x90) and c:IsMonster()
end
function s.xyzfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x90)
end

-- target: 1 "Sylvan" in GY; choose top or bottom placement
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sylvanfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.sylvanfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.sylvanfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end

-- helper to get top n cards group (handles short deck)
function s.get_top_group(tp,n)
    local deckcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
    if deckcount==0 then return Group.CreateGroup() end
    local num=math.min(n,deckcount)
    return Duel.GetDecktopGroup(tp,num)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    --choose top or bottom
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSITION)
    local opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    if opt==0 then
        Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
    else
        Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
    end
    -- Decide whether player controls a Sylvan Xyz Monster
    local hasXyz=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)

    if not hasXyz then
        -- Default: excavate top 1; if it's a Plant monster, add it to hand.
        Duel.ConfirmDecktop(tp,1)
        --local gtop=s.get_top_group(tp,1)
        local gtop=Duel.GetDecktopGroup(tp,1)
        if gtop:GetCount()==0 then return end
        Duel.ConfirmCards(1-tp,gtop)
        local tc2=gtop:GetFirst()
        if tc2:IsType(TYPE_MONSTER) and tc2:IsRace(RACE_PLANT) then
            Duel.DisableShuffleCheck()
            Duel.SendtoHand(tc2,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc2)
        end
    else
        -- If control Sylvan Xyz: excavate top 2, send Plant monsters among them to the GY, place rest on bottom in any order
        --local gtop=s.get_top_group(tp,2)
        Duel.ConfirmDecktop(tp,2)
        local gtop=Duel.GetDecktopGroup(tp,2)
        if gtop:GetCount()==0 then return end
        --Duel.ConfirmCards(1-tp,gtop)
        local plantGroup=Group.CreateGroup()
        local nonPlantGroup=Group.CreateGroup()
        local c=gtop:GetFirst()
        while c do
            if c:IsType(TYPE_MONSTER) and c:IsRace(RACE_PLANT) then
                plantGroup:AddCard(c)
            else
                nonPlantGroup:AddCard(c)
            end
            c=gtop:GetNext()
        end
        if plantGroup:GetCount()>0 then
            Duel.DisableShuffleCheck()
            Duel.SendtoGrave(plantGroup,REASON_EFFECT+REASON_REVEAL)
        end
        -- Place non-plant cards on bottom in any order.
        if nonPlantGroup:GetCount()>0 then
            -- If more than 1, let player choose order; otherwise directly send to bottom
            if nonPlantGroup:GetCount()>1 then
                local sg=nonPlantGroup:Select(tp,1,nonPlantGroup:GetCount(),nil)
                -- Send selected group to bottom; sending as group will preserve order is engine dependent;
                Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
            else
                Duel.SendtoDeck(nonPlantGroup,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
            end
        end
    end
end
--Return to hand and to bottom Deck
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.IsExistingTarget(s.sylvanfilter,tp,LOCATION_GRAVE,0,5,nil)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sylvanfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.sylvansfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.sylvansfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc then return end
    if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT) then
        Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_COST)
    end
end