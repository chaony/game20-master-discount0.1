--蛊惑权杖
--在战斗开始时，魅惑敌方前排持续2秒
---@class Relic_68 : Relic @
---@field super Relic @Relic
local M = class("Relic_68", Relic)

M.time = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.time = self:getValue(1)
	
	self.buffData =
	{
		["buffType"] = "Charm",
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
				["prefab"] = "fx_JiuWeiHu_skill1_02",
				["effectType"] = "startPlay",
				["effectParent"] = "head",
				["isParent"] = true,
				["effectDestroyTime"] = self.time,
			},
		},
		["buffTags"] =
		{
			[1] = "debuff",
		}
	}

	self.data =
	{
		["count"] = "frontrow",
		["camp"] = "enemy",
		["campRace"] = "not",
		["pos"] = "not",
		["profession"] = "all",
		["area"] = "all",
	}
end

function M:gameStart()
	M.super.gameStart(self)
	local targets = self.mgr:getTargetData(self.data)
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		ply.bufMgr:addBuf(self.buffData, nil)
	end
end

return M