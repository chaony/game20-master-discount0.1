--飞龙堡释放一个飞轮，飞轮会在敌我之间弹跳攻击5次，
--若飞轮命中了敌方单位，则会对其造成200%攻击力的伤害和一层中毒效果，
--若命中了己方单位，则会为其恢复150%攻击力的血量，飞轮会优先选择未命中过的敌方和己方单位

---@class W_FeiLB_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_FeiLB_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    self.addBuff1 = self:getParam(1)       -- Buff[]  命中敌方buff
    self.addBuff2 = self:getParam(2)       -- Buff[]  命中己方buff
    self.addTimes = self:getParam(3)       -- Fix[1-10]  每己方一个水额外弹跳次数
    self.addAnger1 = self:getParam(4)       -- Fix[]  命中敌方加怒气
    self.addAnger2 = self:getParam(5)       -- Fix[]  命中友方加怒气
    
    self.curAddTimes = 0
    self.hitList = {}

    
    EventDispatcher:registerEvent("shootBullet", {self,self.shootBulletHandler})
end

function M:skillStart(data)
    M.super.skillStart(self, data)
    self.hitList = {}

    local friends = SelectTargetUtil:findXieKeFriendWithRace(self.player, Battle.EnumData.BATTLE_RACE.Mu)
    self.curAddTimes = 0
    for i = 1, friends.Count do
        self.curAddTimes = self.curAddTimes + self.addTimes
    end
end

function M:killerBeforeAttack(attackData, victim)
    if BattleTool:isMySkill3(self.player, attackData) then
        if victim then
            if victim.camp == self.player.camp then -- 友方
                attackData.angerAir = GlobalTools:Mul(self.addAnger2, attackData.angerAir)
            else
                attackData.angerAir = GlobalTools:Mul(self.addAnger1, attackData.angerAir)
            end
        end
    end
end

function M:killerAfterAttack(data)
    if data.attackData.skillConfig == self.skill and data.attackData.injureType == "skill" and data.victim then
        self:onHitPlayer(data.victim)

        -- 命中队友和敌方的音效不同
        if data.victim.camp == self.player.camp then
            data.attackData.hitAudio = "skill3_heal"
        else
            data.attackData.hitAudio = "skill3_hit"
        end
    end
end

---@param target PlayerModel
function M:onHitPlayer(target)
    self.hitList[target:get_playerInstanceId()] = 1    -- 记录攻击目标
    if self.player:get_camp() == target:get_camp() then -- 队友
        target.bufMgr:addBufById(self.addBuff2, self.player, self.skill)
    else
        target.bufMgr:addBufById(self.addBuff1, self.player, self.skill)
    end
end

---@param eventData Battle_HandleData_ShootBullet
function M:shootBulletHandler(eventName, eventData)
    if eventData.bullet.sourceSkill == self.skill then
        if eventData.bullet.trackCount and eventData.bullet.setTrackCount then
            local curTimes = eventData.bullet.trackCount + self.curAddTimes
            eventData.bullet:setTrackCount(curTimes)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("shootBullet", {self,self.shootBulletHandler})
    M.super.destroy(self)
end

return M
