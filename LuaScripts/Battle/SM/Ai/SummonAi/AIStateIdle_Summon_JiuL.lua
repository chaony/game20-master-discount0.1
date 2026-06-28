--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:27:44
]]
--召唤物 Idle AI基类
---@class AIStateIdle_Summon_JiuL : AIState @
---@field super AIState @AIState
local M = class("AIStateIdle_Summon_JiuL",Battle.AIState)

M.anim_name = "battle_idle"

--进入移动状态
function M:enter()
    M.super.enter(self)
    --先将动作切换到站立
    self.player.animator:changeState(self.anim_name)
    self.player:set_curSkillConfig(nil)
    self.offsetPos = FixVector3.New(0,0,0);
    self.offsetPos.x = self.player.summonData.offset.x;
    self.offsetPos.y = self.player.summonData.offset.y;
    self.offsetPos.z = self.player.summonData.offset.z;
end

--更新移动状态
function M:update(dt,unsdt)
    M.super.update(self,dt,unsdt)
    if self.player.summonData.follow == true then
        local x = self.player.summonData.offset.x
        if self.player.master ~= nil and self.player.master:getForward().x < 0  then
            x = GlobalTools:Mul( x, -GlobalTools.base1 )
            self.offsetPos.x = x;
        end

        local targetPos = self.player.master.position + self.offsetPos;
        local dist = GlobalTools:Distance(self.player.position, targetPos)
        if dist <= GlobalTools:ToFix2( GlobalTools.base0_5 ) then
            self.player:rotaTo(self.player.master.forward , dt);
        else
            self.player.aiEngine:changeState("move")
        end
    end
end

--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M