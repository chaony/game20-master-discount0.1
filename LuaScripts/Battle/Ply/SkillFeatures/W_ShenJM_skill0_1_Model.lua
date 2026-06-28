--每次进入“”神剑“或“真·神剑”状态时，会获得40%伤害减免和30点吸血效果，该效果不可叠加
---@class W_ShenJM_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @W_ShenJM_skill0_1_Model
local M = class("W_ShenJM_skill0_1_Model", SkillFeatures_Model)

--初始化
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.buffData1 = self:getParam(1) -- 40%伤害减免和30点吸血buff
	self.buffData2 = self:getParam(2) -- 会恢复20%最大生命值的血量
end

function M:update(dt, unsdt)
	M.super.update(self,dt,unsdt)
	local buffList = self.player.bufMgr:findBufById(self.buffData1)
	if #buffList > 0 then
		local skill3Buff = self.player.bufMgr:findBufByTag("W_ShenJM_skill3")
		local skill2Buff = self.player.bufMgr:findBufByTag("W_ShenJM_skill2")
		if #skill3Buff == 0 and #skill2Buff==0 then
			self.player.bufMgr:removeBufById(self.buffData1, true)
		end
	end
end

function M:destroy()
	M.super.destroy(self)
end


return M