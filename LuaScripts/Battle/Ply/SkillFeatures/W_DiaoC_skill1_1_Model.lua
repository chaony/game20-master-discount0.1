--貂蝉
--战斗中，只要貂蝉在场，我发所有侠客的攻击不会被闪避，且敌方侠客造成的内功伤害会降低20%，效果会在貂蝉离场后消失
--lv2 若貂蝉在场上存活超过15秒，则该技能效果在貂蝉死亡后也不会消失
--lv3 我方侠客还会获得貂蝉攻速属性和攻击属性的30%
---@class W_DiaoC_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DiaoC_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.effectBuff = self:getParam(1) --特效buffid
    self.buffId1 = self:getParam(2) --无法闪避buffid
    self.buffId2 = self:getParam(3) --内伤降低buff
    self.aliveTime = self:getParam(4) --存活时间
    self.buffId3 = self:getParam(5) --属性增加buffid
    self.curAliveTime = 0
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    local enemys = SelectTargetUtil:findPlayerByParam(self.player, {camp = "enemy", ignoreSummon = true})
    for i = 1, enemys.Count do
        local enemy = enemys:get(i - 1)
        if enemy.bufMgr then
            enemy.bufMgr:addBufById(self.buffId1, self.player, self.skill)
            enemy.bufMgr:addBufById(self.buffId2, self.player, self.skill)
        end
    end
    local friends = SelectTargetUtil:findPlayerByParam(self.player, { camp = "friendExceptSelf",
                                                                      ignoreSummon = true,  
                                                                      count = "all",
                                                                     })
    for i = 1, friends.Count do
        local friend = friends:get(i - 1)
        if friend.bufMgr then
            friend.bufMgr:addBufById(self.effectBuff, self.player, self.skill)
            friend.bufMgr:addBufById(self.buffId3, self.player, self.skill)
        end
    end
    self.player.bufMgr:addBufById(self.effectBuff, self.player, self.skill)
    self.player.bufMgr:addBufById(self.buffId3, self.player, self.skill)
end

function M:update(dt)
    M.super.update(self, dt)
    if self.aliveTime > 0 and self.player:isLive() == true and self.curAliveTime <= self.aliveTime then
        self.curAliveTime = self.curAliveTime + dt
    end
end

---@param data Battle_HandleData_KillPlayer
function M:killerPlayerHandler(eventName, data)
    if self.player:equal(data.victim) and self.curAliveTime < self.aliveTime and self.player.master == nil then
        local enemys = SelectTargetUtil:findPlayerByParam(self.player, {camp = "enemy", ignoreSummon = true})
        for i = 1, enemys.Count do
            local enemy = enemys:get(i - 1)
            if enemy.bufMgr then
                enemy.bufMgr:removeBufById(self.buffId1, true)
                enemy.bufMgr:removeBufById(self.buffId2, true)
            end
        end
        local friends = SelectTargetUtil:findPlayerByParam(self.player, { camp = "friendExceptSelf",
                                                                          ignoreSummon = true,
                                                                          count = "all",
        })
        for i = 1, friends.Count do
            local friend = friends:get(i - 1)
            if friend.bufMgr then
                friend.bufMgr:removeBufById(self.effectBuff, true)
                friend.bufMgr:removeBufById(self.buffId3, true)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    M.super.destroy(self)
end

return M