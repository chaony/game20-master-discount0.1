--前排武神，战斗开始后赋予 生命{x}%的护盾，持续{y}秒
---@class Relic_201 : Relic @
---@field super Relic @Relic
local M = class("Relic_201", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.bufId = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	local pos_key = "frontrow"
	if self.data.hero_position == 2 then
		pos_key = "backrow"
	end
	--前排队友
	local targets = self.mgr:getTarget("self",pos_key)
	for i = 1, targets.Count  do
		local ply = targets:get(i-1)
		ply.bufMgr:addBufById(self.bufId, ply)
		self:playEffect(ply)
	end
end

return M