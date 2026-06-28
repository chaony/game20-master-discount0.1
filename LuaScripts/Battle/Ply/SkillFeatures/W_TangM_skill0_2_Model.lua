local W_TangM_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_TangM_skill0_1_Model")
---@class W_TangM_skill0_2_Model : W_TangM_skill0_1_Model @
---@field super W_TangM_skill0_1_Model @W_TangM_skill0_1_Model
local M = class("W_TangM_skill0_2_Model", W_TangM_skill0_1_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.atkBuff = self:getParam(2)
end


--条件触发
function M:deadHandler( eventName, data )
	M.super.deadHandler(self, eventName, data)
	self.player.bufMgr:addBufById(self.atkBuff, self.player)
end


function M:destroy()
    M.super.destroy(self)
end

return M