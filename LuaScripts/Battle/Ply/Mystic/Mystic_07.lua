-- 紫霞
--释放绝技时如被命中的敌对目标被暴击，则目标内力减30，多次攻击仅计算第一次
---@class Mystic_07 : Mystic
---@field super Mystic
local M = class("Mystic_07", Mystic)

function M:init(mgr, mysticCfg, mysticBufCfg)
	M.super.init(self, mgr, mysticCfg, mysticBufCfg)
	self.buffId = self:getParam(1, 0)	--number[] 单次技能触发最大角色个数
	self.skillTargets = {}
	EventDispatcher:registerEvent("injure", {self, self.injureHandler})
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
	end
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
	if not self.isRunning then
		return
	end
	
	local victim = eventData["victim"]
	if victim:get_playerInstanceId() == nil then
		return
	end
	if self.skillTargets[victim:get_playerInstanceId()] then
		return
	end
	if BattleTool:isMySkill3(self.player, eventData.attackData) and eventData.attackData.isCrit and victim and victim.bufMgr then
		victim.bufMgr:addBufById(self.buffId, self.player)
		self.skillTargets[victim:get_playerInstanceId()] = true
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
	M.super.destroy(self)
end

return M