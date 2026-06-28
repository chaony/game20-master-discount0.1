--神农鼎战斗中第一个濒死武神【受到致命伤时】，将免疫本次伤害，且赋予{x}秒的无敌效果，且获得{y}点吸血
---@class Relic_401 : Relic @
---@field super Relic @Relic
local M = class("Relic_401", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.count = self:getValue(1)
	self.wudibufId = self:getValue(2)
	self.xixuebufId = self:getValue(3)
	self.curCount = 0
end

function M:gameStart()
	self.curCount = self.count or 0
end

--死亡前
---@param dead PlayerModel
function M:beforeDead(dead, player, damage)
	if dead.camp == self.mgr.camp and (dead.master == nil or dead.playerId == 5021) and dead.playerType ~= "pet" then -- 召唤物不触发免死效果(昆仑除外)
		if self.curCount > 0 then
			dead.bufMgr:addBufById(self.wudibufId, dead)
			dead.bufMgr:addBufById(self.xixuebufId, dead)
			self.curCount = self.curCount - 1;
			return 0;
		end
	end
	return damage;
end

return M