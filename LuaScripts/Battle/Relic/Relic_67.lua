--圣光庇护
--每过 10 秒降下圣光治疗最虚弱友军40%已损失生命。
---@class Relic_67 : Relic @
---@field super Relic @Relic
local M = class("Relic_67", Relic)

--时间间隔
M.interval = nil
--伤害
M.cure = nil

M.timer = nil

M.data = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.interval = self:getValue(1)
	self.cure = self:getValue(2)
	
	self.data =
	{
		["count"] = "one",
		["camp"] = "friend",
		["campRace"] = "not",
		["pos"] = "bloodLeast",
		["profession"] = "all",
		["area"] = "all",
	}
end

function M:gameStart()
	M.super.gameStart(self)
	self.timer = 0
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
	self.timer = self.timer - dt
	if self.timer <= 0 then
		self.timer = self.timer + self.interval
		local targets = self.mgr:getTargetData(self.data)

		for i = 1, targets.Count do
			local ply = targets:get(i - 1)
			ply:cure("fix", nil, self.cure * (ply.data:get_hp() - ply.data:get_curHp() ))
		end
	end
end

return M