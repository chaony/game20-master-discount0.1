--勇气之心
--武魂生命越低造成的伤害越高，最多提升25%
---@class Relic_66 : Relic @
---@field super Relic @Relic
local M = class("Relic_66", Relic)

--最大提升
M.maxAdd = nil

M.plyList = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.maxAdd, self.calType = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	local targets = self.mgr:getTarget("self", "all")
	self.plyList = {}
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		self.plyList[ply.index] = 0
	end
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
	local targets = self.mgr:getTarget("self", "all")

	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		if ply ~= nil and ply:isLive() then
			local value = (1 - ply.data:get_curHp() / ply.data:get_hp() ) * self.maxAdd
			self:removeValue(ply, "physicaldamage", self.calType, self.plyList[ply.index])
			self:dealWithValue(ply, "physicaldamage", self.calType, value)

			self:removeValue(ply, "magicdamage", self.calType, self.plyList[ply.index])
			self:dealWithValue(ply, "magicdamage", self.calType, value)
			
			self.plyList[ply.index] = value
		end
	end
end

return M