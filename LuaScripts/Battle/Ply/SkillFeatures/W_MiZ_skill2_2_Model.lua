--密宗    梵言释厄
-- lv2 当自身处于“涅槃”状态时，该技能冷却时间会大幅度减少
local W_MiZ_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_MiZ_skill2_1_Model")
---@class W_MiZ_skill2_2_Model : SkillFeatures_Model @
---@field super W_MiZ_skill2_1_Model @W_MiZ_skill2_1_Model
local M = class("W_MiZ_skill2_2_Model", W_MiZ_skill2_1_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.preCD = self:getParam(2)  --[Fix:0-100] 涅槃初始冷却时间
    self.postCD = self:getParam(3)  --[Fix:0-100] 涅槃冷却时间

    EventDispatcher:registerEvent("relive", {self,self.reliveHandler})
end

function M:resetSkillCD()
    self.skill.pre_cd = self.preCD
    self.skill.post_cd = self.postCD
end

---@param data Battle_HandleData_Relive
function M:reliveHandler(eventName, data)
    if self.player:equal(data.player) then
        self:resetSkillCD()
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("relive", {self,self.reliveHandler})
    M.super.destroy(self)
end

return M