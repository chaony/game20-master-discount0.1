---@class W_JinQ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JinQ_skill1_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.rate = self:getParam(1)
	--self.buffId = self:getParam(2)
	self.rateReduce = self:getParam(2)
	self.curRate = self.rate
	self.succeed = false;
end


--当前技能释放
function M:skillStart()
	M.super.skillStart(self)
	if self.player.curSkillConfig ~= nil then
		local r_fix = WRandom:randomNum(0, 100)
		if r_fix <= self.curRate then
			--成功收招
			self.player.curSkillConfig.extra_anim_name = "skill1_1"
            self.succeed = true
			self.curRate = self.curRate - self.rateReduce
		else
			--收招失败
			self.player.curSkillConfig.extra_anim_name = "skill1_2"
            self.succeed = false
			self.curRate = self.rate
		end
	end
end


--技能结束
function M:skillEnd()
	if self.succeed then
		if self.player.aiEngine ~= nil then
			self.player.aiEngine.skillConfig = self.skill
		end
		-- self.player:set_curSkillConfig(self.skill)
		return "attack"
	end
end


function M:destroy()
    M.super.destroy(self)
end

return M