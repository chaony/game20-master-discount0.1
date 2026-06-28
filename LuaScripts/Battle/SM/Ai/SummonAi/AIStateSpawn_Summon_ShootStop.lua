--召唤物 发射后停留——返回 行为 AI基类
---@class AIStateSpawn_Summon_ShootStop : AIState @
---@field super AIState @AIState
local M = class("AIStateSpawn_Summon_ShootStop", Battle.AIState)

M.anim_name = "spawn"

function M:enter()
    M.super.enter(self)
    self.player.animator:changeState(self.anim_name)
end

--更新移动状态
function M:update(dt,unsdt)
    M.super.update(self,dt,unsdt)

    if self.player.animator.curState.canChangeAnim == true then
        self.player.aiEngine:changeState("idle")
    end
end

--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M