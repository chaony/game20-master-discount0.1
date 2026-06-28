 --纯阳 大招效果持续期间，纯阳的普工会附带穿透效果，对命中的所有敌人造成伤害并附加流血效果，该技能没命中一个敌人，会使后续普工的伤害减少20%
local W_ChunY_skill0_2_Model = require("Battle.Ply.SkillFeatures.W_ChunY_skill0_2_Model")
---@class W_ChunY_skill0_3_Model : W_ChunY_skill0_2_Model @
---@field super W_ChunY_skill0_2_Model @W_ChunY_skill0_2_Model
local M = class("W_ChunY_skill0_3_Model", W_ChunY_skill0_2_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.equip_hero_id = self:getParam(1)
end


return M