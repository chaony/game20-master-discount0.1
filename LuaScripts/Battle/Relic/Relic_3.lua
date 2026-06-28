--日之石
--怒气高于50%的英雄会持续恢复生命，同时拥有日之石，则恢复效果提升2倍
---@class Relic_3 : Relic @
---@field super Relic @Relic
local M = class("Relic_3", Relic)

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
		if ply:get_camp() == self:get_camp() and ply.data:get_AngerRate() > self.rate then
			local value = GlobalTools:Mul(self.addSpeed, dt)
			if self.mgr:findById(4) ~= nil then
				value = GlobalTools:Mul(value, self.power)
			end
			local hp_value = GlobalTools:Mul(value, ply.data:get_hp())
			ply:cure("fix",ply, hp_value, nil, true)	
		end
	end
end

return M