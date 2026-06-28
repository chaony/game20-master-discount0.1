--吸血之牙
--吸血+10%
---@class Relic_18 : Relic @
---@field super Relic @Relic
local M = class("Relic_18", Relic)

--内外伤减伤
M.suck = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.suck = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	local targets = self.mgr:getTarget("self", "all")
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		self:dealWithData(ply, "leeching", 1)
	end
end

return M