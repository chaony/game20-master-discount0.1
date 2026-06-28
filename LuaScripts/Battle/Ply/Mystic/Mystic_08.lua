-- 天鉴神功

-- 释放绝技后2秒时间内如被敌方攻击则为自身回血，每被攻击一下恢复10%，最多恢复50%

---@class Mystic_08 : Mystic
---@field super Mystic
local M = class("Mystic_08", Mystic)

function M:init(mgr, mysticCfg, mysticBufCfg)
	M.super.init(self, mgr, mysticCfg, mysticBufCfg)

	self.maxTriggerTime = self:getParam(1, 0)	--number[] 技能触发时长
	self.buffId = self:getParam(2, 0)	--number[] 单次回血buff
	self.maxBuffCnt = self:getParam(3, 0)	--number[] 最大恢复次数
	if self.maxTriggerTime > 0 and self.maxTriggerTime < GlobalTools.base1 then
		self.maxTriggerTime = GlobalTools:ToFix(self.maxTriggerTime)
	end
	self.curTriggerCnt = 0
	EventDispatcher:registerEvent("injure", {self, self.injureHandler})
end

---@param ply PlayerModel
---@param skill SkillDataConfig
function M:skillEnd(ply, skill)
	if skill.type == 1 then	-- 必杀
		if self.maxTriggerTime > 0 then
			self.isRunning = true
			self.curTriggerCnt = 0
			TimeTools:delayTime(self.maxTriggerTime,function()
				self.isRunning = false
			end)
		end
	end
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
	if not self.isRunning then
		return
	end

	if self.curTriggerCnt >= self.maxBuffCnt then
		return
	end
	local victim = eventData["victim"]
	if self.player:equal(victim) and self.player.bufMgr then
		self.curTriggerCnt = self.curTriggerCnt + 1
		self.player.bufMgr:addBufById(self.buffId, self.player)
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
	M.super.destroy(self)
end

return M