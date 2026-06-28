--蛮族巨斧
--草莽的英雄攻击力加10% 吸血15%
---@class Relic_40 : Relic @
---@field super Relic @Relic
local M = class("Relic_40", Relic)

--攻击
M.atk = nil

--吸血率
M.leeching = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.atk = self:getValue(1)
	self.leeching = self:getValue(2)
end

function M:gameStart()
	M.super.gameStart(self)
	local players = self.mgr:getTarget("self", "all")


	for i=1,players.Count do
		local ply = players:get(i-1)
		if ply.plyData.race == 2 then
			self:dealWithData(ply, "atk", 1)
			self:dealWithData(ply, "leeching", 2)
		end
	end
end

return M