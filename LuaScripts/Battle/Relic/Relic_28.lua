--惧生灵兽
--当我方半场没有敌人时，所有友军提升12点急速
---@class Relic_28 : Relic @
---@field super Relic @Relic
local M = class("Relic_28", Relic)
--加速
M.addSpeed = nil

M.center = nil

M.have = true

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	
	self.addSpeed = self:getValue(1)
	self.center = FixVector3.New(0,0,0)
end

function M:gameStart()
	M.super.gameStart(self)
	
	local player = self.mgr.plyMgr.hero_list:get(0)
	
	self.center = SelectTargetTool:findFixPoint(player, "sceneCenter")
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
	local targets = self.mgr:getTarget("enemy", "all")

	local have = false
	for i = targets.Count, 1, -1 do
		local ply = targets:get(i - 1)

		--进入我方半场
		if ply.position.x < self.center.x then
			have = true
			break
		end
	end

	if self.have and have == false then
		self.have = have
		--增加速度
		local friends = self.mgr:getTarget("self", "all")
		for i = friends.Count, 1, -1 do
			local ply = friends:get(i - 1)
			self:dealWithData(ply, "haste", 1)
		end
		
	elseif self.have == false and have then
		--减速
		self.have = have
		local friends = self.mgr:getTarget("self", "all")
		for i = friends.Count, 1, -1 do
			local ply = friends:get(i - 1)
			self:removeData(ply, "haste", 1)
		end
	end
end

return M