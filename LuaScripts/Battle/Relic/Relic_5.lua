--蛛丝手套
--战斗开始时用蛛丝缠绕敌方全体3.5秒，如受到一定伤害（暂定为敌方血量10%）会提前解除
---@class Relic_5 : Relic @
---@field super Relic @Relic
local M = class("Relic_5", Relic)

--缠绕时长
M.time = nil
--解除伤害
M.hp = nil

M.bufData = nil

M.bufList = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.time = self:getValue(1)
	self.hp = self:getValue(2)
	
	self.bufList = Battle.ListMap.new()
	self.bufData = 
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
		},
		["buffTags"] =
		{
			[1] = "debuff",
		},
	}
end

function M:gameStart()
	M.super.gameStart(self)
end

function M:spawnFinish()
	M.super.spawnFinish(self)
	local targets = self.mgr:getTarget("enemy", "all")
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		local buf = ply.bufMgr:addBuf(self.bufData, nil)
		if buf ~= nil then
			self.bufList:add(ply.index, buf)
		end
	end
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
	if self.bufList.list.Count > 0 then
		for i = 1, self.bufList.list.Count do
			local k = self.bufList.list:get(i-1)
			local v = self.bufList:get(k)
			if v ~= nil then
				if v.mState ~= -1 then
					if v.player.data:get_curHp() / v.player.data:get_hp() < (1 - self.hp) then
						v.player.bufMgr:removeBuf(v)
						self.bufList[k] = nil
					end
				else
					self.bufList[k] = nil
				end
			end
		end
	end
end

return M