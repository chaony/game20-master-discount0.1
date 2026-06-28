--当敌人释放一个治疗技能或护盾技能，我方全体都将获得一次祝福【伤害增加{x}%】，持续{y}秒，祝福效果可以叠加
---@class Relic_402 : Relic @
---@field super Relic @Relic
local M = class("Relic_402", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.bufId = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	EventDispatcher:registerEvent("addBuff",{self,self.addBuf})
end

function M:addBuf( eventName, data )
	local buff = data["buff"]
	--加血技能
	if buff ~= nil and buff.player.camp == -self.mgr.camp then
		if buff.type == "AddBlood" or buff.type == "Shield" then
			local players = self.mgr:getTarget("self", "all")
			for i=1,players.Count do
				local ply = players:get(i-1)
				ply.bufMgr:addBufById(self.bufId, ply)
				self:playEffect(ply)
			end
		end
	end
end

function M:gameover()
	EventDispatcher:unRegisterEvent("addBuff",{self,self.addBuf})
	M.super.gameover(self)
end

return M