--召唤物 行为 AI基类
---@class AIStateDie_Summon_MoJ : AIState @
---@field super AIState @AIState
local M = class("AIStateDie_Summon_MoJ",Battle.AIState)

M.startPos = nil

M.target = nil 

M.targetDist = nil

M.animName = "die"

M.skillStart = false

function M:enter()
    M.super.enter(self)
    ----先将动作切换
    self.player.animator:changeState(self.animName)
    
    self.skillStart = false
end

--更新移动状态
function M:update(dt,unsdt)
    M.super.update(self,dt,unsdt)
end

--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M