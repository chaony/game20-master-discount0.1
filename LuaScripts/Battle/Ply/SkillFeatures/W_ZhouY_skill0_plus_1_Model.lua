--每次有敌人被施加“引燃”状态，周瑜便会获得【英姿】效果，每层5%的攻速和攻击力提升效果，最多叠加8层，英姿效果会持续到战斗结束，
--当受到致命伤害时，周瑜会免疫本次伤害，并依照当前【英姿】的层数，每层无敌0.4秒，触发无敌后，【英姿】效果将被清除，无敌效果每场战斗只能触发一次。
--【英姿】效果叠加层数最高为12层
--每层英姿无敌的效果提高至0.6秒
--若场上存在小乔，则周瑜在战斗开始时，将获得4层英姿效果，小乔死亡时，周瑜将立即获得最高英姿层数，并回复所有生命值。
---@class W_ZhouY_skill0_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ZhouY_skill0_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.yingZiBuff = self:getParam(1)--英姿buff
    self.invincibleBuff = self:getParam(2)--无敌buff
    self.startInvincibleCount = self:getParam(3)--一开始获得的英姿层数
    self.maxInvincibleCount = self:getParam(4)--最高英姿层数
    self.hasInvincible = false
    self.hasXiaoQ = false
    EventDispatcher:registerEvent("add_W_ZhouY_YinRan", {self,self.addYinRanBuffHandler})
    EventDispatcher:registerEvent("add_W_ZhouY_WuDi", {self,self.addWuDiBuffHandler})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("killPlayer", {self,self.killPlayerHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self.hasXiaoQ = false
    if self.startInvincibleCount > 0 then
        local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
        friends:safeWalkInverted(function(ply)
            if ply ~= nil and ply:isLive() and ply.playerId == Battle.EnumData.BATTLE_SPECIAL_HERO_ID.XiaoQ then
                self.hasXiaoQ = true
            end
        end)
        if self.hasXiaoQ then
            for i = 0, self.startInvincibleCount do
                self.player.bufMgr:addBufById(self.yingZiBuff, self.player)
            end
        end
    end

end

function M:injureHandler(eventName, eventData)
    if not self.hasInvincible and self.player:equal(eventData.victim) then
        if self.player:isAttackCauseDeath(eventData.attackData, eventData.wantdata) then
            if self.player.bufMgr:hasBufByTag("W_ZhouY_Skill0_YingZi") then
                self.hasInvincible = true
                eventData.wantdata.damage = 0   -- 免受本次伤害
                self.player.bufMgr:addBufById(self.invincibleBuff, self.player)
                self.player.bufMgr:removeBufByTag("W_ZhouY_Skill0_YingZi")
            end
        end
    end
end


function M:addYinRanBuffHandler(eventName, data)
    local buff = data["buff"]
    if not self.hasInvincible and buff ~= nil and self.player:equal(buff.source) then
        self.player.bufMgr:addBufById(self.yingZiBuff, self.player)
    end
end

function M:addWuDiBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.player) and buff.player.bufMgr ~= nil then
        local yingZiBuffs = self.player.bufMgr:findBufByTag("W_ZhouY_Skill0_YingZi")
        if #yingZiBuffs > 0 then
            buff.curLastTime = GlobalTools:Mul(buff.lastTime , GlobalTools:ToFix(#yingZiBuffs))
        end
    end
end

function M:killPlayerHandler(eventName, data)
    local victim = data["victim"]
    if self.maxInvincibleCount > 0 and victim.camp == self.player.camp and victim.playerId == Battle.EnumData.BATTLE_SPECIAL_HERO_ID.XiaoQ then
        local buffs = self.player.bufMgr:findBufByTag("W_ZhouY_Skill0_YingZi")
        local buffCount = #buffs
        for i = buffCount, self.maxInvincibleCount do
            self.player.bufMgr:addBufById(self.yingZiBuff, self.player)
        end
        local cure = self.player.data:get_hp() - self.player.data:get_curHp()
        self.player:cure("fix", self.player, cure, self.skill, false)
    end
end



function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_ZhouY_YinRan", {self,self.addYinRanBuffHandler})
    EventDispatcher:unRegisterEvent("add_W_ZhouY_WuDi", {self,self.addWuDiBuffHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killPlayerHandler})
    M.super.destroy(self)
end

return M