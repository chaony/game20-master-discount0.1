--七宝莲灯
--辅助类侠客，战斗中会获得x点攻速提升，持续x秒，且战斗开始后受到的前x次伤害会强制变为1点
---@class Relic_304 : Relic @
---@field super Relic @Relic
local M = class("Relic_304", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	--战斗中会获得x点攻速提升
	self.atkSpdBuf = self:getValue(1)
	--前x次伤害会强制变为1点
	self.buffTime = self:getValue(2)
	self.buffCount = 0
	self.role_Type = 5

	EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:gameStart()
	M.super.gameStart(self)
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

end

function M:removeInjureEvent()
	EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end

function M:injureHandler(eventName, eventData)
	local victim = eventData["victim"]
	if victim ~= nil and victim.camp == self.mgr.camp and victim.plyData.role_type == self.role_Type  then
		eventData.wantdata.damage = GlobalTools.base1
		self.buffCount = self.buffCount + 1
	end
	if self.buffCount >= self.buffTime then
		self:removeInjureEvent()
	end
end

function M:gameover()
	self:removeInjureEvent()
	M.super.gameover(self)
end

return M