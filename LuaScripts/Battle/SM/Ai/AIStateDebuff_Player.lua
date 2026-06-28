--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:17:14
]]
--玩家player Debuff AI基类
---@class AIStateDebuff_Player : AIState @
---@field super AIState @AIState
local M = class("AIStateDebuff_Player",Battle.AIState)

M.anim_name = "debuff1"
M.extra_anim_name = nil

--进入移动状态
function M:enter()
    M.super.enter(self)

    --先将动作切换到站立
    if self.anim_name == nil or self.anim_name == "nil" then
        self.anim_name = "hit2_flyloop"
    end

    if self.extra_anim_name == nil then
        self.player.animator:changeState(self.anim_name)
    else
        self.player.animator:changeState(self.extra_anim_name)
        self.extra_anim_name = nil
    end
end

--更新移动状态
function M:update(dt)
    M.super.update(self,dt)
    if SceneManager.curScene.plyMgr.blackScreenPlayerCamp == 0 or
            SceneManager.curScene.plyMgr.blackScreenPlayerCamp == self.player.camp then
        if self.player.bufMgr:inDebuffState() == false then
            self.player.aiEngine:changeState("idle")
        end        
    end
end

--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M