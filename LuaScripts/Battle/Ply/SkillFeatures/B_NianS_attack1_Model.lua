--年兽boss attack

---@class B_NianS_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("B_NianS_attack1_Model", SkillFeatures_Model)

M.dis = nil
function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
end

--出生
function M:spawn( ... )
    M.super.spawn(self,...)
    local bufData1 = self:getParam(1)
    self.player.bufMgr:addBufById(bufData1, self.player) --免疫hit

    local bufData2 = self:getParam(2)
    self.player.bufMgr:addBufById(bufData2, self.player) --免疫控制
    
    local bufData4 = self:getParam(3)
    self.player.bufMgr:addBufById(bufData4, self.player) --受击会怒降低70%
end



function M:destroy()
    M.super.destroy(self)
    
end

return M