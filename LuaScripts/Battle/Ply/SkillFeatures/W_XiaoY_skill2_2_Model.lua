--“逍遥游”效果结束时，逍遥会恢复10%最大生命值
---@class W_XiaoY_skill2_2_Model : W_XiaoY_skill2_1_Model
local W_XiaoY_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_XiaoY_skill2_1_Model")
local M = class("W_XiaoY_skill2_2_Model", W_XiaoY_skill2_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hpBuff = self:getParam(2)
end

function M:stateEnd()
    M.super.stateEnd(self)
    self.player.bufMgr:addBufById(self.hpBuff, self.player, self.skill)
end

function M:destroy()
    M.super.destroy(self)
end

return M