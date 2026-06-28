--密宗    龙象马牛
---@class W_MiZ_skill0_2_Model : W_MiZ_skill0_1_Model @
---@field super W_MiZ_skill0_1_Model @W_MiZ_skill0_1_Model
local W_MiZ_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_MiZ_skill0_1_Model")
local M = class("W_MiZ_skill0_2_Model", W_MiZ_skill0_1_Model)

--复活调用
function M:relive( eventName, data )
    if data.player:equal(self.player) then
        if self.player.aiEngine ~= nil then
            self.player.aiEngine.skillConfig = self.skill
            self.player.aiEngine:changeState("attack")
        else
            Logger.logError("self.player.aiEngine AI状态机 = nil ") 
        end
    end
end


return M