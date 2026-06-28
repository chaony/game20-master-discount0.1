--猎手之爪
--攻击最大生命值最高的敌人，造成伤害越高，最多提升25%
---@class Relic_55 : Relic @
---@field super Relic @Relic
local M = class("Relic_55", Relic)

--伤害
M.atk = nil


function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	
	self.atk, self.calType =  self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
end

function M:dataChangeTemp(killer, victim)
	if killer ~= nil and killer.camp == 1 and victim.camp == -1 then
		local players = self.mgr:getTarget("enemy", "all")
		local maxHp = 0
		for i = 1, players.Count do
			local ply = players:get(i-1)
			if ply.data:get_hp() > maxHp then
				maxHp = ply.data:get_hp()
			end
		end
		local value = victim.data:get_hp() / maxHp * self.atk
		self:dealWithValueTemp(killer, "physicaldamage", self.calType, value)
		self:dealWithValueTemp(killer, "magicdamage", self.calType, value)
	end
end

function M:gameover()
	M.super.gameover(self)
end

return M
