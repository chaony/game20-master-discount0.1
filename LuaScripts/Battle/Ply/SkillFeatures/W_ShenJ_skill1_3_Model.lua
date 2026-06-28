--神机 该技能在攻击血量低于50%的敌人时，伤害提升30%
---@class W_ShenJ_skill1_3_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ShenJ_skill1_3_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hp = self:getParam(1)
    self.dmg = self:getParam(2)
end


function M:spawn()
    M.super.spawn(self)
end


function M:killerAfterAttack(data)
	local dmg = data["damage"]
	local killer = data["killer"]
	local skill = data.attackData["skillConfig"]
	local victim =data["victim"]
	if killer ~= nil and killer:equal(self.player) and skill ~= nil and skill.anim_name == "skill1" then
		if victim ~= nil  then
			local hp_value = GlobalTools:Mul(victim.data:get_hp(), self.hp)
			if victim.data:get_curHp() <= hp_value then
				local damage_value = GlobalTools:Mul(data.damage, self.dmg);
				data.damage = data.damage + damage_value
				return data.damage
			end
			
		end
	end
	return data.damage
end


function M:destroy()
    M.super.destroy(self)
end

return M