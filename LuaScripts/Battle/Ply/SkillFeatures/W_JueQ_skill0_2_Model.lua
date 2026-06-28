--绝情被动
--在自身周围召唤结界，结界内的敌人受到的所有内力恢复效果会降低40% 敌人首次尝试出入结界的时候 会受到200%攻击力的伤害和2秒眩晕
--结界内的敌人换回降低50%的血量恢复效果
local W_JueQ_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_JueQ_skill0_1_Model")
---@class W_JueQ_skill0_2_Model : W_JueQ_skill0_1_Model @
---@field super W_JueQ_skill0_1_Model @W_JueQ_skill0_1_Model
local M = class("W_JueQ_skill0_2_Model", W_JueQ_skill0_1_Model)

M.buffId4 = 0
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId4 = self:getParam(5) --血量恢复
end

function M:alterAdd_Value( ply )
   ply.bufMgr:addBufById(self.buffId4, self.player) --血量恢复
end

function M:alterRemove_Value( ply )
   ply.bufMgr:removeBufById(self.buffId4) --删除血量恢复
end


function M:destroy()
    M.super.destroy(self)
end

   

return M