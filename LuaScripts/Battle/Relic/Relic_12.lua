--剑雨
--战斗开始时和每隔第15秒，向敌对阵营释放一次箭雨
---@class Relic_12 : Relic @
---@field super Relic @Relic
local M = class("Relic_12", Relic)

--时间间隔
M.interval = nil
--初始cd
M.time = nil
--伤害
M.damage = nil

--计时器
M.timer = nil

--攻击数据
M.attackData = {}

--总数
M.sum = 0

--伤害类型
M.damageType = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.damageType = self:getValueSimple(1)
	self.time = self:getValueSimple(2)
	self.interval = self:getValueSimple(3)
	self.damage = self:getValue(4)	
end

function M:gameStart()
	M.super.gameStart(self)
	self.timer = self.time
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
	self.timer = self.timer - dt
	if self.timer <= 0 then
		self.timer = self.timer + self.interval
		local targets = self.mgr:getTarget("enemy", "all")

		self.sum = 0
		for i = 1, targets.Count do
			local ply = targets:get(i - 1)
			local hp = ply.data:get_hp()
			self.sum = self.sum + hp
		end

		local dmg = (self.sum / targets.Count) * self.damage
		self.attackData["damage"] = dmg
	    self.attackData["damageFront"] = GlobalTools.base1
	    self.attackData["damageLast"] = GlobalTools.base1
	    self.attackData["damageType"] = self.damageType
	    self.attackData["mustHit"] = true
		for i = 1, targets.Count do
			local ply = targets:get(i - 1)
			ply:injure(self.attackData)
		end

		local pos = SelectTargetTool:findFixPoint(nil, "sceneCenter")
		SceneManager.curScene:playerEffect(pos:toVector3(), "fx_Relics_JianYu_01", 10 )
	end
end
return M