--陷阵之志
--进入敌方半场的友军防御+10%，吸血+10%
---@class Relic_27 : Relic @
---@field super Relic @Relic
local M = class("Relic_27", Relic)

--防御提升
M.def = nil
--吸血提升
M.suck = nil

M.friendInEnemy = nil

M.friendOutEnemy = nil

M.defChangeValue = nil

M.suckChangeValue = nil

M.center = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.def = self:getValue(1)
	self.suck = self:getValue(2)
	self.center = FixVector3.New(0,0,0)
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
				self.defChangeValue[ply.index] = self.def
				self:dealWithData(ply, "def", 1)

				self.suckChangeValue[ply.index] = self.suck
				self:dealWithData(ply, "leeching", 2)
				
				self.friendInEnemy:add(ply)
				self.friendOutEnemy:remove(ply)
			end
		end
	
		for i = self.friendInEnemy.Count, 1, -1 do
			local ply = self.friendInEnemy:get(i - 1)

			--回到我方半场
			if ply.position.x < self.center.x then
				self:removeData(ply, "def", 1)
				self:removeData(ply, "leeching", 2)
				
				self.friendOutEnemy:add(ply)
				self.friendInEnemy:remove(ply)
			end
		end
	end
	
end

return M