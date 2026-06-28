--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:17:14
]]
--玩家player Debuff AI基类
---@class AIStateDie_Player : AIState @
---@field super AIState @AIState
local M = class("AIStateDie_Player",Battle.AIState)

M.extra_anim_name = nil

M.destory = false
--进入移动状态
function M:enter()
    M.super.enter(self)
    self.anim_name = "die";
    --先将动作切换到站立
    if self.extra_anim_name == nil then
        if self.player.animator then
            self.player.animator:changeState(self.anim_name)
        end
    else
        self.player.animator:changeState(self.extra_anim_name)
        self.extra_anim_name = nil
    end
    self.destory = false
    self.fallSpeed = GlobalTools.base10;
    --Logger.logError(self.player.plyType.." 切换到死亡状态  ~~~~~~~~~~~~~~~ ")
end

--更新移动状态
function M:update(dt)
    M.super.update(self,dt)
    if SceneManager.curScene.plyMgr.blackScreenPlayerCamp == 0 or
        SceneManager.curScene.plyMgr.blackScreenPlayerCamp == self.player.camp then
        if self.player.position.y > self.player.positionY then
            local y = self.player.position.y - GlobalTools:Mul( self.fallSpeed , dt )
            if y <= self.player.positionY then
                y = self.player.positionY
            end
            self.player.position.y = y
        end
    end
    
    if self.player.animator.curState ~= nil then
        if self.destory == false and self.player.animator.curState.running == false then
            self.destory = true
            --延迟销毁
            self.player.delayDestoryTask = TimeTools:delayTime(GlobalTools.base0_5,function()
                self.player:destroy()
            end)
        end
    else
        if self.destory == false then
            self.destory = true
            --延迟销毁
            self.player.delayDestoryTask = TimeTools:delayTime(GlobalTools.base1_5,function()
                self.player:destroy()
            end)
        end
    end
end

--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M