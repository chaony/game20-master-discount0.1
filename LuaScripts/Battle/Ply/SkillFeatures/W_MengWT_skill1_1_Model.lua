--蒙武堂重锤地面，对前方范围内的敌人造成260%攻击力的伤害和持续2秒的眩晕效果，该技能成功命中敌人后，
--蒙武堂会获得30%的防御加成，持续5秒，且每额外命中一个敌人，防御加成还会额外提升10%，最多额外提升30%
---@class W_MengWT_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @W_MengWT_skill1_1_Model
local M = class("W_MengWT_skill1_1_Model", SkillFeatures_Model)

--初始化
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.buffData1 = self:getParam(1) -- 命中敌人初始buff
	self.buffData2 = self:getParam(2) -- 每多命中一个敌人额外附加BUFF
	self.beHitPlayer = {}	-- 当前技能命中的人
end

function M:skillStart(data)
	M.super.skillStart(self, data)
	self.beHitPlayer = {}
end

function M:skillEnd(data)
	local count = table.nums(self.beHitPlayer)
	if count > 0 then
		self.player.bufMgr:addBufById(self.buffData1, self.player)
		if count-1 > 0 then
			for i = 1, count-1 do
				self.player.bufMgr:addBufById(self.buffData2, self.player)
			end
		end
	end
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
		self.beHitPlayer[player] = true
	end
end

function M:destroy()
	M.super.destroy(self)
end

return M