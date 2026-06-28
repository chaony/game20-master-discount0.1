-- 战斗中，潘金莲受到来自敌方男性角色的伤害减少40%，
-- 当自身受到致命伤害时，会立刻瞬移至己方一名随机男性角色身边，使其在之后的5秒内，替自己承受伤害，该效果每场战斗只能触发一次
---@class W_PanJL_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_PanJL_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className) 
    M.super.init(self, ply, skill,className)
    EventDispatcher:registerEvent("AfterSkillEnter", {self,self.SkillEnterHandler})
end

---@param eventData Battle_HandleData_SkillEnter
function M:SkillEnterHandler(eventName, eventData)
    if self.player:equal(eventData.player) then
        if self.player.curSkillConfig == self.skill then
            local enemyCenter = SelectTargetTool:findFixPoint(self.player, "enemyCenter")
            local forward = enemyCenter - self.player.position
            self.player:setForward(forward, true)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("AfterSkillEnter", {self,self.SkillEnterHandler})
    M.super.destroy(self)
end

return M