--玄羽会一直跟随附身目标 ,当目标身上的玄羽层数达到3层时，立刻附身对目标进行一次【暗夜绞杀】，造成200%攻击力的伤害，并且玄羽印记消失。
---@class P_Niao_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Niao_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.effectNum = self:getParam(1) -- x根羽毛
    self.buffData1 = self:getParam(2) -- 暗夜绞杀
end

function M:destroy()
    M.super.destroy(self)
end

return M