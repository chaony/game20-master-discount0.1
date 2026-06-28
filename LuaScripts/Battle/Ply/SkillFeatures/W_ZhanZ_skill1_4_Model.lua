--护卫期间，护卫目标会获得展昭防御属性的50%，展昭会获得护卫目标攻击属性的50%
local W_ZhanZ_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_ZhanZ_skill1_1_Model")
---@class W_ZhanZ_skill1_4_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ZhanZ_skill1_4_Model", W_ZhanZ_skill1_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId1 = self:getParam(1) --护卫目标会获得展昭防御属性的50%
    self.buffId2 = self:getParam(2) --展昭会获得护卫目标攻击属性的50%
    EventDispatcher:registerEvent("add_W_ZhanZ_skill1", {self,self.addBuffHandler})
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, eventData)
    if eventData.buff and self.player:equal(eventData.buff.source) and self.player:equal(eventData.buff.player) ~= true then
        self:connectTarget(eventData.buff.player)
        eventData.buff.player.bufMgr:addBufById(self.buffId1, self.player, self.skill)
        self.player.bufMgr:addBufById(self.buffId2, eventData.buff.player, self.skill)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_ZhanZ_skill1", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M