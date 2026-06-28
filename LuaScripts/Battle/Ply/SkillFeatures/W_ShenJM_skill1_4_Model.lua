--当自身处于“神剑“或“真·神剑”状态时，被命中的敌人还会被眩晕2秒

local W_ShenJM_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_ShenJM_skill1_1_Model")
---@class W_ShenJM_skill1_4_Model : W_ShenJM_skill1_1_Model @
---@field super W_ShenJM_skill1_1_Model @W_ShenJM_skill1_1_Model
local M = class("W_ShenJM_skill1_4_Model", W_ShenJM_skill1_1_Model)

--初始化
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.buffData1 = self:getParam(1) -- 眩晕buff
end

function M:skillStart(data)
	local skill3Buff = self.player.bufMgr:findBufByTag("W_ShenJM_skill3")
	local skill2Buff = self.player.bufMgr:findBufByTag("W_ShenJM_skill2")
	if #skill3Buff > 0 or #skill2Buff>0 then
		self.player.bufMgr:addBufById(self.buffData1)
	end
	M.super.skillStart(self,data)
end

function M:destroy()
	M.super.destroy(self)
end


return M