--小乔施展诅咒之力，为敌方当前攻击力最高的敌人施加诅咒，使其造成的所有伤害强制降为1点（对首领单位无效），持续4秒，被施加了诅咒的敌人在诅咒结束后8秒内，无法被再次选择为诅咒目标，且造成的伤害会降低20%
--诅咒的持续时间提升至5秒
--被诅咒的敌人受到的伤害还会增加20%
--被诅咒的敌人受到的伤害还会增加30%
---@class W_XiaoQ_skill3_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XiaoQ_skill3_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.zeroAtkBuff = self:getParam(1) --为敌方当前攻击力最高的敌人施加诅咒，使其造成的所有伤害强制降为1点 tag W_XiaoQ_Skill3_Plus
    self.lowAtkBuff = self:getParam(2)--被施加了诅咒的敌人在诅咒结束后8秒内，无法被再次选择为诅咒目标，且造成的伤害会降低20%    tag W_XiaoQ_Skill3_Plus_Low_Atk
    EventDispatcher:registerEvent("remove_W_XiaoQ_Skill3_Plus", {self,self.removeBuffHandler})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end


function M:checkAtkMaxEnemy()
    local enemies = SelectTargetUtil:findPlayerByParam(self.player, {camp = "enemy", ignoreSummon = true})
    local maxAtkBack = 0
    local atkMaxEnemy = nil
    for i = 1, enemies.Count do
        local temp = enemies:get(i - 1)
        if temp:isLive() == true and not temp.bufMgr:hasBufByTag("W_XiaoQ_Skill3_Plus_Low_Atk") and not temp.bufMgr:hasBufByTag("W_XiaoQ_Skill3_Plus")  then
            if maxAtkBack <= temp.data.atk:getValue() then
                maxAtkBack = temp.data.atk:getValue()
                atkMaxEnemy = temp
            end
        end
    end
    return atkMaxEnemy
end

function M:skillStart(data)
    local enemy = self:checkAtkMaxEnemy()

    if enemy and enemy:isLive() and enemy.bufMgr then
        enemy.bufMgr:addBufById(self.zeroAtkBuff, self.player, self.skill)
    end
    M.super.skillStart(self, data)
end

--function M:findPlayer(data)
--    if self.skill == self.player.curSkillConfig then
--        return self:checkAtkMaxEnemy()
--    end
--    return data
--end

function M:removeBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) then
        local player = buff.player
        if player and player.bufMgr then
            player.bufMgr:addBufById(self.lowAtkBuff, self.player, self.skill)
        end
    end
end
function M:injureHandler(eventName, eventData)
    if  eventData.victim ~= nil and eventData.victim.camp == self.player.camp and eventData.killer.bufMgr ~= nil and eventData.killer.bufMgr:hasBufByTag("W_XiaoQ_Skill3_Plus")  then
        eventData.wantdata.damage = 1
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("remove_W_XiaoQ_Skill3_Plus", {self,self.removeBuffHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M