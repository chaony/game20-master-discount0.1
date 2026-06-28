--纯阳 大招效果持续期间，纯阳的普工会附带穿透效果，对命中的所有敌人造成伤害并附加流血效果，该技能没命中一个敌人，会使后续普工的伤害减少20%
---@class W_ChunY_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ChunY_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.equip_hero_id = self:getParam(1)
end

function M:addSkillId( ... )
    self.player.skillImprove:addItem("equip_hero",self.equip_hero_id)
end

function M:removeSkillId( ... )
    self.player.skillImprove:removeItem("equip_hero",self.equip_hero_id)
end


function M:destroy()
    M.super.destroy(self)
end


return M