--神泪之华
--使用九转还魂丹之后本次副本的攻击提升30%，效果最多叠加4次
---@class Relic_51 : Relic @
---@field super Relic @Relic
local M = class("Relic_51", Relic)

--攻击增加量
M.atk = nil
--最大增加量
M.maxCount = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.atk, self.calType =self:getValue(1)
	self.maxCount = self:getValueSimple(2)
end

function M:gameStart()
	M.super.gameStart(self)
	--获胜场次
	local useCount = self.param["use_item_num"] or 0
	if useCount > self.maxCount then
		useCount = self.maxCount
	end
	local value = self.atk * useCount

	local targets = self.mgr:getTarget("self", "all")
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		
		self.dealWithValue(ply, "atk", self.calType, value)

		ply.data.relicAtkAddPercent = ply.data.relicAtkAddPercent * (1 + value)
	end
end




return M
