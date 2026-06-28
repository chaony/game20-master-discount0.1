--敏捷型武神，暴伤增加{x}，击杀敌人额外回复{z}点怒气，且 攻击敌人远程单位时，每次普攻减少{y}点怒气
---@class Relic_302 : Relic @
---@field super Relic @Relic
local M = class("Relic_302", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	--暴伤增加{x}
	self.crit = self:getValue(1)
	--额外获得怒气回复{z}点怒气
	self.outAnger = self:getValue(2);
	--攻击敌人远程单位时，每次普攻 伤害减少 buff{y}
	self.reduceDamageBuff = self:getValue(3);
end

function M:gameStart()
	M.super.gameStart(self)
	--敏捷型英雄
	local players = self.mgr:getTarget("self", "all")
	for i=1,players.Count do
		local ply = players:get(i-1)
		if ply.plyData.type == self.data.hero_type then
			ply.bufMgr:addBufById(self.crit, ply)
			self:playEffect(ply)
		end
	end
end

--攻击结束
function M:attackOver( beHitPlayer, killer, damage )
	--攻击者是敏捷英雄
	if killer.camp == self.mgr.camp and killer.plyData.type == 2 then
		--减少 远程单位 的怒气
		if beHitPlayer.plyData.fight_type == 2 then
			beHitPlayer.bufMgr:addBufById(self.reduceDamageBuff, beHitPlayer)
		end
	end
end


--攻击结束
function M:playDead( dead, killer )
	--杀人者是敏捷型武神
	if killer.camp == self.mgr.camp and killer.plyData.type == 2 then
		killer.data:addAnger(self.outAnger, true)
	end
end

return M