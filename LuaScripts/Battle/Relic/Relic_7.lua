--时间沙漏
--战斗开始时己方获得6秒加速
---@class Relic_7 : Relic @
---@field super Relic @Relic
local M = class("Relic_7", Relic)

--加速时长
M.time = nil
--加速倍数
M.speed = nil

M.bufData = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.time = self:getValue(1)
	self.speed = self:getValue(2)
	
	self.bufData =
	{
		["buffType"] = "SpeedUp",
		["buffDes"] = "",
		["workRound"] = 1,
		["lastTime"] = self.time,
		["workTime"] = 0,
		["delayTime"] = 0,
		["buffParam"] =
		{
			["speed"] = self.speed,
		},
		["buffEffect"] =
		{
		},
		["buffTags"] =
		{
			[1] = "buff",
		},
	}
end

function M:gameStart()
	M.super.gameStart(self)
	local targets = self.mgr:getTarget("self", "all")

	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		ply.bufMgr:addBuf(self.bufData, nil)
	end
end

return M