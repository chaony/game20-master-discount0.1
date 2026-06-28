--强化后的普攻命中拥有护盾的敌人时，会清空敌人的所有护盾值
local W_TanH_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_TanH_skill2_1_Model")
---@class W_TanH_skill2_3_Model : W_TanH_skill2_1_Model @
---@field super W_TanH_skill2_1_Model @W_TanH_skill2_1_Model
local M = class("W_TanH_skill2_3_Model", W_TanH_skill2_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.armorBreak = true
end

return M