-- 沾衣十八跌,焦热荒经,阿鼻无间心经

-- 每次大招判断对方身上是否有流血的负面效果，则流血负面效果伤害立刻触发，每场战斗触发2次（不清除负面效果只是多爆发一次伤害）

---@class Mystic_05 : Mystic
---@field super Mystic
local M = class("Mystic_05", Mystic)

function M:init(mgr, mysticCfg, mysticBufCfg)
	M.super.init(self, mgr, mysticCfg, mysticBufCfg)

	self.maxTriggerCnt = self:getParam(1, 0)	--number[] 技能触发最大次数
	self.maxTargetCnt = self:getParam(2, 0)	--number[] 单次技能触发最大角色个数
	self.maxBuffCnt = self:getParam(3, 0)	--number[] 单个目标多少次
	self.addDamage = self:getConditionData(1, "damageRaise", 0)	-- Fix[] 增伤

	self.triggerBuffTags = {}
	self:addTriggerBuffTag()

	self.curTriggerCnt = 0
	self.curTargetCnt = 0
	self.skillTargets = {}
	EventDispatcher:registerEvent("injure", {self, self.injureHandler})
	EventDispatcher:registerEvent("addBuff",{self,self.addBufHandler})
end

---@param ply PlayerModel
---@param skill SkillDataConfig
function M:skillStart(ply, skill)
	if skill.type == 1 then	-- 必杀
		if self.curTriggerCnt < self.maxTriggerCnt then
			self.isRunning = true
			self.curTriggerCnt = self.curTriggerCnt + 1
			self.curTargetCnt = 0
			self.skillTargets = {}
		end
	end
end

---@param ply PlayerModel
---@param skill SkillDataConfig
function M:skillEnd(ply, skill)
	if self.isRunning then	-- 必杀
		self.isRunning = false
		self.skillTargets = {}
	end
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
	if not self.isRunning then
		return
	end

	if eventData.attackData and eventData.attackData.sourceBuff then
		if eventData.attackData.sourceBuff:haveTriggerTag("Mystic_05_ForceTrigger") then
			eventData.wantdata.damage = eventData.wantdata.damage + GlobalTools:Mul(eventData.wantdata.damage, self.addDamage)
		end
	end

	if self.curTargetCnt >= self.maxTargetCnt then
		return
	end
	
	if BattleTool:isMySkill3(self.player, eventData.attackData) then
		self:forceTriggerBuffByTag(eventData.victim)		-- 所有标签触发一次
	end
end

---@param data Battle_HandleData_AddBuff
function M:addBufHandler(eventName, data)
	if self.isRunning then
		if self.curTargetCnt >= self.maxTargetCnt then
			return
		end
		
		if data.buff.player.camp ~= self.player.camp then
			local buff = data.buff
			if self.player:equal(buff.source) and buff.sourceSkill and buff.sourceSkill.type == 1 then
				if buff.player:isXiaKe() then
					self:forceTriggerBuffByTag(buff.player)		-- 所有标签触发一次
				end
			end
		end
	end
end

---@param target PlayerModel
function M:forceTriggerBuffByTag(target)
	if target:get_playerInstanceId() == nil then
		return
	end
	if self.skillTargets[target:get_playerInstanceId()] then
		return
	end
	
	local triggerTags = self.triggerBuffTags
	local buffs = target.bufMgr.bufList
	local triggerCnt = 0
	for i = buffs.Count, 1, -1 do
		---@type PlayerBuf_Model
		local buff = buffs:get(i - 1)
		if buff then
			for i, v in ipairs(buff.tag) do
				if triggerTags[v] then
					if self:triggerOneBuff(buff) then
						triggerCnt = triggerCnt + 1
					end
					break
				end
			end
		end
		if triggerCnt >= self.maxBuffCnt then
			break
		end
	end
	
	if triggerCnt > 0 then
		self.curTargetCnt = self.curTargetCnt + 1
	end
end

---@param buff PlayerBuf_Model
function M:triggerOneBuff(oneBleed)
	---@type PlayerBuf_Model
	local triggerBuf = nil
	if oneBleed.bufWork.forceTriggerOnce then	-- 不能触发的buff
		triggerBuf = oneBleed
	else
		if oneBleed.parasiticBuffList then
			for i, buff in ipairs(oneBleed.parasiticBuffList) do
				if buff.bufWork.forceTriggerOnce then
					triggerBuf = buff
					break
				end
			end
		end
	end
	if triggerBuf then
		self.skillTargets[triggerBuf.player:get_playerInstanceId()] = true
		triggerBuf:addTriggerTag("Mystic_05_ForceTrigger")
		triggerBuf.bufWork:forceTriggerOnce()	-- 强制触发一次
		triggerBuf:removeTriggerTag("Mystic_05_ForceTrigger")
		triggerBuf.player.bufMgr:addBufById(self.addBuff2, self.player)
		return true
	end
	return false
end

function M:addTriggerBuffTag()
	local conditions = self:getConditionParam(1)
	for i, condition in ipairs(conditions) do
		if condition[1] == "tag" and condition[2] then
			self.triggerBuffTags[condition[2]] = true
		end
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent("addBuff",{self,self.addBufHandler})
	EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
	M.super.destroy(self)
end

return M