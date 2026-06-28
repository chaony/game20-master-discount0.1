--战斗中，每过10秒，自身可以闪躲一次任意伤害，躲避期间自身无敌；

--技能改
--  战斗中,华山有25%几率闪避攻击
--  等级2:战斗中，华山每成功闪避一次，便获得20点内力

---@class W_HuaS_skill2_1_Model : SkillFeatures_Model
---@field super SkillFeatures_Model
local M = class("W_HuaS_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.dodgeBuff = self:getParam(2);
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self.player.bufMgr:addBufById(self.dodgeBuff, self.player, self.skill)
end

return M