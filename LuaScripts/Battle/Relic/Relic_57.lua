--毁灭神符
--在对战25秒时对地方造成大量伤害并有晕眩效果
---@class Relic_57 : Relic @
---@field super Relic @Relic
local M = class("Relic_57", Relic)

--时间
M.time = nil
--攻击提升
M.atk = nil
--眩晕时长
M.bufTime = nil

M.buffData = nil

M.timer = nil

M.finish = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.time = self:getValue(1)
	self.atk = self:getValue(2)
	self.bufTime = self:getValue(3)

	self.buffData =
	{
		["buffType"] = "Imprison",
		["buffDes"] = "",
		["workRound"] = 1,
		["lastTime"] = self.bufTime,
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
				["effectDestroyTime"] = self.bufTime,
			},
			[2] =
			{
				["prefab"] = "fx_Relics_Explosion_01",
				["effectType"] = "startPlay",
				["effectParent"] = "effectpoint0",
				["effectDestroyTime"] = "2",
			},
		},
		["buffTags"] =
		{
			[1] = "debuff",
		},
	}
end
M.sum = 0
function M:gameStart()
	M.super.gameStart(self)
	self.timer = 0
	self.finish = false

	local targets = self.mgr:getTarget("enemy", "all")

	for i = targets.Count,1,-1 do
		local target = targets:get(i - 1)
		local hp = target.data:get_hp()
		self.sum = self.sum + hp
	end

end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
	self.timer = self.timer + dt
	if self.finish == false and self.timer > self.time then
		local targets = self.mgr:getTarget("enemy", "all")
		for i=targets.Count,1,-1 do
			local target = targets:get(i - 1)			
			local dmg = (self.sum / targets.Count) * self.atk			
			local attackData = BattleTool:getBaseAttackData()
			attackData["damage"] = dmg
			attackData["damageFront"] = GlobalTools.base1
			attackData["damageLast"] = GlobalTools.base1
			attackData["damageType"] = 1
			attackData["mustHit"] = true
			if target:isLive() then
				target.bufMgr:addBuf(self.buffData, nil)
				target:injure(attackData)
			end
		end
		self.finish = true
	end
	
	
end

return M