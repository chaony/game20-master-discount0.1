--飞雪刀会攻击全部带破绽的人一次，并返回当前血量百分比最少的目标强迫其与自己“决斗”8秒钟，决斗持续期间，飞雪刀的攻击力提高30%，且收到的来自决斗角色以外的伤害会减少90%
---@class W_GuanZFXD_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field skill1 W_GuanZFXD_skill1_1_Model
local M = class("W_GuanZFXD_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hitLostRate = self:getParam(1) -- 决斗期间受到到的来自决斗角色以外的伤害会减少90%
    self.battleBuffData = self:getParam(2) -- 决斗buff
    self.buffData = self:getParam(3) -- 击杀决斗对象后附加的BUFF eventData.killer
    self.pozhanBuff = self:getParam(4) -- 破绽buff
    self.enemyPlayer = nil
    self.skill1 = nil
    
end
function M:spawnFinish()
    M.super.spawnFinish(self)
    local skill = self.player.plySkill:getSkillByName("skill1") -- 技能1可能未解锁
    if skill ~= nil then
        self.skill1 = skill.cur_skill_config
    end
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("PlayerDead", {self,self.PlayerDeadHandler})
end
--更新
function M:update(dt,unsdt)
    M.super.update(self, dt,unsdt)
    if self.enemyPlayer ~= nil then
        if self.enemyPlayer:isLive() ~= true then
            self.enemyPlayer = nil
        end
        if self.enemyPlayer ~= nil and self.enemyPlayer:equal(self.player.enemy) == false then
            self.player:lockEnemy(self.enemyPlayer)
        end
    end
end

--当前技能释放
function M:skillStart(data)
    M.super.skillStart(self)

    -- 找到决斗的人
    local enemys = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
    local hpRate = 100000
    local selEnemy = nil
    for i = 1, enemys.Count do
        local enemy = enemys:get(i - 1)
        if enemy.data:get_hpRate() < hpRate then
            hpRate = enemy.data:get_hpRate()
            selEnemy = enemy
        end
    end
    self.enemyPlayer = selEnemy
    if self.enemyPlayer ~= nil then
        if self.enemyPlayer:isLive() ~= true then
            self.enemyPlayer = nil
        end
        if self.enemyPlayer ~= nil then
            if self.enemyPlayer:equal(self.player.enemy) == false then
                self.player:lockEnemy(self.enemyPlayer)
            end
            self.enemyPlayer.bufMgr:addBufById(self.battleBuffData, self.player)
            self.enemyPlayer.bufMgr:addBufById(self.pozhanBuff, self.player)
        end
    end

    if self.skill1 then -- 技能1可能未解锁
        local enemys = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
        for i = 1, enemys.Count do
            local enemy = enemys:get(i - 1)
            if enemy and enemy:isLive() then
                self.skill1.feature:checkPoZhanBuffBySkill3(enemy)
            end
        end
    end
end

---@param eventData Battle_BeHitDirectData
function M:injureHandler(eventName, eventData)
    if self.player:equal(eventData.victim) then  --受击者是自己
        local buffs = eventData.killer.bufMgr:findBufByTag("W_GuanZFXD_skill3")
        if #buffs == 0 then
            eventData.wantdata.damage = GlobalTools:Mul(eventData.wantdata.damage, self.hitLostRate)
        end
    end
end

--死亡回调
function M:PlayerDeadHandler( eventName, data )
    local player = data["data"]
    if self.enemyPlayer and player ~= nil and player:equal(self.enemyPlayer) then -- 死的人是不是锁定的敌人
        self.player.bufMgr:addBufById(self.buffData, self.player)
        self.enemyPlayer = nil
    end
end

---@param data Battle_EventData_Dispatch
function M:skillDispatch(data)
    if data.eventName == "poz" then
        --local targets = SelectTargetUtil:findPlayerByParam(self.player, {camp = "enemy"})
        --targets:safeWalkInverted(function(ply)
        --    if ply.bufMgr:hasBufByTag("x") then
        --        ply.bufMgr:removeBufByTag()
        --        ply.bufMgr:addBufByData()
        --        local buffCfg = xxx
        --        
        --    end
        --end)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.PlayerDeadHandler})
    M.super.destroy(self)
end

return M