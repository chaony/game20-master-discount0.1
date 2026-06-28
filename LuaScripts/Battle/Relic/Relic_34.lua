--蛮族利牙
--每个出场的草莽的武魂，使己方所有英雄吸血3%
---@class Relic_34 : Relic @
---@field super Relic @Relic
local M = class("Relic_34", Relic)

--吸血率
M.leeching = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.leeching = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	local count = 0
	local players = self.mgr:getTarget("self", "all")

	for i = 1, players.Count do
		local ply = players:get(i-1)
		if ply.plyData.race == 2 then
			count = count + 1
		end
	end
	
	if count > 0 then
		for i=1,players.Count do
			local ply = players:get(i-1)
			self:dealWithData(ply, "leeching", 1)
		end
	end
end

return M