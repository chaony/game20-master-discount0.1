--小乔施展庇佑之力，使所有友方侠客获得持续2秒的xx效果，处于xx效果的侠客受到的伤害会强制降为1点，xx效果结束时，所有侠客还会获得1个持续6秒的“回春”效果，处于回春效果的侠客受到的伤害减少40%，且每秒会恢复100%小乔攻击力的血量，处于“回春”效果的侠客无法被施加“xx”效果
--xx效果的持续时间提升至3秒
--恢复的血量提升至120%攻击力
--伤害减免效果提升至50%

---@class W_XiaoQ_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XiaoQ_skill3_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.invincibleBuff = self:getParam(1)--所有友方侠客获得持续2秒的invincibleBuff效果 该buff的tag是W_XiaoQ_Skill3
    self.cureBuff = self:getParam(2)--效果结束时，所有侠客还会获得cureBuff效果  该buff的tag是W_XiaoQ_Skill3_Cure
    EventDispatcher:registerEvent("remove_W_XiaoQ_Skill3", {self,self.removeBuffHandler})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:skillStart(data)
    local friends = SelectTargetUtil:findPlayerByParam(self.player, {camp = "friend", ignoreSummon = true, count = "all"})
    for i = friends.Count, 1, -1 do
        local friend = friends:get(i - 1)
        if friend and friend.bufMgr and not friend.bufMgr:hasBufByTag("W_XiaoQ_Skill3_Cure")  then
            friend.bufMgr:addBufById(self.invincibleBuff, self.player, self.skill)
        end
    end
end

function M:removeBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) then
        local player = buff.player
        if player and player.bufMgr then
            player.bufMgr:addBufById(self.cureBuff, self.player, self.skill)
        end
    end
end


function M:injureHandler(eventName, eventData)
    if  eventData.victim ~= nil and eventData.victim.camp == self.player.camp and eventData.victim.bufMgr ~= nil and eventData.victim.bufMgr:hasBufByTag("W_XiaoQ_Skill3")  then
        eventData.wantdata.damage = 1
    end
end
function M:destroy()
    EventDispatcher:unRegisterEvent("remove_W_XiaoQ_Skill3", {self,self.removeBuffHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
	M.super.destroy(self)
end

return M