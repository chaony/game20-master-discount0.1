--召唤物 行为 AI基类
---@class AIStateSkill_Summon : AIState @
---@field super AIState @AIState
local M = class("AIStateSkill_Summon",Battle.AIState)

M.startPos = nil

M.target = nil 

M.targetDist = nil

M.animName = nil

M.skillStart = false

function M:enter()
    M.super.enter(self)
    ----先将动作切换
    self.startPos = FixVector3.New(0,0,0)
    self.startPos.x = self.player.position.x
    self.startPos.y = self.player.position.y
    self.startPos.z = self.player.position.z

    self.target = self.player.summonData.target
    self.targetDist = self.player.summonData.targetDist
    self.animName = self.player.summonData.animName

    local dist = GlobalTools:Distance(self.player.position, self.target.position)

    if dist > GlobalTools:ToFix2( self.targetDist ) then
        --玩家移动
        self.player.animator:changeState("run")
    end
    
    self.skillStart = false
end

--更新移动状态
function M:update(dt,unsdt)
    M.super.update(self,dt,unsdt)
    if self.skillStart then
        if self.player.animator.curState.canChangeAnim == true then
            self.player.aiEngine:changeState("idle")
        end
    else
        local dist = GlobalTools:Distance(self.player.position, self.target.position)
        local dir = GlobalTools:Dir(self.target.position, self.player.position)
        if dist <= GlobalTools:ToFix2( self.targetDist ) then
            self.player:rotaTo(dir, dt);
            self.player.animator:changeState(self.animName)
            self.skillStart = true
        else
            --玩家移动
            self.player:move_no_coillder(dir,dt)
            self.player:rotaTo(dir, dt)
        end
    end
end

--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M