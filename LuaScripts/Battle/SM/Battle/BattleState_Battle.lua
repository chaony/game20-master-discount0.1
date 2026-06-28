---@class BattleState_Battle : BattleState  @战斗转态
---@field super BattleState
local M = class("BattleState_Battle", Battle.BattleState)

function M:enter()
    self.curScene:playerBattleStart()
end

function M:update(dt)
	self.curScene:update(dt)
end

return M