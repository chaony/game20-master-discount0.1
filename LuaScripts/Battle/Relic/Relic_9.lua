--巨神之礼
--战斗开始时，己方生命值高于95%的英雄提高20%攻击力直到战斗结束
---@class Relic_9 : Relic @
---@field super Relic @Relic
local M = class("Relic_9", Relic)

--血量比率
M.hpRate = nil
--攻击力提升
M.addDamage = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.hpRate = data["param"][2][2]
	self.addDamage = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	local targets = self.mgr:getTarget("self", "all")

	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		if ply.data:get_curHp() / ply.data:get_hp() >= self.hpRate then
			self:dealWithData(ply, "atk", 1)
		end
	end
end

return M