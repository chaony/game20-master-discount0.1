--悲魔山庄	蚀骨血刃
-- lv1 悲魔山庄挥剑旋转一圈，对自身周围的敌人造成200%攻击力的伤害，该技能命中敌人后，会为自身添加5层“破天劲”，且每额外命中一个敌人，还会多添加一层

---@class W_BeiMSZ_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @W_JueQ_skill0_2_Model
local M = class("W_BeiMSZ_skill2_1_Model", SkillFeatures_Model)

--初始化
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

	self.firstHitAddStack = self:getParam(1) -- Fix[1-100] 首次命中增加层数
	self.extraHitAddStack = self:getParam(2) -- Fix[1-100] 额外命中增加层数

	self.beHitPlayer = {}	-- 当前技能命中的人
end

function M:spawnFinish()
	self.mySkill1 = self.player.plySkill:getSkillByName("skill1")
	M.super.spawnFinish(self)
end

function M:skillStart(data)
	M.super.skillStart(self, data)
	self.isInSkill = true
	self.beHitPlayer = {}
end

function M:skillEnd(data)
	self.isInSkill = false
	self.beHitPlayer = {}
	M.super.skillEnd(self, data)
end

--攻击者攻击结束处理
---@param data Battle_HandleData_Attack
function M:killerAfterAttack(data)
	if self.player:equal(data.killer) and data.attackData.skillConfig == self.skill then
		self:onHitSomeBody(data.victim)
	end
end

---@param player PlayerModel
function M:onHitSomeBody(player)
	if not self.beHitPlayer[player] then  -- 命中敌人
		local isFirst = (table.nums(self.beHitPlayer) == 0)
		self.beHitPlayer[player] = true
		self:onRealHitSomeBody(player, isFirst)
	end
end

function M:onRealHitSomeBody(player, isFirst)
	if self.mySkill1 then
		---@type W_BeiMSZ_skill1_1_Model
		local feature = self.mySkill1.cur_skill_config and self.mySkill1.cur_skill_config.feature
		if feature and feature.improvePtStack then
			if isFirst then
				feature:improvePtStack(self.firstHitAddStack)
			else
				feature:improvePtStack(self.extraHitAddStack)
			end
		end
	end
end

return M