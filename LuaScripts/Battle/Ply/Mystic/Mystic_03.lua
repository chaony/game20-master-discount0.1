-- 天女散花，三花聚顶，太乙五行神功

--大招在释放结束后，开始结算，判断击中目标的数量，每击中一个目标，获得自身生命上限15%的护盾、血量恢复15%并恢复5点内力，护盾最多吸收自身血量75%的伤害，
--血量最多恢复75%，恢复25点内，护盾持续时间8秒

---@class Mystic_03 : Mystic
---@field super Mystic
local M = class("Mystic_03", Mystic)

function M:init(mgr, mysticCfg, mysticBufCfg)
	M.super.init(self, mgr, mysticCfg, mysticBufCfg)
	
	self.addBuff1 = self:getParam(1, 0)	--Buff[] 给自己加buff
	self.addMaxNum = self:getParam(2, 0)	--int[] 最多加几个

	self.isRunning = false
	self.skillTargets = {}
	
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
		local nums = Mathf.Min(self.addMaxNum, table.nums(self.skillTargets))
		for i = 1, nums do
			self.player.bufMgr:addBufById(self.addBuff1, self.player)
		end
		self.isRunning = false
		self.skillTargets = {}
	end
end

-- 攻击结束时
---@param victim PlayerModel
---@param killer PlayerModel
---@param wantdata Battle_BeHitDirectData_WantData
-----@param attackData Battle_AttackData
function M:attackOver(victim, killer, wantdata, attackData)
	if self.isRunning and self.player:equal(killer) and attackData.skillConfig and attackData.skillConfig.type == 1 then	-- 大招
		self.skillTargets[victim:get_playerInstanceId()] = true
	end
end

---@param data Battle_HandleData_AddBuff
function M:addBufHandler(eventName, data)
	if self.isRunning and data.buff then
		local buff = data.buff
		if self.player:equal(buff.source) and buff.sourceSkill and buff.sourceSkill.type == 1 then
			if buff.player:isXiaKe() and BattleTool:isCureShieldOrBuff(buff) then
				self.skillTargets[buff.player:get_playerInstanceId()] = true
			end
		end
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent("addBuff",{self,self.addBufHandler})
	M.super.destroy(self)
end 

return M