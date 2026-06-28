--卢俊义为自身开启一个持续5秒的护盾，持续期间，每秒受到的伤害不会超过最大生命值的10%
--战斗中自身生命值首次低于30%时，将为全队恢复相当于自身攻击力300%的生命值，自身获得3倍的恢复效果。
---@class W_LuJY_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LuJY_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
	M.super.init(self, ply, skill,className)
	self.hpRate = self:getParam(1) -- 单次伤害最大值百分比
	self.hpValue = self:getParam(2) -- 护盾触发的血量比例
	self.hpBuff = self:getParam(3) -- 恢复buff
	self.hurtHpMax = 0
	self.curHurt = 0
	EventDispatcher:registerEvent("allInjure", {self,self.allInjureHandler})
end

function M:spawn()
	M.super.spawn(self)
	self.first = true
	self.hurtHpMax = GlobalTools:Mul(self.player.data:get_hp(), self.hpRate)
	self:resetMaxHurtFeature()
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
	if self.timer and self.timer > 0  then
		self.timer = self.timer - dt
		if self.timer <= 0 then
			self:resetMaxHurtFeature()
		end
	end
	if self.first == true and self.player.data:get_hpRate() <= self.hpValue then
		local friends = SelectTargetUtil:findPlayerByParam(self.player, {camp = "friend", ignoreSummon = true, count = "all"})
		for i = friends.Count, 1, -1 do
			local friend = friends:get(i - 1)
			if friend and friend.bufMgr and friend:isLive()  then
				friend.bufMgr:addBufById(self.hpBuff, self.player, self.skill)
				if friend == self.player then
					friend.bufMgr:addBufById(self.hpBuff, self.player, self.skill)
					friend.bufMgr:addBufById(self.hpBuff, self.player, self.skill)
				end
			end
		end
		self.first = false
	end
end



--- 重置每秒受到的伤害不会超过最大生命值的10%特性
function M:resetMaxHurtFeature()
	self.timer = GlobalTools.base1
	self.curHurt = self.hurtHpMax
end

---@param data Battle_HandleData_Injure
function M:allInjureHandler(eventName, data)
	-- 自己受伤且有W_LuJY_skill2护盾
	if self.player:equal(data.victim) and self.player.bufMgr:hasBufByTag("W_LuJY_skill2") then
		if self.curHurt <= 0 then
			data.wantdata.damage = 1
		else
			if data.wantdata.damage > self.curHurt then
				data.wantdata.damage = self.curHurt
			end
			self.curHurt = self.curHurt - data.wantdata.damage	-- 剩余可受伤害
		end
	end
end

function M:destroy()
	self.hurtHpMax = 0
	self.curHurt = 0
	EventDispatcher:unRegisterEvent("allInjure", {self, self.allInjureHandler})
	M.super.destroy(self)
end

return M