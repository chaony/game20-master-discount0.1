---@class W_JinQ_skill3_3_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JinQ_skill3_3_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

function M:spawn( )
	self.player.skillImprove:addItem("equip_hero",2029999)
	--self.player.skillImprove:addItem(v)
end

function M:destroy()
    M.super.destroy(self)
end
return M