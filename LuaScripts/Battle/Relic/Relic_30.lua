--先锋战旗
--布阵在前排的已方武魂防御加10%，受伤会怒加10%
---@class Relic_30 : Relic @
---@field super Relic @Relic
local M = class("Relic_30", Relic)

--防御
M.def = nil
--受伤回怒
M.hurtrageregen = nil


function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.def = self:getValue(1)
	self.hurtrageregen = self:getValue(2)

end

function M:gameStart()
	M.super.gameStart(self)
	local targets = self.mgr:getTarget("self","frontrow")
	for i = 1, targets.Count  do
		local ply = targets:get(i-1)
		self:dealWithData(ply, "def", 1)
		self:dealWithData(ply, "hurtrageregen", 2)
	end

end
return M