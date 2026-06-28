local W_BaG_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_BaG_skill0_1_Model")
---@class W_BaG_skill0_2_Model : W_BaG_skill0_1_Model
local M = class("W_BaG_skill0_2_Model", W_BaG_skill0_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    --怒气
    self.anger = self:getParam(2)
end


--发生暴击
function M:critHandler( eventName, data )
    M.super.critHandler(self, eventName, data)
    local ply = data["ply"]
    if self.player:equal(ply) then
        self.player.data:addAnger( self.anger, true )
    end
end

return M