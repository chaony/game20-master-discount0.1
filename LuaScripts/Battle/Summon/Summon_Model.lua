--召唤物
---@class Summon_Model : ModelBase @
---@field super ModelBase @ModelBase
local M = class("Summon_Model",Battle.ModelBase)

function M:init(player, data, skill)
	self.player = player
	self.data = data
	self.sourceSkill = skill
	self.lifeTime = data["lifeTime"]
	self.attackInterval = data["attackInterval"]
	self.atk = GlobalTools:Mul( data["atk"], self.player.data.atk:getValue())
	self.angerAir = data["angerAir"]
	self.perDamageSuck = data["perDamageSuck"]
	self.totalDamageSuck = data["totalDamageSuck"]
	self.timer = GlobalTools.base0
	self.totalDamage = GlobalTools.base0
	-- Summon Model 创建完成
	self.player:dispatchEvent_Local(Battle.EventType.MV_SummonModelCreateFinish, self)
end

--返回宠物数据
function M:get_data()
	return self.data;
end

--返回技能数据
function M:get_skill()
	return self.sourceSkill
end

function M:update(dt)
	self.lifeTime = self.lifeTime - dt
	self.timer = self.timer - dt
	if self.lifeTime > GlobalTools.base0 then
		if self.timer <= GlobalTools.base0 then
			self.timer = self.attackInterval
			local targets = SelectTargetTool:findPlayerByType(self.data, self.player)
			local attackData = BattleTool:getBaseAttackData()
			for i = 1, targets.Count do
				local target = targets:get(i - 1)

				attackData["damage"] = self.atk
				attackData["damageFront"] = GlobalTools.base1
				attackData["damageLast"] = GlobalTools.base1

				attackData["player"] = self.player
				attackData["type"] = 0
				attackData["damageType"] = 1
				attackData["skillConfig"] = self.sourceSkill

				if self.sourceSkill ~= nil then
					attackData["damageType"] = self.sourceSkill.atk_type
				end

				if self.data["injureMove"] == true then
					attackData["injureMove"] = {}
					attackData["injureMove"]["animName"] = self.data["injureAnimName"]
					attackData["injureMove"]["type"] = self.data["curveMoveType"]
					attackData["injureMove"]["distance"] = self.data["curveMoveDistance"]
					attackData["injureMove"]["time"] = self.data["curveMoveTime"]
				else
					attackData["injureMove"] = nil
				end

				attackData["angerAir"] = self.angerAir
				attackData["prefabName"] = self.data["prefabName"]

				local hp = target.data:get_curHp()
				target:injure(attackData)

				if self.sourceSkill ~= nil and self.angerAir > 0 then
					--攻击增怒
					local hit_energy_value = GlobalTools:Mul(self.sourceSkill.hit_energy, self.angerAir);
					local hit_energy_atk = GlobalTools:Mul(hit_energy_value, self.player.data.atkrageregen:getValue());
					local hit_energy_num = hit_energy_atk;
					self.player.data:addAnger( hit_energy_num )
				end
				
				local damage = hp - target.data:get_curHp()
				if self.perDamageSuck > 0 then
					self.player:cure(self.player, GlobalTools:Mul(damage, self.perDamageSuck))
				end
				self.totalDamage = self.totalDamage + damage
			end
		end
	else
		self:stop()
	end
end

function M:stop()
	if self.totalDamageSuck > 0 then
		self.player:cure(self.player, GlobalTools:Mul(self.totalDamage, self.totalDamageSuck))
	end
	self.player.summonMgr:remove(self)
	-- 播放特效
	self:dispatchEvent_Local(Battle.EventType.MV_SummonModelPlayEffect)
	-- 停止
	self:dispatchEvent_Local(Battle.EventType.MV_SummonModelStop)
end


function M:destroy()
	-- 销毁
	self:dispatchEvent_Local(Battle.EventType.MV_SummonModelDestroy)
end

return M