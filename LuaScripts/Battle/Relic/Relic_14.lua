--暗影匕首
--本方全体武魂+10%暴击率
---@class Relic_14 : Relic @
---@field super Relic @Relic
local M = class("Relic_14", Relic)

--命中
M.critrate = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.critrate = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	local targets = self.mgr:getTarget("self", "all")
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		self:dealWithData(ply, "critrate_correct", 1)
	end
end

return M