--应激防御
--敌人首次使用必杀技时己方全体获得一个持续3秒的最大生命40%的护盾
---@class Relic_61 : Relic @
---@field super Relic @Relic
local M = class("Relic_61", Relic)

--时长
M.time = nil
--回复总量
M.hp = nil

M.finish = nil

M.buffData = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.time = self:getValue(1)
	self.hp = self:getValue(2)
	
	self.buffData = 
	{
		["buffType"] = "Shield",
		["buffDes"] = "",
		["workRound"] = "1",
		["lastTime"] = self.time,
		["workTime"] = "0",
		["delayTime"] = "0",
		["buffParam"] =
		{
			["shieldByHp"] = self.hp,
		},
		["buffEffect"] =
		{
			[1] = 
            {
                ["prefab"] = "fx_Relics_HuDun_01",
                ["effectType"] = "startPlay",
                ["effectParent"] = "effectpoint0",
                ["isParent"] = true,
                ["effectDestroyTime"] = self.time,
            },
		},
		["buffTags"] =
		{
			[1] = "buff",
		},
	}
end

function M:gameStart()
	M.super.gameStart(self)
	self.finish = false
	EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
end

--技能释放
function M:SkillEnterHandler( eventName, data )
	local ply = data["player"]
	local config = data["skillConfig"]
	if self.finish == false and ply.camp == -1 and config ~= nil and "skill3" == config.anim_name then
		self.finish = true
		local targets = self.mgr:getTargetData("self", "all")
		for i = 1, targets.Count do
			local target = targets:get(i - 1)
			target.bufMgr:addBuf(self.buffData, nil)
		end
	end
end

function M:gameover()
	M.super.gameover(self)
	EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})

end

return M