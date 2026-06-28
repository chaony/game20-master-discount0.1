--造化葫芦
--坦克类侠客，战斗中会获得x%的防御和最大血量血量提升效果，持续x秒，且每次受到伤害时，会使攻击者降低x点攻速，最多叠加x次
---@class Relic_407 : Relic @
---@field super Relic @Relic
local M = class("Relic_407", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	--战斗中会获得x%的防御和最大血量血量提升效果
	self.atkDefBuf = self:getValue(1)
	--每次受到伤害时，会使攻击者降低x点攻速
	self.atkSpdBuf = self:getValue(2)
	self.role_Type = 1
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
		ply.bufMgr:addBufById(self.atkDefBuf, ply)
	end
end

function M:injureHandler(eventName, eventData)
	local victim = eventData["victim"]
	local killer = eventData["killer"]
	if victim ~= nil and victim.camp == self.mgr.camp and victim.plyData.role_type == self.role_Type and killer ~= nil and killer.bufMgr ~= nil then
		killer.bufMgr:addBufById(self.atkSpdBuf, killer)
	end

end

function M:gameover()
	EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
	M.super.gameover(self)
end

return M