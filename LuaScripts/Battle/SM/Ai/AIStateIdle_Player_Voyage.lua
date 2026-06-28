--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:27:44
]]
--玩家player Idle 追捕
local AIStateIdle_Player = require("Battle.SM.Ai.AIStateIdle_Player")
---@class AIStateIdle_Player_Voyage : AIStateIdle_Player @
---@field super AIStateIdle_Player @AIStateIdle_Player
local M = class("AIStateIdle_Player_Voyage",AIStateIdle_Player)

--进入状态
function M:enter()
    M.super.enter(self)
    self.minDistance = GlobalTools:ToFix2( GlobalTools.base5 )
end

function M:handlerEnemy(dt,unsdt)
    --找到敌人了
    if self.player:get_enemy() ~= nil and self.player:get_enemy():isLive() then
        self:hasEnemy(dt,unsdt)
    else
        self:noEnemy(dt,unsdt)
    end
end

function M:noEnemy(dt,unsdt)
    if self.player:get_camp() == 1 then
        local can_start = self.player.plyMgr.scene.guide:getCanStartFlag()
        if not can_start then
            local point = self.player.plyMgr.scene.guide:getPoint(self.player.index)
            --我和要追的点的距离
            local distance = GlobalTools:Distance(point, self.player.position)
            if distance > self.minDistance  then
                self.player.aiEngine:changeState("move")
            end
        end
    else
        self.player.aiEngine:changeState("move")
    end
end

--检测我和敌人
function M:hasEnemy(dt,unsdt)
    --我和敌人之间的距离
    local distance = GlobalTools:Distance(self.player.position, self.player.enemy.position)
    --我和敌人的距离小于 攻击距离
    local atkRange = GlobalTools.base1
    
    if distance < GlobalTools:ToFix2( atkRange ) then
        if self.player:get_camp() ~= 1 then
            self:playEffect(self.player)
            self.player:realDead()
        end
    else
        self.player.aiEngine:changeState("move")
    end
end


function M:playEffect( player )
    local effectData = {}

    effectData["prefab"] = "Skill_DaoShuaiMiGong_hit"
    effectData["autodestoryTime"] = 3
    effectData["isPutUpInParent"] = true
    effectData["parent"] = "Root";

    local prefabTrans = {}
    prefabTrans["useUserSet"] = true

    prefabTrans["position"] = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
    }
    prefabTrans["rotation"] = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
    }
    prefabTrans["scale"] = {
        [1] = 1,
        [2] = 1,
        [3] = 1,
    }
    effectData["prefabTrans"] = prefabTrans
    player:playEffect(effectData, player, player);
end


return M