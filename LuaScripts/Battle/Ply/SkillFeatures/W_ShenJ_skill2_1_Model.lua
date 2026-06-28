--神机 战斗中 自身暴击率提升12%
---@class W_ShenJ_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ShenJ_skill2_1_Model", SkillFeatures_Model)


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