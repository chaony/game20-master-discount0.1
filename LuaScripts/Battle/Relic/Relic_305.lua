--飞羽弓
--射手类侠客，战斗中会获得x%的攻速提升效果，持续x秒，且战斗开始x秒内的攻击会无视任何闪避效果

---@class Relic_305 : Relic @
---@field super Relic @Relic
local M = class("Relic_305", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	--战斗中会获得x点攻速提升
	self.atkSpdBuf = self:getValue(1)
	--战斗开始x秒内
	self.buffTime = self:getValue(2)
	self.hasBuff = false
	self.role_Type = 4

	EventDispatcher:registerEvent("victimBeforeAttack", {self,self.victimBeforeAttack})
end


function M:gameStart()
	M.super.gameStart(self)
	self.hasBuff = true
	local data =
	{
		["count"] = "all",
		["camp"] = "friend",
		["pos"] = "not",
		["race"] = "all",
		["roleType"] = self.role_Type,
		["area"] = "all",
	}
	local targets = self.mgr:getTargetData(data)
	if targets == nil then
		return
	end
	for i=1,targets.Count do
		local ply = targets:get(i-1)
		ply.bufMgr:addBufById(self.atkSpdBuf, ply)
	end

	TimeTools:delayTime(self.buffTime,function()
		self:removeVictimBeforeAttackEvent()
	end )
end

function M:removeVictimBeforeAttackEvent()
	if self.hasBuff then
		self.hasBuff = false
		EventDispatcher:unRegisterEvent("victimBeforeAttack", {self,self.victimBeforeAttack})
	end
end

--作为受伤者的属性临时调整
---@param eventData Battle_HandleData_VictimBeforeAttack
function M:victimBeforeAttack(eventName, eventData)
	if eventData.killer ~= nil and eventData.killer:isLive() and eventData.killer.camp == self.mgr.camp and eventData.killer.plyData.role_type == self.role_Type then
		local oldDodge = eventData.victim.data.dodge:getValue()
		eventData.victim.data.dodge:addToAddListTemp(-oldDodge)
	end
end

function M:gameover()
	self:removeVictimBeforeAttackEvent()
	M.super.gameover(self)
end
return M