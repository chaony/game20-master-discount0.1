
---@class W_GaiB_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GaiB_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.buff = self:getParam(1)
    self.count = self:getParam(2)
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    for i = 1, self.count do
        self.player.bufMgr:addBufById(self.buff, self.player)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M