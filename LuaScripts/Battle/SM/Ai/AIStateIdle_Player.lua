--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:27:44
]]
--玩家player Idle AI基类
---@class AIStateIdle_Player : AIState @
---@field super AIState @AIState
local M = class("AIStateIdle_Player",Battle.AIState)

M.anim_name = "idle"
M.extra_anim_name = nil
M.skillConfig = nil

--进入移动状态
function M:enter()
    M.super.enter(self)
    --先将动作切换到站立
    if self.extra_anim_name == nil then
        if self.player.plyInBattle then
            self.anim_name = "battle_idle";
            --Logger.logError(" 切换动画 "..self.anim_name );
            self.player.animator:changeState(self.anim_name)
        else
            self.anim_name = "idle";
            --Logger.logError(" 切换动画 "..self.anim_name );
            self.player.animator:changeState(self.anim_name)
        end 
    else
        self.player.animator:changeState(self.extra_anim_name)
        self.extra_anim_name = nil
    end
    --Logger.logError( self.player.plyType.." 进入到 站立状态 ")
end

--更新移动状态
function M:update(dt,unsdt)
    M.super.update(self,dt,unsdt)
    if SceneManager:getCurSceneModel():get_sceneState() == SceneManager.SceneState.SceneRunning
            and SceneManager.curScene.plyMgr.openingSkillFinish == true then
        if SceneManager.curScene.plyMgr.blackScreenPlayerCamp == 0 or
                SceneManager.curScene.plyMgr.blackScreenPlayerCamp == self.player.camp then
            if self.player ~= nil and self.player:isLive() then
                self:handlerEnemy(dt,unsdt)
            end
        else
            self.player.aiEngine:changeState("patrol")
        end
    end
end


function M:handlerEnemy(dt,unsdt)
    --找到敌人了
    if self.player:get_enemy() ~= nil then
        self:hasEnemy(dt,unsdt)
    else
        if SceneManager.curScene.plyMgr.getPetMgr then
            local petMgr = SceneManager.curScene.plyMgr:getPetMgr(-self.player:get_camp())
            if self.player.playerType == "pet" and (petMgr.curPet == nil or petMgr.curPet:isDead()) then -- 一方没有宠物或者宠物已死亡时也要放技能
                self:hasPetEnemy(dt,unsdt)
            else
                self:noEnemy(dt,unsdt)
            end
        else
            self:noEnemy(dt,unsdt)
        end
    end
end


function M:noEnemy(dt,unsdt)
    if self.player.followTarget ~= nil then
        --敌人和我的距离
        local distance_enemy = GlobalTools:Distance(self.player.followTarget.position, self.player.position )
        if distance_enemy > GlobalTools:ToFix2( GlobalTools.base1_5 ) then
            self.player.aiEngine:changeState("move")
        end
    else
        self.player.aiEngine:changeState("patrol")
    end
end


--检测我和敌人
function M:hasEnemy(dt,unsdt)
    --我和敌人之间的距离
    local distance = GlobalTools:Distance(self.player.position, self.player.enemy.position)
    --我和敌人的距离小于 攻击距离
    local atkRange = self.player.data.atkRange
    if self.aiEngine.skillConfig ~= nil then
        atkRange = self.aiEngine.skillConfig:getSkillDis()
    end
    
    if distance < GlobalTools:ToFix2( atkRange ) then
        if self.aiEngine.skillConfig ~= nil then
            if self.aiEngine.skillConfig.type == 1 then
                self.player.aiEngine:changeState("skill")
            else
                self.player.aiEngine:changeState("attack")
            end
        end
    elseif self.player.data:getSpd() > GlobalTools.base0 then
        self.player.aiEngine:changeState("move")
    end
end

--检测宠物idle时释放技能
function M:hasPetEnemy(dt,unsdt)
    if self.aiEngine.skillConfig ~= nil then
        if self.aiEngine.skillConfig.anim_name ~= "xiezhanattack1" and self.aiEngine.skillConfig.anim_name ~= "xiezhanattack1_2" then
            self.player.aiEngine:changeState("attack")
        end
    end
end


--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M