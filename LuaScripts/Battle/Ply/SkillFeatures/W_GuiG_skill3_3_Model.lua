--鬼谷 skill3被动
--鬼谷引动天雷，对所有敌人造成300%攻击力的伤害，若命中的敌人被添加了诛邪印机，则会额外造成一次伤害
--被添加了诛邪印机的敌人还会额外收到持续2秒的眩晕
local W_GuiG_skill3_1_Model = require("Battle.Ply.SkillFeatures.W_GuiG_skill3_1_Model")
---@class W_GuiG_skill3_3_Model : W_GuiG_skill3_1_Model @
---@field super W_GuiG_skill3_1_Model @W_GuiG_skill3_1_Model
local M = class("W_GuiG_skill3_3_Model", W_GuiG_skill3_1_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.buffId = self:getParam(2)
end


function  M:changeValue(ply)
    ply.bufMgr:addBufById(self.buffId, self.player)
end


return M