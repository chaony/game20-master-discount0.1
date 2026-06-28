--战斗中，当天山参与击杀了一位敌方侠客后，会获得10%的攻击力和10%的攻速提升，该效果会持续到战斗结束
---@class W_TianS_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianS_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.atkBuff = self:getParam(1) --攻击buff
    self.count = 0
    EventDispatcher:registerEvent("killPlayer", {self, self.killPlayerHandler})
end

---@param data Battle_HandleData_KillPlayer
function M:killPlayerHandler(eventName, data)
    local victim = data["victim"]
    local killer = data["killer"]
    if victim.master == nil and victim:get_camp() ~= self.player:get_camp() then
        for k,v in pairs(victim.assistsKiller) do
            if k == self.player:get_playerInstanceId() then
                self.player.bufMgr:addBufById(self.atkBuff, self.player, self.skill)
                self.count = self.count + 1
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self, self.killPlayerHandler})
    M.super.destroy(self)
end

return M