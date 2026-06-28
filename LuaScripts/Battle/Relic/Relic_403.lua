--进入敌人半场的我方武神，将获得以下祝福：伤害增加{x}%，减伤增加{y}%，受伤回怒增加{z}%
---@class Relic_403 : Relic @
---@field super Relic @Relic
local M = class("Relic_403", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.bufId = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	local player = self.mgr.plyMgr.hero_list:get(0)
	self.center = SelectTargetTool:findFixPoint(player, "sceneCenter")
	self.friendOutEnemy = Battle.List.new()
	self.friendOutEnemy = self.mgr:getTarget("self", "all")
	self.friendInEnemy = Battle.List.new()
	self.defChangeValue = {}
	self.suckChangeValue = {}
end


function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
	if self.friendOutEnemy ~= nil then
		for i = self.friendOutEnemy.Count, 1, -1 do
			local ply = self.friendOutEnemy:get(i - 1)
			--进入敌方半场
			if ply.position.x > self.center.x then
				ply.bufMgr:addBufById(self.bufId, ply)
				self:playEffect(ply)
				self.friendInEnemy:add(ply)
				self.friendOutEnemy:remove(ply)
			end
		end

		for i = self.friendInEnemy.Count, 1, -1 do
			local ply = self.friendInEnemy:get(i - 1)
			--回到我方半场
			if ply.position.x < self.center.x then
				ply.bufMgr:removeBufById(self.bufId, true, false)
				self.friendOutEnemy:add(ply)
				self.friendInEnemy:remove(ply)
			end
		end
	end
end


return M