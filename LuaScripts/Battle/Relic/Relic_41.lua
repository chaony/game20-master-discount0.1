--兴奋药剂
--一场战斗中，己方武魂每击杀一个敌人，自身怒气恢复速度+25%可叠加
---@class Relic_41 : Relic @
---@field super Relic @Relic
local M = class("Relic_41", Relic)

--攻击怒气恢复速度
M.atkrageregen = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.atkrageregen = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)

	EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
end

function M:killerPlayerHandler(eventName, data)
    local killer = data["killer"]
    if killer ~= nil then
    	if killer.camp == 1 then
			self:dealWithData(killer, "recoveryAngerRate", 1)
			self:dealWithData(killer, "hurtrageregen", 1)
    	end
    end
end

function M:gameover() 
	M.super.gameover(self)
	EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
end

return M
