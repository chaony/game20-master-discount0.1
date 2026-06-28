-- 玉女心经，素女功，达摩气功

--如大招是护盾、恢复等祝福类技能，则额外给被治疗的随机两个目标提高50%防御力，增加抗暴击值40、坚韧值提高100，持续时间8秒

---@class Mystic_02 : Mystic
---@field super Mystic
local M = class("Mystic_02", Mystic)

function M:init(mgr, mysticCfg, mysticBufCfg)
	M.super.init(self, mgr, mysticCfg, mysticBufCfg)

	self.addBuff1 = self:getParam(1, 0)	--Buff[] 给目标加buff
	self.addBuffCnt = self:getParam(2, 0)	--int[] 给几个目标加buff

	self.isRunning = false
	self.addBuffPlayers = {}
	EventDispatcher:registerEvent("addBuff",{self,self.addBufHandler})
end

---@param ply PlayerModel
---@param skill SkillDataConfig
function M:skillStart(ply, skill)
	if skill.type == 1 then	-- 必杀
		self.isRunning = true
		self.addBuffPlayers = {}
	end
end

---@param ply PlayerModel
---@param skill SkillDataConfig
function M:skillEnd(ply, skill)
	if self.isRunning then
		if #self.addBuffPlayers <= self.addBuffCnt then
			for i, v in ipairs(self.addBuffPlayers) do
				self:addBuffTo(v)
			end
		else
			for i = 1, self.addBuffCnt do
				local index = WRandom:randomNum(1, #self.addBuffPlayers, true)
				local pid = table.remove(self.addBuffPlayers, index)
				self:addBuffTo(pid)
			end
		end

		self.player.plyMgr:getPlayerByInstanceId()

		-- 重置记录
		self.isRunning = false
		self.addBuffPlayers = {}
	end
end

-- 给目标添加buff
function M:addBuffTo(pid)
	local player = self.player.plyMgr:getPlayerByInstanceId(pid)
	if player then
		player.bufMgr:addBufById(self.addBuff1, self.player)
	end
end

---@param data Battle_HandleData_AddBuff
function M:addBufHandler(eventName, data)
	if self.isRunning and data.buff then
		local buff = data.buff
		if self.player:equal(buff.source) and buff.sourceSkill and buff.sourceSkill.type == 1 then
			if buff.player:isXiaKe() and BattleTool:isCureShieldOrBuff(buff) then
				local pid = buff.player:get_playerInstanceId()
				if table.indexof(self.addBuffPlayers, pid) == false then
					table.insert(self.addBuffPlayers, pid)
				end
			end			
		end
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent("addBuff",{self,self.addBufHandler})
	M.super.destroy(self)
end

return M