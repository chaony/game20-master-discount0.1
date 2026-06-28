---@class W_XieJ_skill1_1_View : SkillFeatures_View
---@field super SkillFeatures_View
local M = class("W_XieJ_skill1_1_View", SkillFeatures_View)

M.effectNames = {
    "W_XieJ_Skill0_Buff_001a",
    "W_XieJ_Skill0_Buff_001b",
    "W_XieJ_Skill0_Buff_001c",
    "W_XieJ_Skill0_Buff_001d",
    "W_XieJ_Skill0_Buff_001e",
}
M.completeEffectName = "W_XieJ_Skill1_SF_002"


function M:init(ply, skill, model)
    M.super.init(self, ply, skill, model)
    self.effectList = {}
    self:addEventListener_Local(Battle.SkillEventType.MV_W_XieJ_skill1_1_Model_ResLv_Changed,{self, self.MV_W_XieJ_skill1_1_Model_ResLv_Changed})
end

--显示特效
function M:MV_W_XieJ_skill1_1_Model_ResLv_Changed(eventName, data)
    local target = data.player
    local target_view = self.player.plyMgr:GetPlayerViewByModel(target)
    local index = data.index
    self:checkCurLvEffects(data.curLv)
    for i, data in ipairs(self.effectList) do
        if data.isLoad == false then
            local effect = ResourceUtil:LoadRole3dEffect(self.player.prefabRoot, data.effectName, target_view.obj)
            if IsNull(effect) == false then
                effect.transform.localPosition = Vector3.New(0,0,0)
                effect.transform.localEulerAngles = Vector3.New(0,180,0)
                data.obj = effect
                data.isLoad = true
            end
        end
    end
    if #self.effectList >= 5 then   -- 邪灵层数已满
        local effect = ResourceUtil:LoadRole3dEffect(self.player.prefabRoot, self.completeEffectName, target_view.obj)
        if IsNull(effect) == false then
            effect.transform.localPosition = Vector3.New(0,0,0)
            effect.transform.localEulerAngles = Vector3.New(0,180,0)
            self.completeEffect = effect
        end
    end
end

function M:checkCurLvEffects(curLv)
    local lv = Mathf.Min(curLv, 5)
    for i = 1, lv do
        if not self.effectList[i] then
            self.effectList[i] = {isLoad = false, effectName = M.effectNames[i]}
        end
    end
end

function M:clearEffects()
    if self.effectList ~= nil then
        for i, effectData in ipairs(self.effectList) do
            if effectData.obj then
                ResourceUtil:ReturnItem(effectData.obj)
                effectData.obj = nil
                effectData.isLoad = false
            end
        end
    end
    if self.completeEffect then
        ResourceUtil:ReturnItem(self.completeEffect)
        self.completeEffect = nil
    end
end

function M:destroy()
    self:clearEffects()
    self.effectList = nil
    self.completeEffect = nil
    M.super.destroy(self)
end

return M
