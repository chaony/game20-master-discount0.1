--雷神电符
--周期性产生落雷攻击随机敌人造成伤害和短暂眩晕
---@class Relic_52 : Relic @
---@field super Relic @Relic
local M = class("Relic_52", Relic)

--时间间隔
M.interval = nil
--伤害
M.atk = nil
--眩晕时长
M.dizziness = nil

--初始cd
M.timer = 0

M.buffData = nil

--伤害类型
M.damageType = nil

M.sum = 0

M.attackData = {}
--计时器
M.localtime = 0

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.damageType = self:getValueSimple(1)
	self.timer = self:getValue(2)
	self.interval = self:getValue(3)
	self.atk =  self:getValue(4)
	self.dizziness = self:getValue(5)
end

function M:gameStart()
	M.super.gameStart(self)
	self.localtime = self.timer
	self.buffData =
	{
		["buffType"] = "AddEffect",
		["buffDes"] = "",
		["workRound"] = 1,
		["lastTime"] = self.dizziness,
		["workTime"] = 0,
		["delayTime"] = 0,
		["buffParam"] =
		{
		},
		["buffEffect"] =
		{
			[1] =
			{
				["prefab"] = "fx_buff_xuanyun",
				["effectType"] = "startPlay",
				["effectParent"] = "head",
				["effectDestroyTime"] = self.dizziness,
			},

			[2] =
			{
				["prefab"] = "fx_Relics_Lightning_01",
				["effectType"] = "startPlay",
				["effectParent"] = "effectpoint0",
				["effectDestroyTime"] = self.dizziness,
			},
		},
		["buffTags"] =
		{
			[1] = "debuff",
		},
	}
	
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)

	self.localtime = self.localtime - dt
	if self.localtime <= 0 then
		self.localtime = self.localtime + self.interval
		local targets = self.mgr:getTarget("enemy", "all")
		local count_list = GlobalTools:RandomList(targets,1)
		local ply = count_list:get(0)

		local dmg = ply.data:get_hp() * self.atk
		self.attackData["damage"] = dmg
	    self.attackData["damageFront"] = GlobalTools.base1
	    self.attackData["damageLast"] = GlobalTools.base1
	    self.attackData["damageType"] = self.damageType
	    self.attackData["mustHit"] = true
		ply:injure(self.attackData)
		ply.bufMgr:addBuf(self.buffData, nil)
	end

end

return M
