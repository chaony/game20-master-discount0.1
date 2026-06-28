--银色箭矢
--当攻击目标为种族克制的话，伤害提过40%
---@class Relic_49 : Relic @
---@field super Relic @Relic
local M = class("Relic_49", Relic)


--伤害
M.atk = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.atk = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
end

function M:dataChangeTemp(killer, victim)
	if killer ~= nil and killer.camp == 1 and victim.camp == -1 then
		if GlobalTools:checkRace(killer, victim) == 1 then
			self:dealWithDataTemp(killer, "physicaldamage", 1)
			self:dealWithDataTemp(killer, "magicdamage", 1)
		end
	end
end

return M
