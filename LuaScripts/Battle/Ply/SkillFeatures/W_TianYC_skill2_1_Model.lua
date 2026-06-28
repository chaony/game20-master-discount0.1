--开场时，天墉城召唤剑阵锁定敌方攻击力最高的侠客，使其对天墉城的伤害降低16%，并提高16%天墉城对目标的伤害。
-- 3级 当被锁定侠客未被击败时，天墉城获得额外8%的伤害减免 4级 当被锁定的侠客被击败，天墉城获得50点攻速，持续6秒
---@class W_TianYC_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianYC_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hitLostRate = self:getParam(1) -- 对天墉城伤害降低比例
    self.hitUpRate = self:getParam(2) -- 天墉城对目标伤害提高比例
    self.buffData1 = self:getParam(3) -- 免伤提高buff
    self.buffData2 = self:getParam(4) -- 攻速提高buff
    self.enemyPlayer = nil
end

function M:spawn()
    M.super.spawn(self)
    self.enemyPlayer = nil
    local enemys = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
    local atkMax = 0
    for i = 1, enemys.Count do
        local enemy = enemys:get(i - 1)
        if enemy.data and enemy.data.atk and enemy.data.atk:getValue() > atkMax then -- 找到攻击力最高的地方英雄
            atkMax = enemy.data.atk:getValue()
            self.enemyPlayer = enemy
        end
    end
    self.player.bufMgr:addBufById(self.buffData1, self.player)
    EventDispatcher:registerEvent("PlayerDead", {self,self.PlayerDeadHandler})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

--攻击者的攻击开始处理
---@param attackData Battle_AttackData
---@param victim PlayerModel
function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    if self.enemyPlayer and victim:equal(self.enemyPlayer) and self.player:equal(attackData.player) then
        attackData.damageLast = attackData.damageLast + self.hitUpRate -- 伤害增伤
    end
end

---@param eventData Battle_BeHitDirectData
function M:injureHandler(eventName, eventData)
    if self.enemyPlayer and self.enemyPlayer:equal(eventData.killer) and self.player:equal(eventData.victim) then  --攻击者是攻击力最高的地方英雄
        eventData.wantdata.damage = GlobalTools:Mul(eventData.wantdata.damage, GlobalTools.base1 - self.hitLostRate)
    end
end

--死亡回调
function M:PlayerDeadHandler( eventName, data )
    local player = data["data"]
    if self.enemyPlayer and player ~= nil and player:equal(self.enemyPlayer) then -- 死的人是不是锁定的敌人
        self.player.bufMgr:addBufById(self.buffData2, self.player)
        self.player.bufMgr:removeBufById(self.buffData1)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.PlayerDeadHandler})
    self.enemyPlayer = nil
    M.super.destroy(self)
end

return M