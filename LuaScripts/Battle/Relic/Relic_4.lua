--月之石
--血量高于50%的英雄会持续恢复怒气，同时拥有日之石，则恢复效果提升2倍
---@class Relic_4 : Relic @
---@field super Relic @Relic
local M = class("Relic_4", Relic)

M.rate = nil
--恢复速度
M.addSpeed = nil
--同时拥有日之石提升效果
M.power = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.rate = self:getValue(2)
	self.addSpeed = self:getValue(1)
	self.power = self:getValue(3)
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
	local targets = self.mgr:getTarget("self", "all")
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		if ply.data:get_hpRate() > self.rate then
			local value = GlobalTools:Mul(self.addSpeed , dt)
			if self.mgr:findById(3) ~= nil then
				value = GlobalTools:Mul(value, self.power)
			end
			ply.data:addAnger(GlobalTools:Mul(value, ply.data:get_maxAnger()))			
		end
	end
end

return M