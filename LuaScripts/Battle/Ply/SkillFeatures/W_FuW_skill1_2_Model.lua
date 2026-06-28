 local W_FuW_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_FuW_skill1_1_Model")

---@class W_FuW_skill1_2_Model : W_FuW_skill1_1_Model @
---@field super W_FuW_skill1_1_Model @W_FuW_skill1_1_Model
local M = class("W_FuW_skill1_2_Model", W_FuW_skill1_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buff2 = self:getParam(4)
end

function M:useMedicine()
    M.super.useMedicine(self)
    self.player.bufMgr:addBufById(self.buff2,self.player)
end

return M