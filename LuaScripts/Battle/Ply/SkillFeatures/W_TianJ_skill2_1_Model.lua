--战斗中，天机受到的所有生命恢复效果提升15%
---@class W_TianJ_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianJ_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    --生命恢复效果提升
    self.hpRecoverBuff = self:getParam(1)
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self.player.bufMgr:addBufById(self.hpRecoverBuff, self.player)
end

function M:destroy()
    M.super.destroy(self)
end

return M