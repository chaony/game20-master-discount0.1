--战斗第5秒蒙武堂会帮血量百分比最少队友承受伤害2秒，对并对自身周围造成200%的伤害和6秒嘲讽效果，该技能每场战斗仅能触发一次
---@class W_MengWT_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @W_MengWT_skill2_1_Model
local M = class("W_MengWT_skill2_1_Model", SkillFeatures_Model)

--初始化
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.startTime = self:getParam(1) -- 第x秒
	self.startTimer = 0
	self.firstFlag = true -- 首次触发
end

function M:spawn()
	M.super.spawn(self)
	self.startTimer = self.startTime 
end

function M:update(dt,unsdt)
	M.super.update(self, dt,unsdt)
	if self.startTimer > 0 then
		self.startTimer = self.startTimer - dt
		if self.startTimer <= 0 and self.firstFlag then
			self.firstFlag = false
			self:startMySkill2()
		end
	end
end

function M:startMySkill2()
	local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
	local friendCount = friends.Count - 1
	if friendCount > 0 then
		--self.skill.extra_anim_name = "skill2"
		self.player.aiEngine.skillConfig = self.skill
		self.player.aiEngine:changeState("attack")
	end
end

function M:destroy()
	M.super.destroy(self)
end

return M