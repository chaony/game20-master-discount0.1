--每场战斗第一次触发该效果时，将不再消耗丹药	
--恢复生命值的效果提升值8%
local G_FuW_skill1_3_Model = require("Battle.Ply.SkillFeatures.G_FuW_skill1_3_Model")
---@class G_FuW_skill1_4_Model : G_FuW_skill1_3_Model @
---@field super G_FuW_skill1_3_Model @G_FuW_skill1_3_Model
local M = class("G_FuW_skill1_4_Model", G_FuW_skill1_3_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buff2 = self:getParam(4)
end


return M