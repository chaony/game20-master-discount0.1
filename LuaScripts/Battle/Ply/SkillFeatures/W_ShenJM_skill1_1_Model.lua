--当自身处于“神剑“或“真·神剑”状态时，被命中的敌人还会被眩晕2秒

---@class W_ShenJM_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @W_ShenJM_skill1_1_Model
local M = class("W_ShenJM_skill1_1_Model", SkillFeatures_Model)

--初始化
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

function M:skillStart(data)
	local skill3Buff = self.player.bufMgr:findBufByTag("W_ShenJM_skill3")
	local skill2Buff = self.player.bufMgr:findBufByTag("W_ShenJM_skill2")
	if #skill3Buff > 0 or #skill2Buff>0 then
		self.skill.extra_anim_name = "skill1_1"
	else
		self.skill.extra_anim_name = "skill1"
	end
	M.super.skillStart(self,data)
end

function M:destroy()
	M.super.destroy(self)
end


return M