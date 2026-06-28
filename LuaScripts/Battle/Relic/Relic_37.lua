--世族神弓
--世族的英雄暴击率增加10%，速度10%
---@class Relic_37 : Relic @
---@field super Relic @Relic
local M = class("Relic_37", Relic)

--暴击率
M.crit = nil

--速度
M.animSpeed = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.crit = self:getValue(1)
	self.animSpeed = self:getValue(2)
end

function M:gameStart()
	M.super.gameStart(self)
	local players = self.mgr:getTarget("self", "all")


	for i=1,players.Count do
		local ply = players:get(i-1)
		if ply.plyData.race == 3 then
			self:dealWithData(ply, "critrate_correct", 1)
			self:dealWithData(ply, "haste", 2)
		end

	end
end

return M