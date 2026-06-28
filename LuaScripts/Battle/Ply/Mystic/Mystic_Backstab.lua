--每背刺触发触发

---@class Mystic_BackStab : Mystic
---@field super Mystic
local M = class("Mystic_BackStab", Mystic)

function M:init(mgr, mysticCfg, mysticBufCfg)
	M.super.init(self, mgr, mysticCfg, mysticBufCfg)

	self.addBuff1 = self:getParam(1, 0)	--Buff[] 给自己加buff

	self.addDamage = self:getConditionData(1, "damageRaise", 0)
	self.critAddDamage = self:getConditionData(1, "critDamageRaise", 0)
	self.center = SelectTargetTool:findFixPoint(self.player, "sceneCenter")
	
	EventDispatcher:registerEvent("injure", {self, self.injureHandler})
end

---@param data Battle_HandleData_Injure
function M:injureHandler(eventName, data)
	if self.player:equal(data.killer) and self:isInEnemyField() then
		if BattleTool:isSkillInjure(data.attackData) then
			if data.attackData.isCrit then
				data.wantdata.damage = data.wantdata.damage + GlobalTools:Mul(self.critAddDamage, data.wantdata.damage)
			else
				data.wantdata.damage = data.wantdata.damage + GlobalTools:Mul(self.addDamage, data.wantdata.damage)
			end
		end
		
		--local dir = data.victim.position - self.player.position
		--if FixVector3.Dot(dir, data.victim:getForward()) > 0then
		--end
	end
end

function M:isInEnemyField()
	if self.player.camp == 1 then
		return self.player.position.x > self.center.x
	else
		return self.player.position.x < self.center.x
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
	M.super.destroy(self)
end

return M