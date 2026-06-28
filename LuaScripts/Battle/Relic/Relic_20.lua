--活力戒指
--战斗时，己方受到的生命恢复效果提高40%
---@class Relic_20 : Relic @
---@field super Relic @Relic
local M = class("Relic_20", Relic)

--内外伤减伤
M.cure = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.cure = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	local targets = self.mgr:getTarget("self", "all")
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		self:dealWithData(ply, "cureRate", 1)
	end
end

return M