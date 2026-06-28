--幻术勾玉
--战斗开始时，大幅削弱敌人的生命 ( 战斗开始时，所有敌方英雄的生命减少35%，被减少的生命将在战斗开始的10秒内逐渐恢復）
---@class Relic_11 : Relic @
---@field super Relic @Relic
local M = class("Relic_11", Relic)

--生命减少量
M.hpReduce = 0
--回复时间
M.time = nil

M.timer = nil

M.plyList = nil
function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.hpReduce = self:getValue(1)
	self.time = self:getValue(2)
end

function M:gameStart()
	M.super.gameStart(self)
	local targets = self.mgr:getTarget("enemy", "all")
	self.plyList = Battle.ListMap.new()
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		local reduce = GlobalTools:Mul( ply.data:get_hp(), self.hpReduce )
		ply:setHp( ply.data:get_curHp() - reduce )
		local reduce_v = reduce / self.time
		self.plyList:add(ply, reduce_v)
	end
	self.timer = self.time
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
	self.timer = self.timer - dt
	if self.timer >= 0 then
		for i = 1, self.plyList.list.Count do
			local k = self.plyList.list:get(i-1)
			local v = self.plyList:get(k)
			if k ~= nil and k:isLive() then
				k:setHp(k.data:get_curHp() + v * dt)
			end
		end
	end
end

return M