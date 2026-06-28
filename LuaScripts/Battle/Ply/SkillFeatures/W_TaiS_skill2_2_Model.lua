--泰山 泰山没减少1%的 最大生命值，便获得1%……的防御强化 最多60%
--二级 最多80%
local W_TaiS_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_TaiS_skill2_1_Model")
---@class W_TaiS_skill2_2_Model : W_TaiS_skill2_1_Model @
---@field super W_TaiS_skill2_1_Model @W_TaiS_skill2_1_Model
local M = class("W_TaiS_skill2_2_Model", W_TaiS_skill2_1_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.max_hp = self:getParam(3)  
end

return M