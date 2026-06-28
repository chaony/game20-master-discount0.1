-- 乾坤阴阳诀
-- 为友军施加“护盾”增益时，使自身获得一个下次受到致死伤害时无敌2秒，此效果持续时间8秒，无敌效果一场战斗最多触发1次

---@class Mystic_09 : Mystic
---@field super Mystic
local M = class("Mystic_09", Mystic)

function M:init(mgr, mysticCfg, mysticBufCfg)
	M.super.init(self, mgr, mysticCfg, mysticBufCfg)
	self.wudiMarkBuff = self:getParam(1, 0)	--Buff[] 无敌标记
	self.wudiBuff = self:getParam(2, 0)	--Buff[] 无敌
	self.isTrigger = false
	EventDispatcher:registerEvent("injure", {self, self.injureHandler})
	EventDispatcher:registerEvent("addBuff",{self,self.addBufHandler})
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
	if not self.isTrigger and eventData.victim and eventData.victim:equal(self.player) then
		if self.player:isAttackCauseDeath(eventData.attackData, eventData.wantdata) and self.player.bufMgr then
			local buff = self.player.bufMgr:findBufByTag("mystic_09")
			if #buff > 0 then
				eventData.wantdata.damage = 0
				self.player.bufMgr:addBufById(self.wudiBuff, self.player)
				self.isTrigger = true
			end
		end
	end
end

---@param data Battle_HandleData_AddBuff
function M:addBufHandler(eventName, data)
	if not self.isTrigger and data.buff and data.buff.player and data.buff.player.camp == self.player.camp and not self.player:equal(data.buff.player) then
		local buff = data.buff
		if self.player:equal(buff.source) and BattleTool:isShieldBuff(buff) then
			if buff.player:isXiaKe() then
				self.player.bufMgr:addBufById(self.wudiMarkBuff, self.player)
			end
		end
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
	EventDispatcher:unRegisterEvent("addBuff",{self,self.addBufHandler})
	M.super.destroy(self)
end

return M