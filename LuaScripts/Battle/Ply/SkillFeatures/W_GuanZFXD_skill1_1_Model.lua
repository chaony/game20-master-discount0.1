--飞雪刀每隔5秒随机对一名敌方侠客生成一个破绽，当飞雪刀普攻攻击被施加了破绽标记的角色时，会消耗该标记并额外附加敌方最大生命值8%的伤害，附加伤害的上限为500%攻击力，同一侠客最多叠加3层破绽。
---@class W_GuanZFXD_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GuanZFXD_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.pozhanBuff = self:getParam(1) -- 破绽buff
    self.intervalTime = self:getParam(2) -- 破绽buff间隔时间
    self.maxHpHurt = self:getParam(3) -- 破绽击破敌人最大生命值百分比
    self.maxAtkHurt = self:getParam(4) -- 破绽击破敌人上限为500%攻击力
    self.buffData2 = self:getParam(5) -- 破绽击破的特效buff
    self.buffData = self:getParam(6) -- 破绽击破自己加的buff
    self.timer = TimeTools:startOneLoopTask(self.intervalTime, handler(self, self.onResetTrigger))
    self.buffCount = 0
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("PlayerDead", {self,self.PlayerDeadHandler})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:update(time)
    if self.timer then
        self.timer:update_dt(time)
    end
end

---@param data Battle_BeHitDirectData
function M:injureHandler(eventName, data)
    local victim = data["victim"]
    local attackData = data["attackData"]
    if victim ~= nil and self.player:equal(victim) == false then
        self:checkPoZhanBuff(attackData, victim)
        self:checkBuffDamage(attackData, victim, data)
    end
end

function M:checkPoZhanBuff(attackData, victim)
    local hasBuff = victim.bufMgr:hasBufByTag("W_GuanZFXD_skill1") -- 破绽标记
    if hasBuff and BattleTool:isMySkillWithPlayer(self.player, attackData, "attack1") then
        victim.bufMgr:addBufById(self.buffData2, self.player) -- 触发破绽特效
        self.player.bufMgr:addBufById(self.buffData, self.player, self.skill) -- 给自己加回血buffd
    end
end

function M:checkPoZhanBuffBySkill3(victim)
    if victim then
        local hasBuff = victim.bufMgr:hasBufByTag("W_GuanZFXD_skill1") -- 破绽标记
        if hasBuff then
            victim.bufMgr:addBufById(self.buffData2, self.player) -- 触发破绽特效
        end
    end
end

---@param victim PlayerModel
---@param attackData Battle_AttackData
function M:checkBuffDamage(attackData, victim, data)
    local killer = data["killer"]
    if BattleTool:isMySkillBuffByPlayer(self.player, attackData, killer, "W_GuanZFXD_skill1_2") then
        local buff_list = victim.bufMgr:findBufByTag("W_GuanZFXD_skill1") -- 破绽标记
        if #buff_list >0 then
            local count = GlobalTools:ToExistFixNum(#buff_list)
            local damage = 0
            local maxAtkHurt = GlobalTools:Mul(self.player.data.atk:getValue(),self.maxAtkHurt) -- 攻击的百分比伤害
            local maxHpHurt = GlobalTools:Mul(victim.data:get_hp() ,self.maxHpHurt) -- 生命的百分比伤害
            if maxHpHurt > maxAtkHurt then
                damage = GlobalTools:Mul( maxAtkHurt, count)
            else
                damage = GlobalTools:Mul( maxHpHurt, count)
            end
            data.wantdata.damage = damage
            victim.bufMgr:removeBufByTag("W_GuanZFXD_skill1") -- 移除破绽标记
        end
    end
end

-- 每隔5秒随机对一名敌方侠客生成一个破绽
function M:onResetTrigger()
    local enemys = self.player.plyMgr:getPlayers(-self.player:get_camp())
    local randomIndex = WRandom:randomNum(1, enemys.Count, true)
    local enemy = enemys:get(randomIndex-1)
    if enemy ~= nil then
        enemy.bufMgr:addBufById(self.pozhanBuff, self.player)
    end
end

--死亡回调
function M:PlayerDeadHandler( eventName, data )
    local player = data["data"]
    if player ~= nil and player:equal(self.player) then -- 死的人是自己的话移除所有敌人身上的破绽标记
        local enemys = self.player.plyMgr:getPlayers(-self.player:get_camp())
        for i = enemys.Count, 1, -1 do
            local enemy_player = enemys:get(i-1)
            enemy_player.bufMgr:removeBufByTag("W_GuanZFXD_skill1")
        end
    end
end
function M:destroy()
    self.timer = nil
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.PlayerDeadHandler})
    M.super.destroy(self)
end

return M