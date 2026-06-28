-- 流仙抚云掌, 落英神功, 太上清心诀

-- 每次释放技能判断对方身上是否有回血、防御增加、护盾、攻击增加的增益效果，如有则驱散其中三个，每场战斗触发4次

---@class Mystic_06 : Mystic
---@field super Mystic
local M = class("Mystic_06", Mystic)

function M:init(mgr, mysticCfg, mysticBufCfg)
	M.super.init(self, mgr, mysticCfg, mysticBufCfg)

	self.maxRemoveCnt = self:getParam(1, 0)	--number[] 最大移除数量
	self.maxTriggerCnt = self:getParam(2, 0)	--number[] 最大触发次数
	self.maxTargetCnt = self:getParam(3, 0)	--number[] 最大触发次数
	self.triggerInterval = self:getParam(4, 0)	--number[] 触发时间间隔
	self.debuff4 = self:getParam(5, 0)	--Buff[] debuff3

	self.curTriggerCnt = 0
	self.curTargetCnt = 0
	
	self.canTrigger = true
	self.cdTimer = nil

	self.triggerCondition = self:getConditionParam(1) or {}
	
	self.triggerBuffTags = {}
	self:initTriggerBuffTag()

	EventDispatcher:registerEvent("injure", {self, self.injureHandler})
	EventDispatcher:registerEvent("addBuff",{self,self.addBufHandler})
end

function M:initTriggerBuffTag()
	local conditions = self:getConditionParam(1)
	for i, condition in ipairs(conditions) do
		if condition[1] == "tag_extra" and condition[2] then
			self.triggerBuffTags[condition[2]] = true
		end
	end
end


---@param ply PlayerModel
---@param skill SkillDataConfig
function M:skillStart(ply, skill)
	if skill.anim_name ~= "attack1" then
		if self.curTriggerCnt < self.maxTriggerCnt and self.canTrigger then
			self.isRunning = true
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
		if self.curTargetCnt > 0then
			self:markTriggered()
		end
		
		self.curTargetCnt = 0
		self.skillTargets = {}
	end
end

function M:markTriggered()
	if self.curTargetCnt > 0then
		self.curTriggerCnt = self.curTriggerCnt + 1
		self.canTrigger = false
		if self.cdTimer then
			TimeTools:stopTask(self.cdTimer)
			self.cdTimer = nil
		end
		self.cdTimer = TimeTools:delayTime(self.triggerInterval, function()  
			self.canTrigger = true
		end)
	end
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
	if not self.isRunning then
		return
	end
	
	if self.curTargetCnt >= self.maxTargetCnt then	-- 达到最大目标数
		return
	end

	if BattleTool:isMySkillWithPlayer(self.player, eventData.attackData) then
		self:checkTrigger(eventData.victim)	
	end
	
end

function M:checkTrigger(target)
	if target:get_playerInstanceId() == nil then
		return
	end
	if self.skillTargets[target:get_playerInstanceId()] then
		return
	end
	if target.camp == self.player.camp then
		return
	end
	
	self.curTargetCnt = self.curTargetCnt + 1
	self.skillTargets[target:get_playerInstanceId()] = true

	target.bufMgr:addBufById(self.debuff4, self.player)
		
	self:removeBuff(target, self.maxRemoveCnt)		-- 每个标签触发n次
end

---@param data Battle_HandleData_AddBuff
function M:addBufHandler(eventName, data)
	if self.isRunning then
		if self.curTargetCnt >= self.maxTargetCnt then	-- 达到最大目标数
			return
		end
		
		local buff = data.buff
		if self.player:equal(buff.source) and buff.sourceSkill and buff.sourceSkill.type == 1 then
			if buff.player:isXiaKe() then
				self:checkTrigger(buff.player)		-- 所有标签触发一次
			end
		end
	end
end

---@param target PlayerModel
function M:removeBuff(target, cnt)
	local triggerTags = self.triggerBuffTags
	local buffs = target.bufMgr.bufList
	local triggerCnt = 0
	for i = buffs.Count, 1, -1 do
		---@type PlayerBuf_Model
		local buff = buffs:get(i - 1)
		if buff then
			for i, v in ipairs(buff.tagExtra) do
				if triggerTags[v] then
					triggerCnt = triggerCnt + 1
					target.bufMgr:dispelBuff(self.player, buff, true)
				end
			end
		end
		if triggerCnt >= self.maxRemoveCnt then
			break
		end
	end
end

function M:destroy()
	if self.cdTimer then
		TimeTools:stopTask(self.cdTimer)
		self.cdTimer = nil
	end
	EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
	EventDispatcher:unRegisterEvent("addBuff",{self,self.addBufHandler})
	M.super.destroy(self)
end

return M