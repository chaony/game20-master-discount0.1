-- 战斗开始时，狄仁杰会随机选择5个敌方侠客揭露其罪行并为其施加一层“断狱”状态，
--断狱状态会一直持续到战斗结束或狄仁杰死亡，且最多叠加3层，每有一层断狱状态，该敌人受到的伤害变会增加10%，--
--之后战斗时间每过去10秒，狄仁杰还会随机选择2个角色，并为其施加1层“断狱”状态，若武则天在场，则必须武则天也死亡才会消失
--lv4击杀我方单位的敌方侠客将立刻被施加一层断狱状态
---@class W_DiRJ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DiRJ_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.realFriend = nil
    self.duanYuBuffId = self:getParam(1)  -- 断狱buff

    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    local friends = SelectTargetUtil:findPlayerByParam(self.player, {
        camp = "friendExceptSelf",
        ignoreSummon = true,
        priority = true,
    })
    for i = 1, friends.Count do
        local friend = friends:get(i - 1)
        if friend then
            if friend.playerId == Battle.EnumData.BATTLE_SPECIAL_HERO_ID.WuZT then
                self.realFriend = friend
                break
            end
        end
    end

    local targets = SelectTargetUtil:findPlayerByParam(self.player, { camp = "enemy", ignoreSummon = true, count = "all"})
    for i = 1, targets.Count do
        local player = targets:get(i - 1)
        if player and player.bufMgr then
            player.bufMgr:addBufById(self.duanYuBuffId, self.player, self.skill)
        end
    end
end

---@param data Battle_HandleData_KillPlayer
function M:killerPlayerHandler(eventName, data)
    local removeFlag = false
    if self.player:equal(data.victim) or (self.realFriend and self.realFriend:equal(data.victim)) then
        if not self.realFriend and self.player:equal(data.victim) then
            removeFlag = true
        elseif self.realFriend and not(self.realFriend:isLive()) and not(self.player:isLive()) then
            removeFlag = true
        end
    end
    
    if removeFlag == true then
        local enemies = SelectTargetUtil:findPlayerByParam(self.player, {camp = "enemy", ignoreSummon = true, count = "all"})
        for i = 1, enemies.Count do
            local ememy = enemies:get(i - 1)
            if ememy and ememy.bufMgr then
                ememy.bufMgr:removeBufByTag("W_DiRJ_skill1", true)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    M.super.destroy(self)
end

return M