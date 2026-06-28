--古墓会获得10%的伤害减免，场上任意武神死亡时，幽魂魅影便恢复最大生命值的10%，同时古墓会获得5%的伤害减免，持续到战斗结束
---@class W_GuM_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GuM_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.dmgBuffId = self:getParam(1)
    self.atdBuff = self:getParam(2)
    EventDispatcher:registerEvent("killPlayer", {self, self.killPlayerHandler})
end

function M:spawn()
    M.super.spawn(self)
    self.player.bufMgr:addBufById(self.atdBuff, self.player)
end

function M:killPlayerHandler(eventName, data)
    local victim = data["victim"]
    local killer = data["killer"]
    if victim.master == nil then
        self.player.bufMgr:addBufById(self.dmgBuffId, self.player)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self, self.killPlayerHandler})
    M.super.destroy(self)
end

   

return M