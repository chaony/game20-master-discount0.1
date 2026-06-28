--AI复活状态
---@class AIStateRelive_Player : AIState @
---@field super AIState @AIState
local M = class("AIStateRelive_Player", Battle.AIState)

M.anim_name = "idle"
M.reliveTime = GlobalTools.base0_5

--进入状态
function M:enter()
	M.super.enter(self)
	self.player:hideBody(true)
	
	--切换复活动作
	if self.extra_anim_name == nil then
		self.player.animator:changeState(self.anim_name)
	else
		self.player.animator:changeState(self.extra_anim_name)
		self.extra_anim_name = nil
	end
	self.isRelived = false
end

--更新状态
function M:update(dt)
	M.super.update(self, dt)
	if self.reliveTime > 0 then
		self.reliveTime = self.reliveTime - dt
		if self.reliveTime <= 0 then
			self.isRelived = true
			self.player:relived()
			self.player:ShowHpBar(true)
			self.player.aiEngine:changeState("patrol")
		end
	end
end


--退出当前状态
function M:exit()
	M.super.exit(self)
end

return M