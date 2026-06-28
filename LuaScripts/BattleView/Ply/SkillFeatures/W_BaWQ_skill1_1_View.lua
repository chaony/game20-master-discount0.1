---@class W_BaWQ_skill1_1_View : SkillFeatures_View
---@field super SkillFeatures_View
---@field resEffectList W_BaWQ_skill1_1_View_EffectData[]
---@field model W_BaWQ_skill1_1_Model
local M = class("W_BaWQ_skill1_1_View", SkillFeatures_View)

M.resEffectName = "W_BaWQ_Skill1_Buff_001"

M.resEffectTransform = {
    {position = Vector3.New(-1.3, 0.35,-0.6), rotation = Vector3.New(0,180,-90)},
    {position = Vector3.New(-1.15, 0.25,-1.05), rotation = Vector3.New(25,-152,-78)},    
    {position = Vector3.New(-1.3, 0.25,-0.2), rotation = Vector3.New(-25,152,-78)},
    {position = Vector3.New(-1.15, 0.1,-1.38), rotation = Vector3.New(20,-120,-50)},
    {position = Vector3.New(-1.3, 0.05,0.2), rotation = Vector3.New(-20,121,-50)},
}

---@class W_BaWQ_skill1_1_View_EffectData
---@field isLoad boolean
---@field isVisible boolean
---@field obj CS.UnityEngine.GameObject

function M:init(player, skill, model)
    M.super.init(self, player, skill, model)
    self:addEventListener_Local(Battle.SkillEventType.MV_W_BaWQ_skill1_1_Model_Res_Changed, { self, self.onResLvChanged})
    self.isLoadedEffect = false
    self.resEffectList = {}
    self.forwardX = 0
    self.lastForward = nil
end

-- 加载完成
function M:loadFinish()
    M.super.loadFinish(self)
    self:tryLoadResEffects()
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self:tryLoadResEffects()
end

function M:update(dt)
    if self.player.forward.x ~= self.forwardX then
        self:refreshEffectForward()
    end
end

function M:refreshEffectForward()
    self.forwardX = self.player.forward.x
    local isForwardRight = self.forwardX >= 0
    if self.lastForward == isForwardRight then
        return
    end
    self.lastForward = isForwardRight
    for i, effectData in ipairs(self.resEffectList) do
        if effectData.isLoad and (not IsNull(effectData.obj)) then
            local transform = M.resEffectTransform[i] or M.resEffectTransform[1]
            local position = transform.position
            if not isForwardRight then
                position = position:Clone()
                position.x = -position.x
            end
            effectData.obj.transform.localPosition = position
        end
    end
end

-- 加载完成
function M:tryLoadResEffects()
    if self.isLoadedEffect then
        return
    end
    self.isLoadedEffect = true
    local target_view = self.player.plyMgr:GetPlayerViewByModel(self.model.player)
    if not target_view then
        return
    end
    local headObj = target_view.tran:Find("head")
    local camp = self.model.player.camp
    for i = 1, 5 do
        ---@type CS.UnityEngine.GameObject
        local effect = ResourceUtil:LoadRole3dEffect(self.player.prefabRoot, self.resEffectName, headObj.gameObject)
        local data = {isLoad = false, isVisible = false, obj = nil}
        self.resEffectList[i] = data
        if IsNull(effect) == false then
            local transform = M.resEffectTransform[i] or M.resEffectTransform[1]
            --local position = transform.position
            ----if camp == -1 then
            ----    position = position:Clone()
            ----    position.x = -position.x
            ----end
            --effect.transform.localPosition = position
            effect.transform.localEulerAngles = transform.rotation
            data.obj = effect
            data.isLoad = true
            data.obj:SetActive(data.isVisible)
        end
    end
    self:refreshEffectForward()
    if self.model and self.model.curResLv then
        self:refreshResLv(self.model.curResLv)
    end
end

--- 枪头数量变化
function M:onResLvChanged(eventName, eventData)
    local curLv = eventData.curResLv
    self:refreshResLv(curLv)
end

function M:refreshResLv(curLv)
    for i, v in ipairs(self.resEffectList) do
        if i <= curLv then
            if v.isVisible == false then
                v.isVisible = true
                v.obj:SetActive(v.isVisible)
            end
        else
            if v.isVisible == true then
                v.isVisible = false
                v.obj:SetActive(v.isVisible)
            end
        end
    end
end

function M:clearEffects()
    if self.resEffectList ~= nil then
        for i, effectData in ipairs(self.resEffectList) do
            if not IsNull(effectData.obj) then
                ResourceUtil:ReturnItem(effectData.obj)
                effectData.obj = nil
                effectData.isLoad = false
            end
        end
    end
    self.isLoadedEffect = false
end

function M:destroy()
    self:clearEffects()
    M.super.destroy(self)
end

return M
