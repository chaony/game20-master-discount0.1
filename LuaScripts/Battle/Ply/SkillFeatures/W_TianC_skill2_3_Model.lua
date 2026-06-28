--若选中的敌人在决斗时间内死亡，则天策会增加30%攻击力，持续8秒
local W_TianC_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_TianC_skill2_1_Model")
---@class W_TianC_skill2_3_Model : W_TianC_skill2_1_Model @
---@field super W_TianC_skill2_1_Model @W_TianC_skill2_1_Model
local M = class("W_TianC_skill2_3_Model", W_TianC_skill2_1_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(5)
    EventDispatcher:registerEvent("killPlayer", {self, self.killPlayerHandler})
end


function M:killPlayerHandler(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]
    --击杀
    if self:checkSelect(victim) == true then
        self.player.bufMgr:addBufById(self.buffId, self.player)
    end
end


function M:destroy()
	M.super.destroy(self)
    EventDispatcher:unRegisterEvent("killPlayer", {self, self.killPlayerHandler})
end

return M