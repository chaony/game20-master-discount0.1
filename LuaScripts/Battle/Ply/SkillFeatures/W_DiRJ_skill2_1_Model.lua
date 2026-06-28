-- 战斗开始时，狄仁杰会选择一名敌方攻击力最高的侠客，使其沉默5秒，当狄仁杰每次为敌人施加“断狱”状态时，还会随机为一名我方侠客施加一层“明断”状态，
--处于“明断”状态的友军会获得10%的攻击力和攻速提升，持续5秒，最多提升叠加3层，明断状态会优先选择武则天

---@class W_DiRJ_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DiRJ_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId1 = self:getParam(1) --明断buff
    self.friendTarget = nil
    EventDispatcher:registerEvent("add_W_DiRJ_skill1", {self,self.addBuffHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    local targets = SelectTargetUtil:findPlayerByParam(self.player, { camp = "friend", ignoreSummon = true, priority = true})
    local addFlag = false
    for i = 1, targets.Count do
        local player = targets:get(i - 1)
        if player and player.playerId == Battle.EnumData.BATTLE_SPECIAL_HERO_ID.WuZT  then
            self.friendTarget = player
            break
        end
    end
    if not addFlag then
        local target = SelectTargetUtil:findPlayerByParam(self.player, { camp = "friend", ignoreSummon = true,count = "one"})
        local player = target:get(0)
        if player and player.bufMgr then
            player.bufMgr:addBufById(self.buffId1, self.player, self.skill)
        end
    end
end

function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) then
        if self.friendTarget and self.friendTarget:isLive() and self.friendTarget.bufMgr then
            self.friendTarget.bufMgr:addBufById(self.buffId1, self.player, self.skill)
        else
            local targets = SelectTargetUtil:findPlayerByParam(self.player, { camp = "friend", ignoreSummon = true,count = "one"})
            local target = targets:get(0)
            if target and target.bufMgr then
                target.bufMgr:addBufById(self.buffId1, self.player, self.skill)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_DiRJ_skill1", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M