-- 等级2:战斗开始时，该技能会立刻释放一次，且护盾值额外提升50%

local W_JiuT_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_JiuT_skill0_1_Model")
---@class W_JiuT_skill0_2_Model : W_JiuT_skill0_1_Model @
---@field super W_JiuT_skill0_1_Model @W_JiuT_skill0_1_Model
local M = class("W_JiuT_skill0_2_Model", W_JiuT_skill0_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.shieldBuff2 = self:getParam(2)
end

function M:spawn()
    M.super.spawn(self)
    self:addShieldBuff(self.shieldBuff2) -- 加护盾buff
end

function M:destroy()
    M.super.destroy(self)
end

return M