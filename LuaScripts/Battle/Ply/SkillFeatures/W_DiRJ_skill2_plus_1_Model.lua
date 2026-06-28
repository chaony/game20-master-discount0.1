-- 狄仁杰随机攻击两名敌方侠客，对其造成攻击力200%的伤害并使其禁锢3秒，之后为其施加一层“断狱”状态，
--且每次有地方侠客被施加“断狱”状态，狄仁杰都活获得10%伤害提升，持续5秒，最多叠加5层，
--若场上同时存在武则天，则武则天每次施加“慑服”状态还会使狄仁杰的攻速提升10%，持续5秒，最多叠加5层
---@class W_DiRJ_skill2_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DiRJ_skill2_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId1 = self:getParam(1) --伤害提升buff
    self.buffId2 = self:getParam(2) --攻速提升buff
    self.realFriend = nil
    EventDispatcher:registerEvent("add_W_DiRJ_skill1", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("add_W_WuZT_skill1", {self,self.addBuffHandler2})
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
end

function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) then
        self.player.bufMgr:addBufById(self.buffId1, self.player, self.skill)
    end
end

function M:addBuffHandler2(eventName, data)
    local buff = data["buff"]
    if self.realFriend and self.realFriend:isLive() and buff ~= nil  then
        self.player.bufMgr:addBufById(self.buffId2, self.player, self.skill)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_DiRJ_skill1", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("add_W_WuZT_skill1", {self,self.addBuffHandler2})
    M.super.destroy(self)
end

return M