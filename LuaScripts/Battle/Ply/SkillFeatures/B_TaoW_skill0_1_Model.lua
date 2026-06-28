--战斗中，boss自身受到的单体伤害增加50%

---@class B_TaoW_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("B_TaoW_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.isFive = self:getParam(1) --第五形态
    self.buffId1 = self:getParam(2)
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    if self.isFive == 0 then
        self.player.bufMgr:addBufById(self.buffId1, self.player, self.skill)
    end
end

function M:skillStart(data)
    
end
function M:destroy()
    M.super.destroy(self)
end

return M