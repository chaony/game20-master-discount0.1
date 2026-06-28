local skillState = require("Battle.SM.Ai.SummonAi.AIStateSkill_Summon")
--召唤物 行为 AI基类
---@class AIStateSkill_Summon_Return : AIState @
---@field super AIState @AIState
local M = class("AIStateSkill_Summon_Return",Battle.AIState)

M.animName = nil

M.skillStart = false

function M:enter()
    M.super.enter(self)
    ----先将动作切换
    self.animName = self.player.summonData.animName
    
    local pos = self.player.master.position:Clone()
    pos.x = pos.x + self.player.summonData.offset.x
    pos.y = pos.y + self.player.summonData.offset.y
    pos.z = pos.z + self.player.summonData.offset.z
    self.player:setPos(pos, true)
    self.player:setForward(self.player.master.forward, true)
    
    --玩家移动
    self.player.animator:changeState("jumpin2")

    
    self.skillStart = false
end

--更新移动状态
function M:update(dt,unsdt)
    M.super.update(self,dt,unsdt)

    if self.skillStart == false then
        if self.player.animator.curState.canChangeAnim == true then
            self.player.animator:changeState(self.animName)
            self.skillStart = true
        end
    else
        if self.player.animator.curState.canChangeAnim == true then
            if self.player.animator.curState.canChangeAnim == true then
                self.player.aiEngine:changeState("return")
            end
        end
    end
end

--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M