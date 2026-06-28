--龙门 中毒状态下的敌人时，造成的伤害提升20%
--攻击中毒状态下的敌人 造成伤害提升30%
local W_LongM_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_LongM_skill2_1_Model")
---@class W_LongM_skill2_2_Model : W_LongM_skill2_1_Model @
---@field super W_LongM_skill2_1_Model @W_LongM_skill2_1_Model
local M = class("W_LongM_skill2_2_Model", W_LongM_skill2_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.dmg = self:getParam(1)
end


return M