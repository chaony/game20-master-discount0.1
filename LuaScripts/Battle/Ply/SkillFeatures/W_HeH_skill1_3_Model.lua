--当其中一方死亡时，另一方会被眩晕5秒
local W_HeH_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_HeH_skill1_1_Model")
---@class W_HeH_skill1_3_Model : W_HeH_skill1_1_Model @
---@field super W_HeH_skill1_1_Model @W_HeH_skill1_1_Model
local M = class("W_HeH_skill1_3_Model", W_HeH_skill1_1_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.deadBuff = self:getParam(3)
    EventDispatcher:registerEvent("killPlayer", {self, self.killPlayerHandler})
end


function M:spawn()
    M.super.spawn(self)
end


function M:killPlayerHandler(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]
    --击杀或者助攻
    if victim ~= nil then
        if victim:equal(self.player1) then
            if self.player2 ~= nil then
                self.player2.bufMgr:addBufById(self.deadBuff, self.player2)
            end
        elseif victim:equal(self.player2) then
            if self.player1 ~= nil then
                self.player1.bufMgr:addBufById(self.deadBuff, self.player1)
            end
        end
    end
end


function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self, self.killPlayerHandler})
    M.super.destroy(self)
end

return M