--每场战斗第一次触发该效果时，将不再消耗丹药	
local W_FuW_skill1_2_Model = require("Battle.Ply.SkillFeatures.W_FuW_skill1_2_Model")
---@class W_FuW_skill1_3_Model : W_FuW_skill1_2_Model @
---@field super W_FuW_skill1_2_Model @W_FuW_skill1_2_Model
local M = class("W_FuW_skill1_3_Model", W_FuW_skill1_2_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.first = true
end


function M:canUse()
    if self.first then
        self.first = false
        self:sendforControl()
        return true
    else
        if self.player.medCount > 0 then
            self:sendforControl()
            self:setMed(self.player.medCount - 1)
            return true
        else
            return false
        end
    end
end

return M