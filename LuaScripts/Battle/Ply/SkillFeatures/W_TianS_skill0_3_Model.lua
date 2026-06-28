--当天山参与击杀了3个及3个以上敌方侠客时，会额外获得20点吸血等级，该效果会一直持续到战斗结束
local W_TianS_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_TianS_skill0_1_Model")

---@class W_TianS_skill0_3_Model : W_TianS_skill0_1_Model @
---@field super W_TianS_skill0_1_Model @W_TianS_skill0_1_Model
local M = class("W_TianS_skill0_3_Model", W_TianS_skill0_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.maxCount = self:getParam(2) --击杀数量
    self.leechingBuff = self:getParam(3) --吸血buff
end

function M:killPlayerHandler(eventName, data)
    M.super.killPlayerHandler(self, eventName, data)
    if self.count == self.maxCount then
        self.player.bufMgr:addBufById(self.leechingBuff, self.player, self.skill)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self, self.killPlayerHandler})
    M.super.destroy(self)
end

return M