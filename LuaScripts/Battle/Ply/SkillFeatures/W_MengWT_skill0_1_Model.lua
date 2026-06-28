--战斗开始，蒙武堂5秒内免疫控制，该技能每20秒仅能触发一次，且每次触发都会为蒙武堂恢复10%最大生命值的血量
---@class W_MengWT_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @W_MengWT_skill2_1_Model
local M = class("W_MengWT_skill0_1_Model", SkillFeatures_Model)

--初始化
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.intervalTime = self:getParam(1) -- 间隔时间
	self.buffData1 = self:getParam(2) -- 触发buff1
	self.buffData2 = self:getParam(3) -- 触发buff2
	self.timer = TimeTools:startOneLoopTask(self.intervalTime, handler(self, self.onResetTrigger))
end

function M:spawn()
	M.super.spawn(self)
	self:onResetTrigger()
end

-- 每隔20秒给自己加俩buff
function M:onResetTrigger()
	self.player.bufMgr:addBufById(self.buffData1, self.player)
	self.player.bufMgr:addBufById(self.buffData2, self.player)
end

function M:update(time)
	if self.timer then
		self.timer:update_dt(time)
	end
end

function M:destroy()
	self.timer = nil
	M.super.destroy(self)
end


return M