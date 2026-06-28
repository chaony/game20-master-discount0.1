--浩劫绳结
--我方所有武魂使用必杀技时对敌方全体造成一次伤害和晕眩
---@class Relic_59 : Relic @
---@field super Relic @Relic
local M = class("Relic_59", Relic)

--伤害
M.damage = nil
--眩晕时长
M.time = nil

M.buffData = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.damage = self:getValue(1)
	self.time = self:getValue(2)

	self.buffData =
	{
		["buffType"] = "Imprison",
		["buffDes"] = "",
		["workRound"] = 1,
		["lastTime"] = self.time,
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
				["effectDestroyTime"] = self.time,
			},
			[2] =
			{
				["prefab"] = "fx_Relics_Lightning_01",
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
	EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
end

--技能开始
function M:SkillEnterHandler( eventName, data )
	local ply = data["player"]
	local config = data["skillConfig"]
	
	if ply.camp == 1 and config ~= nil and "skill3" == config.anim_name then

		self.targets = self.mgr:getTarget("self", "all")
		for i = 1, self.targets.Count do
			local target = self.targets:get(i - 1)
			local atk = target.data.atk:getValue()
			self.sum = self.sum + atk
		end
		
		self.targets = self.mgr:getTarget("enemy", "all")
		for i = 1, self.targets.Count do
			local target = self.targets:get(i - 1)
			local dmg = (self.sum / self.targets.Count) * self.damage
			local attackData = BattleTool:getBaseAttackData()
			attackData["damage"] = dmg
		    attackData["damageFront"] = GlobalTools.base1
		    attackData["damageLast"] = GlobalTools.base1
		    attackData["damageType"] = self.damageType
		    attackData["mustHit"] = true
			target:injure(attackData)
			target.bufMgr:addBuf(self.buffData, nil)
		end
	end
end

function M:gameover()
	M.super.gameover(self)
	EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})

end

return M