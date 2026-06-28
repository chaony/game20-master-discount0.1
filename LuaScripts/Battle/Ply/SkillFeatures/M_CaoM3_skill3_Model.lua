--山贼刺客
--该技能 暴击时，伤害额外提升50%
---@class M_CaoM3_skill3_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("M_CaoM3_skill3_Model", SkillFeatures_Model)


M.atk = nil
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.atk = self:getParam(1)
end


function M:killerAfterAttack(data)
	local isCrit = data["isCrit"]
	local dmg = data["damage"]
	local killer = data["killer"]
	local skill = data.attackData["skillConfig"]
	if killer ~= nil and killer:equal(self.player) and skill ~= nil and skill.anim_name == "skill3" then
		if isCrit == true  then
			data["damage"] = dmg + GlobalTools:Mul(dmg, self.atk)
		end
	end
end

return M