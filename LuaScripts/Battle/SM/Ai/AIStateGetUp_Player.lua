--玩家player InjureMove AI基类
---@class AIStateGetUp_Player : AIState @
---@field super AIState @AIState
local M = class("AIStateGetUp_Player",Battle.AIState)

M.anim_name = "hit3"
M.extra_anim_name = nil

M.curTime = 1

--进入移动状态
function M:enter()
    M.super.enter(self)

    if self.extra_anim_name == nil then
        self.player.animator:changeState(self.anim_name)
    else
        self.player.animator:changeState(self.extra_anim_name)
        self.extra_anim_name = nil
    end
end
M.demo = false
--更新移动状态
function M:update(dt,unsdt)
    M.super.update(self,dt,unsdt)

    if SceneManager.curScene.plyMgr.blackScreenPlayerCamp == 0 or
            SceneManager.curScene.plyMgr.blackScreenPlayerCamp == self.player.camp then
        if self.curTime > 0 then
            self.curTime = self.curTime - dt
            if self.curTime <= 0 then
                self.curTime = 0  
            end
        else
            if self.player:get_enemy() ~= nil then
                self.player:lockEnemy(nil)
            end
    
            local imprison = self.player.bufMgr:findBufByType("Imprison")
            if table.nums(imprison) > 0 then
                self.player.aiEngine:changeState("debuff")
            else
                self.player.aiEngine:changeState("move")
            end
        end
    end
end


--退出当前状态
function M:exit()
    M.super.exit(self)
    self.curTime = 1
end

return M