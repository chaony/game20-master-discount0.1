-- 每次切换至“轻剑决”姿态时，会立即释放一次该技能
local W_CangJ_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_CangJ_skill0_1_Model")
---@class W_CangJ_skill0_2_Model : W_CangJ_skill0_1_Model @
---@field super W_CangJ_skill0_1_Model @W_CangJ_skill0_1_Model
local M = class("W_CangJ_skill0_2_Model", W_CangJ_skill0_1_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className )
    self.useImmediately = true
end

return M