
--几率附加打断效果 30 %
local W_TangM_skill1_3_Model = require("Battle.Ply.SkillFeatures.W_TangM_skill1_3_Model")
---@class W_TangM_skill1_4_Model : W_TangM_skill1_3_Model @
---@field super W_TangM_skill1_3_Model @W_TangM_skill1_3_Model
local M = class("W_TangM_skill1_4_Model", W_TangM_skill1_3_Model)


--function M:init(ply, skill,className)
--    M.super.init(self, ply, skill,className)
--    self.buffId1 = self:getParam(3)
--	self.ran = self:getParam(4)
--end
--
--
--function M:changeFunc(buff)
--	M.super.changeFunc(self,buff)
--	local r = WRandom:randomNum(0, 100)
--	local r_fix = r;
--	if r <= self.ran then
--		buff.player.bufMgr:addBufById(self.buffId1, self.player)
--	end
--end

return M