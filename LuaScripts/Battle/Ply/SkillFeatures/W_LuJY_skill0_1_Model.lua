--战斗开始时，卢俊义会获得30%的伤害减免效果，且自身每受到一次伤害，伤害减免效果还会额外提高1%，最多提高至50%
---@class W_LuJY_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LuJY_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
	M.super.init(self, ply, skill,className)
	self.buffId = self:getParam(1) 			-- Buff[] 开场获得buff
	self.addResatd = self:getParam(2)  		--Fix[0-100] 每次受伤增加伤害减免
	self.addResatdMaxCnt = self:getParam(3)		--Int[0-100] 最大伤害减免层数
	self.addHpRecover = self:getParam(4) 		--Fix[0-100] 每次受伤增加收治疗效果
	self.addHpRecoverMaxCnt = self:getParam(5) 	--Int[0-100] 最大收治疗效果层数

	self.curAddResatdCnt = 0
	self.curAddHpRecoverCnt = 0

	EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawn()
	M.super.spawn(self)
	self.player.bufMgr:addBufById(self.buffId, self.player, self.skill)
end

---@param data Battle_BeHitDirectData
function M:injureHandler(eventName, data)
	if self.player:equal(data.victim) == true then -- 受伤的是自己
		-- 增加伤害减免 没有到达上限
		if self.curAddResatdCnt < self.addResatdMaxCnt and self.addResatd > 0 then	
			self.curAddResatdCnt = self.curAddResatdCnt + 1
			self.player.data.resatd:addToAddList(-self.addResatd)
		end

		-- 增加收治疗效果 没有到达上限
		if self.curAddHpRecoverCnt < self.addHpRecoverMaxCnt and self.addHpRecover > 0 then
			self.curAddHpRecoverCnt = self.curAddHpRecoverCnt + 1
			self.player.data.hpRecover:addToAddList(self.addHpRecover)
		end
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
	M.super.destroy(self)
end

return M