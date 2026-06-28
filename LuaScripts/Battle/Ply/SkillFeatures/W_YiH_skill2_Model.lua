--移花 skill2 战斗中 提升自身攻速12%
---@class W_YiH_skill2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_YiH_skill2_Model", SkillFeatures_Model)

M.bufid = 0
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.bufid = self:getParam(1)
end


function M:spawn()
    M.super.spawn(self)
    self.player.bufMgr:addBufById(self.bufid, self.player)
end


function M:destroy()
    M.super.destroy(self)
end

return M