
local W_XingY_skill3_2_Model = require("Battle.Ply.SkillFeatures.W_XingY_skill3_2_Model")
---@class W_XingY_skill3_3_Model : W_XingY_skill3_2_Model @
---@field super W_XingY_skill3_2_Model @W_XingY_skill3_2_Model
local M = class("W_XingY_skill3_3_Model", W_XingY_skill3_2_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	--self.one_atk = self:getParam(2)
	--self.two_atk = self:getParam(3)
	--self.three_atk = self:getParam(4)
end


--攻击开始处理
function M:killerBeforeAttack(attackData, killer)
	--if attackData["injureType"] ~= "buff" then
	--	local attack1 = self.player.plySkill:getSkillByName("attack1")
	--	if attack1 ~= nil then
	--		if attack1.cur_skill_config.feature.state ~= nil and attack1.cur_skill_config.feature.state.anim_name == "skill3" then
	--			local attackCount = attack1.cur_skill_config.feature.attackCount
	--			if attackCount == 2 then
	--				attackData["damageFront"] = self.one_atk
	--			elseif attackCount == 1 then
	--				attackData["damageFront"] = self.two_atk
	--			elseif attackCount == 0 then
	--				attackData["damageFront"] = self.three_atk
	--			end
	--		end
	--	end
	--end
end


function M:spawn()
    M.super.spawn(self)
end


function M:destroy()
    M.super.destroy(self)
    
end

return M