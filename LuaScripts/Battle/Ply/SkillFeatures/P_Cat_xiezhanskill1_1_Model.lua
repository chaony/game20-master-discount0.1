--每隔x秒，随机选中一个我方后排侠客给予护盾，该护盾可以减少下次伤害的50%。
--当击败敌方宠物后，效果强化为：可以给我方y个后排侠客给予护盾；
---@class P_Cat_xiezhanskill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Cat_xiezhanskill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.addNum1 = self:getParam(1) -- 击败敌方宠物前给x个侠客加
    self.buffData1 = self:getParam(2) -- buff1
    self.addNum2 = self:getParam(3) -- 击败敌方宠物后给y个侠客加成
    self.buffData2 = self:getParam(4) -- buff2
    self.killFlag = false -- 是否击杀地方宠物
    EventDispatcher:registerEvent("PlayerDead", {self,self.PlayerDeadHandler})
end

function M:skillStart(data)
    M.super.skillStart(self, data)
    local max = self.killFlag == true and self.addNum2 or self.addNum1
    for i = 1, max do
        self:randomBackGroundHeroAddBuff()
    end
end

-- 随机后排侠客加buff
function M:randomBackGroundHeroAddBuff()
    local friends = SelectTargetUtil:findPlayerByParam(self.player, {
        camp = "friend",
        posIndex = "backrow",
        ignoreSummon = true,
    })
    local randomIndex = WRandom:randomNum(1, friends.Count, true)
    local friend = friends:get(randomIndex-1)
    if friend ~= nil and friend:isLive() then
        local buffData = self.killFlag == true and self.buffData2 or self.buffData1
        friend.bufMgr:addBufById(buffData, self.player)
    end
end

---@param eventData Battle_HandleData_PlayerDead
function M:PlayerDeadHandler(eventName, eventData)
    if eventData.data and eventData.data.playerType == "pet" and BattleTool:killerIsMe(self.player, eventData.data) then
        self.killFlag = true
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.PlayerDeadHandler})
    M.super.destroy(self)
end

return M