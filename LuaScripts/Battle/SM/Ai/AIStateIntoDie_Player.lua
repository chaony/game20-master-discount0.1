
--玩家player 假死，陷入死亡（不是真正死亡，可能处于假死） AI基类
---@class AIStateIntoDie_Player : AIState @
---@field super AIState @AIState
local M = class("AIStateIntoDie_Player", Battle.AIState)

M.extra_anim_name = nil
M.anim_name = "die";
-- 消失的时间点
M.disappearTime = GlobalTools.base1

--进入移动状态
function M:enter()
    M.super.enter(self)
    
    --切换死亡动作
    if self.extra_anim_name == nil then
        self.player.animator:changeState(self.anim_name)
    else
        self.player.animator:changeState(self.extra_anim_name)
        self.extra_anim_name = nil
    end

    -- 移除目标
    self.player.plyMgr:addHide(self.player)
    self.player:ShowHpBar(false)        -- 隐藏血条
end

--更新移动状态
function M:update(dt)
    M.super.update(self,dt)
    if self.disappearTime > 0 then
        self.disappearTime = self.disappearTime - dt
        if self.disappearTime <= 0 then
            self.player:hideBody(false)     -- 隐藏本体
            EventDispatcher:dipatchEvent("leave_battlefield", {player = self.player}) -- 离开战场
        end
    end
    
    --if SceneManager.curScene.plyMgr.blackScreenPlayerCamp == 0 or
    --    SceneManager.curScene.plyMgr.blackScreenPlayerCamp == self.player.camp then
    --    if self.player.position.y > self.player.positionY then
    --        local y = self.player.position.y - GlobalTools:Mul( self.fallSpeed , dt )
    --        if y <= self.player.positionY then
    --            y = self.player.positionY
    --        end
    --        self.player.position.y = y
    --    end
    --end
end

--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M