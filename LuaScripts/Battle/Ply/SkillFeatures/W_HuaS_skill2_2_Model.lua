-- 等级2:战斗中，华山每成功闪避一次，便获得20点内力

local W_HuaS_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_HuaS_skill2_1_Model")
---@class W_HuaS_skill2_2_Model : W_HuaS_skill2_1_Model @
---@field super W_HuaS_skill2_1_Model @W_HuaS_skill2_1_Model
local M = class("W_HuaS_skill2_2_Model", W_HuaS_skill2_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.add_anger_after_dodge = self:getParam(1)
    EventDispatcher:registerEvent("dodge", {self,self.dodgeHandler})
end

--发生闪避
---@param data table
function M:dodgeHandler(eventName, data)
    if self.player:equal(data.victim) then
        self.player.data:addAnger( self.add_anger_after_dodge, true )
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("dodge", {self,self.dodgeHandler})
    M.super.destroy(self)
end

return M