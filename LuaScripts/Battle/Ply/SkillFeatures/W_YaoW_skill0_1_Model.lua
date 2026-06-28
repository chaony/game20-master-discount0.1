--药王造成的治疗效果提高15%
---@class W_YaoW_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_YaoW_skill0_1_Model", SkillFeatures_Model)

M.cureRate = nil

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.cureRate = self:getParam(1)
end

function M:spawn()
    M.super.spawn(self)
    self.player.data.cureRate:addToMulList(self.cureRate)
end

function M:destroy()
    M.super.destroy(self)
end

return M