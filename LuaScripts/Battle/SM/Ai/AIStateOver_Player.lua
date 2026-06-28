--AI巡逻状态
---@class AIStateOver_Player : AIState @
---@field super AIState @AIState
local M = class("AIStateOver_Player",Battle.AIState)

M.anim_name = "win"

M.dir = nil

M.speed = 8

--进入状态
function M:enter(data)
	M.super.enter(self)
	--动作切换
	self.anim_name = "win"
	if self.player.camp == 1 and data.re == 0 then
		self.anim_name = "lose"
	elseif self.player.camp == -1 and data.re == 1 then
		self.anim_name = "lose"
	end
	self.player.animator:changeState(self.anim_name)
end

--更新状态
function M:update(dt)
	M.super.update(self,dt)
end

--退出当前状态
function M:exit()
	M.super.exit(self)
end

return M