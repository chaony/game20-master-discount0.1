--神剑门重击前方敌人，对其造成300%攻击力的伤害和2秒的眩晕效果，释放该技能后，神剑门会进入“真·神剑”姿态6秒，期间攻击力增加40%

---@class W_ShenJM_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @W_ShenJM_skill3_1_Model
local M = class("W_ShenJM_skill3_1_Model", SkillFeatures_Model)

--初始化
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

function M:spawn()
	M.super.spawn(self)
	self.skill0 = nil
	local skill0 = self.player.plySkill:getSkillByName("skill0")
	if skill0 ~= nil and skill0.cur_skill_config then
		---@type SkillFeatures_Model
		self.skill0 = skill0.cur_skill_config.feature
	end
end

function M:skillStart(data)
	if self.skill0 and self.skill0.buffData2 ~= 0 then
		self.skill.extra_anim_name = "skill3_1"
	else
		self.skill.extra_anim_name = "skill3"
	end
	M.super.skillStart(self,data)
end

---@param data Battle_EventData_Dispatch
function M:skillDispatch(data)
	if data.eventName == "zhenshenjian" and self.skill0 then
		self.player.bufMgr:addBufById(self.skill0.buffData1, self.player) -- 每次进入“”神剑“或“真·神剑”状态时，会获得40%伤害减免和30点吸血效果，该效果不可叠加
	end
end

function M:destroy()
	M.super.destroy(self)
end


return M