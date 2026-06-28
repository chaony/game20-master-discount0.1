--援护战旗
--布阵在后排的已方武魂攻击加5%，暴击率10%
---@class Relic_31 : Relic @
---@field super Relic @Relic
local M = class("Relic_31", Relic)

--伤害
M.atk = nil
--暴击率
M.crit = nil


function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.atk =self:getValue(1)
	self.crit = self:getValue(2)

end

function M:gameStart()
	M.super.gameStart(self)
	local targets = self.mgr:getTarget("self","backrow")
	for i = 1, targets.Count  do
		local ply = targets:get(i-1)
		self:dealWithData(ply, "atk", 1)
		self:dealWithData(ply, "critrate_correct", 2)
	end

end

return M