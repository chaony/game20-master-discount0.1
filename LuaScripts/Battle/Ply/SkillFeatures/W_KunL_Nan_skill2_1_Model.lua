--战斗中，昆仑的最大生命值提升30%
---@class W_KunL_Nan_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_KunL_Nan_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.cureBuff = self:getParam(1)
end

function M:follow( followPly )
    if followPly ~= nil then
        followPly.bufMgr:addBufById(self.cureBuff, self.player, self.skill)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M