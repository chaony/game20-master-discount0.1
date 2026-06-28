--恢复水晶
--当队友生命低于40%时，可在 20 秒内每秒恢复队友4%的生命值，每场触发一次。
---@class Relic_63 : Relic @
---@field super Relic @Relic
local M = class("Relic_63", Relic)

--触发线
M.hpLine = nil
--时长
M.time = nil
--回复量
M.cure = nil

M.ply = nil

M.totalTimer = nil 

M.timer = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.hpLine = self:getValue(1)
	self.time = self:getValue(2)
	self.cure = self:getValue(3)
end

function M:gameStart()
	M.super.gameStart(self)
	self.ply = nil
	self.timer = 1
	self.totalTimer = self.time
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)

	if self.ply == nil then
		local targets = self.mgr:getTarget("self", "all")
		for i = 1, targets.Count do
			local ply = targets:get(i - 1)
			if ply:isLive() and ply.data:get_curHp() / ply.data:get_hp() < self.hpLine then
				self.ply = ply
				break
			end
		end
	end

	if self.ply ~= nil and self.ply:isLive() and self.totalTimer > 0 then
		self.timer = self.timer - dt
		if self.timer <= 0 then
			self.timer = self.timer + 1
			self.totalTimer = self.totalTimer - 1
			self.ply:cure("hp", nil, self.cure,true)
		end
	end
end

return M