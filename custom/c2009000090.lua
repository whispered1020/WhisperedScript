--Harsh Desert Biome
--Scripted by: Whispered
local s,id=GetID()
function s.initial_effect(c)
  --disable spsummon and destroy
  local e1=Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_SPSUMMON)
  e1:SetCondition(s.condition)
  e1:SetTarget(s.target)
  e1:SetOperation(s.activate)
  c:RegisterEffect(e1)
end

function s.cfilter(c)
  return c:IsFaceup() and c:IsSetCard(0xf19)
end
function s.desfilter(c)
  return c:IsFaceup() and c:IsDestructable()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
  if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
  return tp~=ep and Duel.GetCurrentChain()==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
  Duel.NegateSummon(eg)
  Duel.Destroy(eg,REASON_EFFECT)
end
