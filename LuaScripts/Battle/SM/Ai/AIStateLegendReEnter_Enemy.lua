---@class AIStateLegendReEnter_Enemy : AIState @
---@field super AIState @AIState
local M = class("AIStateIntoDie_Player", Battle.AIState)

M.reliveTime = GlobalTools.base0_0_1

--进入状态
function M:enter()
	M.super.enter(self)
	local player = self.player
	player:hideBody(true)
	self.isRelived = true
	player:relived()
	player.data:set_curHp(self.player.data:get_hp())
	--player:ShowHpBar(true)
	player.aiEngine:changeState("legendSpawn", {spawnDist = GlobalTools.base5})
end

return M