--充盈号角
--战斗开始时，己方出场武魂恢复60怒气
---@class Relic_10 : Relic @
---@field super Relic @Relic
local M = class("Relic_10", Relic)

--怒气回复量
M.anger = 0

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.anger = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	local targets = self.mgr:getTarget("self", "all")

	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		ply.data:addAnger(self.anger)
	end
end

return M