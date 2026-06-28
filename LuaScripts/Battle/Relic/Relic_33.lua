--帝国手镯
--每个出场的龙庭的武魂，使己方所有英雄防御+10%
---@class Relic_33 : Relic @
---@field super Relic @Relic
local M = class("Relic_33", Relic)

--防御
M.def = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.def = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)

	local count = 0
	local players = self.mgr:getTarget("self", "all")

	for i = 1, players.Count do
		local ply = players:get(i-1)
		if ply.plyData.race == 1 then
			count = count + 1
		end
	end

	if count > 0 then
		for i = 1, players.Count do
			local ply = players:get(i-1)
			self:dealWithData(ply, "def", 1)
		end
	end

end

return M