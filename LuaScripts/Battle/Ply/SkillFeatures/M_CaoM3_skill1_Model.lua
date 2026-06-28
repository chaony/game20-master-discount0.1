--山贼刺客
--被动buff，持续生效，暴击率增加【15%】，命中增加【15】
---@class M_CaoM3_skill1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("M_CaoM3_skill1_Model", SkillFeatures_Model)


M.atk = nil
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.buffId = self:getParam(1)
end


function M:spawn()
    M.super.spawn(self)
   self.player.bufMgr:addBufById(self.buffId, self.player)
end

return M