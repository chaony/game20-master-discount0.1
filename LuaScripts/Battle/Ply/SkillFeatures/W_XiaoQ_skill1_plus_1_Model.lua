--小乔施展虚弱，为随机2名敌方侠客施加“虚弱”效果，被虚弱的敌人攻击速度会降低30%，攻击力会降低30%，持续5秒
--被施加虚弱的敌人还会降低30%的内力恢复效果
--持续时间提升至6秒
--持续时间提升至6秒
---@class W_XiaoQ_skill1_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XiaoQ_skill1_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)    
end




function M:destroy()
    M.super.destroy(self)
end

return M