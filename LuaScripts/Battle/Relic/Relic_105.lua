--九霄佩
--战士类侠客，战斗开始时会获得x%的攻击和吸血效果提升，持续x秒，且战斗开始x秒内，自身受到溢出的治疗效果的x%会转化为自身护盾。

---@class Relic_105 : Relic @
---@field super Relic @Relic
local M = class("Relic_105", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	--获得x%的攻击和吸血效果提升，持续x秒    配置方式同沈嫣skill3护盾
	self.bufId = self:getValue(1)
	self.shieldBufId = self:getValue(2)
	--战斗开始x秒内
	self.buffTime = self:getValue(3)
	-- 自身受到溢出的治疗效果的x%
	self.bloodRate = self:getValue(4)
	self.hasBuff = false
	self.role_Type = 2
	EventDispatcher:registerEvent("cureOverflow", {self,self.cureOverflowHandler})
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
		ply.bufMgr:addBufById(self.bufId, ply)
	end

	TimeTools:delayTime(self.buffTime,function()
		self:removeCureOverflowEvent()
	end )
end

function M:removeCureOverflowEvent()
	if self.hasBuff then
		self.hasBuff = false
		EventDispatcher:unRegisterEvent("cureOverflow", {self,self.cureOverflowHandler})
	end
end

function M:cureOverflowHandler(eventName, eventData)
	if eventData.player ~= nil and eventData.player:isLive() and eventData.player.camp == self.mgr.camp and eventData.player.bufMgr ~= nil and eventData.player.plyData.role_type == self.role_Type then
		local buffData = table.copy(eventData.player.bufMgr.bufData[self.shieldBufId])
		if buffData then
			local guard_value = GlobalTools:Mul(eventData.overflow, self.bloodRate)
			BattleTool:addFixedShield(eventData.player, eventData.player, buffData, guard_value, nil, self.shieldBufId)
		end
	end
end

function M:gameover()
	self:removeCureOverflowEvent()
	M.super.gameover(self)
end

return M