--稻草娃娃
--战斗开始时随机一名敌人受到伤害增加
---@class Relic_8 : Relic @
---@field super Relic @Relic
local M = class("Relic_8", Relic)

--加速时长
M.time = nil
--加速倍数
M.damage = nil

M.timer = 0

M.ply = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.time = self:getValue(2)
	local damage, type = self:getValue(1)
	self.bufDataId = 0
end

function M:gameStart()
	M.super.gameStart(self)
	self.timer = self.time
	self:addBuf()
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
	self.timer = self.timer - dt
	if self.timer > 0 and (self.ply == nil or self.ply:isDead()) then
		self:addBuf()
	end
end

function M:addBuf()
	local targets = self.mgr:getTarget("enemy", "one")
	--self.bufData["lastTime"] = self.timer
	--for i = 1, targets.Count do
	--	self.ply = targets:get(i - 1)
	--	self.ply.bufMgr:addBufById(self.bufDataId, nil)
	--end
end

return M