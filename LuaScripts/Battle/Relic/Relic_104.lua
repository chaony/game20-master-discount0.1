--混元伞
--战斗开始时，选择敌方当前攻击力最高的侠客，有50%的概率使其无法恢复内力x秒，若未能生效，则使其攻击力降低x%，持续X秒

---@class Relic_104 : Relic @
---@field super Relic @Relic
local M = class("Relic_104", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	--随机使其1本秘籍的效果失效x秒
	self.randomNoAnger = self:getValue(1)
	--无法恢复内力
	self.noAngerBuf = self:getValue(2)
	--该侠客未能装备秘籍，则使其攻击力降低x%buf
	self.atkBuf = self:getValue(3)
	self.enemy = nil
	self.mysticCfg = nil
	self.mysticBufConfig = nil
end


function M:gameStart()
	M.super.gameStart(self)
	local player = self.mgr.plyMgr:getPlayers(self.mgr.camp):get(0)
	if player == nil then
		return
	end
	local enemies = SelectTargetUtil:findPlayerByParam(player, {
		camp = "enemy",
		ignoreSummon = true,
		pos = "forceMax",
		--priority = true,
	})
	if enemies.Count > 0 then
		local target = enemies:get(0)
		if target and target:isLive() and target.bufMgr ~= nil then
			local randomValue = WRandom:randomNum(0, GlobalTools.base1,true)
			if randomValue <= self.randomNoAnger then
				target.bufMgr:addBufById(self.noAngerBuf, target)
			else
				target.bufMgr:addBufById(self.atkBuf, target)
			end
		end
	end


end




return M