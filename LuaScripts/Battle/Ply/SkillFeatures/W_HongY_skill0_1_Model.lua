--红衣造成的所有伤害都有40%的概率为命中的敌人附加1层破甲状态（破甲：每秒受到60%攻击力的伤害，且防御力降低5%，持续5秒，最多可叠加5层）
---@class W_HongY_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HongY_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.rate = self:getParam(1)
    self.buffId = self:getParam(2)
    EventDispatcher:registerEvent("injure", {self, self.injureHandle})
end

function M:injureHandle(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]
    local attackData = data["attackData"]
    if killer ~= nil and killer:equal(self.player) and attackData.injureType ~= "dot" then
        if WRandom:randomNum(0, 100) <= GlobalTools:Mul(self.rate, GlobalTools.base100) then
            victim.bufMgr:addBufById(self.buffId, self.player)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self, self.injureHandle})
    M.super.destroy(self)
end

return M