--亡灵法珠
--每个出场的异族的武魂，使己方所有英雄攻击力+3%
---@class Relic_35 : Relic @
---@field super Relic @Relic
local M = class("Relic_35", Relic)

--吸血率
M.atk = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.atk = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	local count = 0
	local players = self.mgr:getTarget("self", "all")

	for i = 1, players.Count do
		local ply = players:get(i-1)
		if ply.plyData.race == 4 then
			count = count + 1
		end
	end

	if count > 0 then
		for i=1,players.Count do
			local ply = players:get(i-1)
			self:dealWithData(ply, "atk", 1)
		end
	end
end

return M