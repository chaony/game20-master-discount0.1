--战斗开始时，武当立刻在敌方战场中央降下七星剑阵，立即对所有敌人造成200%攻击力的伤害并在之后再造成3次70%攻击力的伤害
---@class W_WDang_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WDang_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    --七星剑阵buff
    self.buff1 = self:getParam(1)
    --属性buff
    self.buff2 = self:getParam(2)
end

--角色出生结束
function M:spawnFinish()
    M.super.spawnFinish(self)
    self.player.bufMgr:addBufById(self.buff1, self.player, self.skill)
    self.player.bufMgr:addBufById(self.buff2, self.player, self.skill)
end

function M:destroy()
    M.super.destroy(self)
end
return M