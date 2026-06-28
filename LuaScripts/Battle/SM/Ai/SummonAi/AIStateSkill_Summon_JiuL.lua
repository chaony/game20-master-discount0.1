--召唤物 行为 AI基类
---@class AIStateSkill_Summon_JiuL : AIState @
---@field super AIState @AIState
local M = class("AIStateSkill_Summon_JiuL",Battle.AIState)

function M:enter(data)
    M.super.enter(self, data)
    ----先将动作切换
    self.player.animator:changeState(data.animName)
end

--更新移动状态
function M:update(dt,unsdt)
    M.super.update(self,dt,unsdt)
    if self.player.animator.curState ~= nil then
        if self.player.animator.curState.canChangeAnim == true then
            self.player.aiEngine:changeState("idle")
        end
    end
end

--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M