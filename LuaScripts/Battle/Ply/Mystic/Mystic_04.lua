-- 一阳指, 天山折梅手, 万剑归宗

-- 大招攻击敌对目标时优先判断击中数量，如数量只有1个且血量低于30%则立刻斩杀（濒死对斩杀无效），如果血量高于30%则眩晕3秒。

---@class Mystic_04 : Mystic
---@field super Mystic
local M = class("Mystic_04", Mystic)

function M:init(mgr, mysticCfg, mysticBufCfg)
	M.super.init(self, mgr, mysticCfg, mysticBufCfg)

	self.addBuff1 = self:getParam(1, 0)	--Buff[] 眩晕buff
	self.killerHp = 0

	local conditions = self:getConditionParam(1)
	if conditions then
		for i, condition in ipairs(conditions) do
			if condition[1] == "hp" then
				self.killerHp = condition[2] or 0
			end
		end
	end
	self:getParam(2, 0)	--Fix[0-100] 斩杀血线
	
	self.isRunning = false
	self.skillTargets = {}

	EventDispatcher:registerEvent("injure", {self, self.injureHandler})
	EventDispatcher:registerEvent("addBuff",{self,self.addBufHandler})
end

---@param ply PlayerModel
---@param skill SkillDataConfig
function M:skillStart(ply, skill)
	if skill.type == 1 then	-- 必杀
		self.isRunning = true
		self.skillTargets = {}
	end
end

---@param ply PlayerModel
---@param skill SkillDataConfig
function M:skillEnd(ply, skill)
	if self.isRunning then	-- 必杀
		self.isRunning = false
		if(table.nums(self.skillTargets) == 1)then
			local id = next(self.skillTargets)
			local target = self.player.plyMgr:getPlayerByInstanceId(id)
			if target then
				if not self:triggerKiller(target) then		-- 没有触发斩杀
					target.bufMgr:addBufById(self.addBuff1, self.player)
				end	
			end
		end
		self.skillTargets = {}
	end
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
	if self.isRunning then
		if eventData.victim.camp ~= self.player.camp then
			if BattleTool:isMySkill3(self.player, eventData.attackData) then
				if eventData.attackData.injureType == "skill" then
					self.skillTargets[eventData.victim:get_playerInstanceId()] = true
				end
			end
		end
	end
end

---@param data Battle_HandleData_AddBuff
function M:addBufHandler(eventName, data)
	if self.isRunning then
		if data.buff.player.camp ~= self.player.camp then
			local buff = data.buff
			if self.player:equal(buff.source) and buff.sourceSkill and buff.sourceSkill.type == 1 then
				if buff.player:isXiaKe() then
					self.skillTargets[buff.player:get_playerInstanceId()] = true
				end
			end
		end
	end
end

---@param target PlayerModel
function M:triggerKiller(target)
	if target.isBoss then		-- boss不生效
		return false
	end
	local hpRate = target.data:get_hpRate()
	if hpRate > 0 and hpRate <= self.killerHp then
		local attackData, want_data = BattleTool:getHitDirectAttackData(self.player, target.data:get_curHp())
		attackData.ignoreGuard = false
		attackData.ignoreAvoidDeath = true
		target:beHitDirect(self.player, attackData, want_data, false)
		return true
	end
	return false
end

function M:destroy()
	EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
	EventDispatcher:unRegisterEvent("addBuff",{self,self.addBufHandler})
	M.super.destroy(self)
end

return M