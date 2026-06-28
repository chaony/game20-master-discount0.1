--卫队头盔
--受到伤害-10%
---@class Relic_16 : Relic @
---@field super Relic @Relic
local M = class("Relic_16", Relic)

--内外伤减伤
M.atk_reduce_percent = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.atk_reduce_percent = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	local targets = self.mgr:getTarget("self", "all")
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		self:dealWithData(ply, "atd", 1)
		self:dealWithData(ply, "res", 1)
	end
end

return M