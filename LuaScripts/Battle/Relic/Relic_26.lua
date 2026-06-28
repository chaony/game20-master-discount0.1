--远征旗帜
--仅在第三层困难模式中有用，处于困难模式第三层时提升12%攻击与防御
---@class Relic_26 : Relic @
---@field super Relic @Relic
local M = class("Relic_26", Relic)

M.value = nil
--生效层数
M.floor = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.value = self:getValue(1)
	self.floor = self:getValue(2)
end

function M:gameStart()
	M.super.gameStart(self)
	--第三层
	if self.floor == self.param["floor"] then
		local targets = self.mgr:getTarget("self", "all")
		for i = 1, targets.Count do
			local ply = targets:get(i - 1)
			self:dealWithData(ply, "atk", 1)
			self:dealWithData(ply, "def", 1)
		end
	end
end

return M