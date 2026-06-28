--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:27:44
]]
--墨家召唤物 复活
---@class AIStateReSpawn_Summon_MoJ : AIState @
---@field super AIState @AIState
local M = class("AIStateReSpawn_Summon_MoJ",Battle.AIState)

M.anim_name = "skill3"

--进入移动状态
function M:enter()
    M.super.enter(self)
    --先将动作切换到站立
    self.player.animator:changeState(self.anim_name)
end

--更新移动状态
function M:update(dt,unsdt)
    M.super.update(self,dt,unsdt)
    if self.player.animator.curState.canChangeAnim == true then
        self.player.aiEngine:changeState("idle")
    end
end

--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M