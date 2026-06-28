--鬼谷被动
--战斗开始时，鬼谷会在我方半场布下阵法。处于阵法中的我方友军，攻击力会提升15%，敌方角色的攻击会减少15%.
--我方角色获得的攻击力加成提高30%
--敌方角色的攻击力减少提升至30%
local W_GuiG_skill0_2_Model = require("Battle.Ply.SkillFeatures.W_GuiG_skill0_2_Model")
---@class W_GuiG_skill0_3_Model : W_GuiG_skill0_2_Model @
---@field super W_GuiG_skill0_2_Model @W_GuiG_skill0_2_Model
local M = class("W_GuiG_skill0_3_Model", W_GuiG_skill0_2_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.buffId = self:getParam(1)
    self.buffId2 = self:getParam(2)
end


function M:destroy()
    M.super.destroy(self)
end

   

return M