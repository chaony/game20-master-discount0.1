--巧手护手
--本方全体武魂+50命中，+10%暴击率
---@class Relic_13 : Relic @
---@field super Relic @Relic
local M = class("Relic_13", Relic)

--命中
M.hr = nil
--暴击率
M.critrate_correct = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.hr = self:getValue(1)
	self.critrate_correct = self:getValue(2)
end

function M:gameStart()
	M.super.gameStart(self)
	local targets = self.mgr:getTarget("self", "all")
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		self:dealWithData(ply, "hr", 1)
		self:dealWithData(ply, "critrate_correct", 2)
	end
end

return M