--每场战斗第一次触发该效果时，将不再消耗丹药	
--恢复生命值的效果提升值8%
local W_FuW_skill1_3_Model = require("Battle.Ply.SkillFeatures.W_FuW_skill1_3_Model")
---@class W_FuW_skill1_4_Model : W_FuW_skill1_3_Model @
---@field super W_FuW_skill1_3_Model @W_FuW_skill1_3_Model
local M = class("W_FuW_skill1_4_Model", W_FuW_skill1_3_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buff2 = self:getParam(4)
end


return M