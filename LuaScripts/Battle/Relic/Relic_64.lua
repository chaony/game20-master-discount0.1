--世界树枝叶
--战斗结束时恢复武魂15%生命值
---@class Relic_64 : Relic @
---@field super Relic @Relic
local M = class("Relic_64", Relic)

--生命回复量
M.cure = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.cure = self:getValue(1)
end

function M:gameover()
	M.super.gameover(self)
	local targets = self.mgr:getTarget("self", "all")
	self.plyList = {}
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		ply:cure("hp", nil, self.cure)
	end
end

return M