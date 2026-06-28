--世族神石
--每个出场的世族的武魂，使己方所有英雄闪避+4点
---@class Relic_36 : Relic @
---@field super Relic @Relic
local M = class("Relic_36", Relic)

--闪避
M.dodge = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.dodge = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	local count = 0
	local players = self.mgr:getTarget("self", "all")

	for i = 1, players.Count do
		local ply = players:get(i-1)
		if ply.plyData.race == 3 then
			count = count + 1
		end
	end
	if count > 0 then
		for i=1,players.Count do
			local ply = players:get(i-1)
			self:dealWithData(ply, "dodge", 1)
		end
	end
end

return M