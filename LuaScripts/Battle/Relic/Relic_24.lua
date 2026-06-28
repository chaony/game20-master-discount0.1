--能量碎块
--单独一个能量碎块无法发挥任何作用，能解锁对应收益2个受到的伤害下降15%，3个造成伤害提升25%，4个以上暴击率提升40%
---@class Relic_24 : Relic @
---@field super Relic @Relic
local M = class("Relic_24", Relic)

--伤害下降
M.value2 = nil
--伤害提升
M.value3 = nil
--暴击提升
M.value4 = nil

M.rate = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	--忽略叠加次数，所以未用统一接口
	self.value2 = self:getValueSimple(1)
	self.value3 = self:getValueSimple(2)
	self.value4 = self:getValueSimple(3)
	
	self.rate = GlobalTools.base1
end

function M:gameStart()
	M.super.gameStart(self)
	if self.relicCount > 1 then
		local relic = self.mgr:findById(40)
		if relic ~= nil then
			self.rate = GlobalTools.base1 + relic.value
		end
		
		local targets = self.mgr:getTarget("self", "all")
		for i = 1, targets.Count do
			local ply = targets:get(i - 1)
			if ply ~= nil then
				if self.relicCount >= 2 then
					self:dealWithData(ply, "atd", 1)
					self:dealWithData(ply, "res", 1)
				end
				if self.relicCount >= 3 then
					self:dealWithData(ply, "physicaldamage", 2)
					self:dealWithData(ply, "magicdamage", 2)
				end
				if self.relicCount >= 4 then
					self:dealWithData(ply, "critrate_correct", 3)
				end
			end
		end
	end
end

return M