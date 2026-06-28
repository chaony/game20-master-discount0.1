--狼王对被施加了狩猎印记的敌人造成伤害时，本次伤害的暴击率额外提升30%
local W_WanS_skill2_2_Model = require("Battle.Ply.SkillFeatures.W_WanS_skill2_2_Model")
---@class W_WanS_skill2_3_Model : W_WanS_skill2_2_Model @
---@field super W_WanS_skill2_2_Model @W_WanS_skill2_2_Model
local M = class("W_WanS_skill2_3_Model", W_WanS_skill2_2_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.crit = self:getParam(2)
    EventDispatcher:registerEvent("killerDataChangeTemp", {self,self.DataChangeTemp})
end


function M:spawn()
    M.super.spawn(self)
end


function M:DataChangeTemp( eventName, data )
    local killer = data["killer"]
    local victim = data["victim"]
    if killer ~= nil and self.player:equal(killer.master) == true then
        killer.data.critrate:addToAddListTemp(self.crit)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killerDataChangeTemp", {self,self.DataChangeTemp})
    M.super.destroy(self)
end

return M