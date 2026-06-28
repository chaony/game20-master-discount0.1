--AI巡逻状态
---@class AIStatePatrol_Player_Fight : AIStatePatrol_Player @
---@field super AIStatePatrol_Player @AIStatePatrol_Player
local M = class("AIStatePatrol_Player_Fight",Battle.AIStatePatrol_Player)

--进入状态
function M:enter()
	M.super.enter(self)
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