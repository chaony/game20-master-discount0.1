--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:27:44
]]
--召唤物 Idle AI基类
---@class AIStateIdle_Summon_MoJ : AIState @
---@field super AIState @AIState
local M = class("AIStateIdle_Summon_MoJ",Battle.AIState)

M.anim_name = "battle_idle"

--进入移动状态
function M:enter()
    M.super.enter(self)
    --先将动作切换到站立
    self.player.animator:changeState(self.anim_name)
    self.player:set_curSkillConfig(nil)
end

--更新移动状态
function M:update(dt,unsdt)
    M.super.update(self,dt,unsdt)
    if self.player:get_enemy() ~= nil then
        local distance = GlobalTools:Distance(self.player.enemy.position, self.player.position )

        --我和敌人的距离小于 攻击距离
        local atkRange = self.player.data.atkRange
        if self.aiEngine.skillConfig ~= nil then
            atkRange = self.aiEngine.skillConfig:getSkillDis()
        end

        if distance < GlobalTools:ToFix2( atkRange ) then
            if self.aiEngine.skillConfig ~= nil then
                self.aiEngine:changeState("skill")
                return
            end
        end
    end
end

--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M