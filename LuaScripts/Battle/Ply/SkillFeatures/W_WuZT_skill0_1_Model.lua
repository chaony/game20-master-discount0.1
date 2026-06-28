--四海臣服
--战斗开始前10秒，武则天会免疫所有负面效果，且每有一个敌方或己方侠客死亡，武则天便会恢复10%最大生命值的血量，并使自身无敌2秒

---@class W_WuZT_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WuZT_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.buffId1 = self:getParam(1)       --免疫buffid
    self.buffId2 = self:getParam(2)       --buffid恢复10%最大生命值的血量，并使自身无敌2秒
    EventDispatcher:registerEvent("killPlayer", {self, self.killPlayerHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self.player.bufMgr:addBufById(self.buffId1, self.player, self.skill)
end

function M:killPlayerHandler(eventName, data)
    local victim = data["victim"]
    local killer = data["killer"]
    if victim:isXiaKe() then
        self.player.bufMgr:addBufById(self.buffId2, self.player, self.skill)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self, self.killPlayerHandler})
    M.super.destroy(self)
end

return M
