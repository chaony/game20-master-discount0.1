--耀光圣剑
--龙庭英雄防御力加10% 受伤回怒 15%
---@class Relic_39 : Relic @
---@field super Relic @Relic
local M = class("Relic_39", Relic)

--防御
M.def = nil

--受伤会怒
M.hurtrageregen = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.def = self:getValue(1)
	self.hurtrageregen = self:getValue(2)
end

function M:gameStart()
	M.super.gameStart(self)
	local players = self.mgr:getTarget("self", "all")


	for i=1,players.Count do
		local ply = players:get(i-1)
		if ply.plyData.race == 1 then
			self:dealWithData(ply, "def", 1)
			self:dealWithData(ply, "hurtrageregen", 2)
		end
	end
end

return M