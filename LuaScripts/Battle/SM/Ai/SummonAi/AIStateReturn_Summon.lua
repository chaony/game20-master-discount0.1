
--召唤物 Return回收 AI基类
---@class AIStateReturn_Summon : AIState @
---@field super AIState @AIState
local M = class("AIStateReturn_Summon",Battle.AIState)

M.anim_name = "run"

M.distance = 20

--进入移动状态
function M:enter()
    M.super.enter(self)
    --先将动作切换到站立
    self.player.animator:changeState(self.anim_name)
    self.startPos = FixVector3.New(0,0,0)
    self.startPos.x = self.player.position.x
    self.startPos.y = self.player.position.y
    self.startPos.z = self.player.position.z
    self.stop = false
end

--更新移动状态
function M:update(dt,unsdt)
    M.super.update(self,dt,unsdt)

    if self.stop == false and GlobalTools:Distance(self.startPos, self.player.position) <= GlobalTools:ToFix2(self.distance) then
        local dir = nil
        if self.player:getForward().x > 0 then
            dir =  FixVector3._New(10000, 0,0)
        else
            dir =  FixVector3._New(-10000, 0,0)
        end
        --玩家移动
        self.player:move_no_coillder(dir,dt)
        self.player:rotaTo(dir, dt)
    else
        self.stop = true
    end 
end

--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M