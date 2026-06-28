--召唤物 行为 AI基类
---@class AIStateSpawn_Summon : AIState @
---@field super AIState @AIState
local M = class("AIStateSpawn_Summon",Battle.AIState)

M.anim_name = "jumpin1"

function M:enter()
    M.super.enter(self)
    if self.player.animator.states["jumpin1"] == nil then
        TimeTools:delayTime(GlobalTools.base0_1,function()
            if self.player.aiEngine then
                self:toNextState()
            end
        end)
        return
    else
        self.player.animator:changeState(self.anim_name)
    end
end

--更新移动状态
function M:update(dt,unsdt)
    M.super.update(self,dt,unsdt)

    if self.player ~= nil then
        local state = self.player.animator.curState
        if state ~= nil then
            --出生状态结束
            if state.running == false then
                self:toNextState()
            end
        end
    end
end

function M:toNextState()
    self.player.aiEngine:changeState("idle")
end

--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M