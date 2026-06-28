--苍龙剪
--刺客类侠客，战斗中会获得x点暴击和暴伤提升，持续x秒，战斗开始x秒内，自身每次造成暴击伤害时，还会额外附加自身攻击力x%的真实伤害
---@class Relic_205 : Relic @
---@field super Relic @Relic
local M = class("Relic_205", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	--获得x点暴击和暴伤提升
	self.critBuf = self:getValue(1)
	--战斗开始x秒内
	self.buffTime = self:getValue(2)
	--额外附加自身攻击力x%的真实伤害
	self.trueInjurePercent = self:getValue(3)
	self.hasBuff = false
	self.role_Type = 3
	EventDispatcher:registerEvent("injure", {self,self.injureHandler})
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
		ply.bufMgr:addBufById(self.critBuf, ply)
	end

	TimeTools:delayTime(self.buffTime,function()
		self:removeInjureEvent()
	end )
end

function M:removeInjureEvent()
	if self.hasBuff then
		self.hasBuff = false
		EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
	end
end

function M:injureHandler(eventName, eventData)
	local killer = eventData.killer
	if killer ~= nil and killer.camp == self.mgr.camp and killer.plyData.role_type == self.role_Type and eventData["attackData"]["isCrit"] == true then
		local damage = GlobalTools:Mul(self.trueInjurePercent, killer.data.atk:getValue())
		eventData.victim:beHitRealDamage(damage, killer, eventData["skillConfig"])
	end
end



function M:gameover()
	self:removeInjureEvent()
	M.super.gameover(self)
end
return M