--皓羽会一直跟随附身目标，当目标身上的皓羽层数达到3层时，；立刻对附身目标进行一次【皓羽普渡】，立刻恢复150%攻击力的生命值，并且皓羽印记消失。
---@class P_Niao_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Niao_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.effectNum = self:getParam(1) -- x根羽毛
    self.buffData1 = self:getParam(2) -- 皓羽普渡
end

function M:destroy()
    M.super.destroy(self)
end

return M