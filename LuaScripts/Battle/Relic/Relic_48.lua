--寒冰神符
--关键时刻拯救受到致命伤的英雄
---@class Relic_48 : Relic @
---@field super Relic @Relic
local M = class("Relic_48", Relic)

--生命恢复
M.hp = nil
--无敌时间
M.time = nil

M.bufData1 = nil

M.bufData2 = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.time = self:getValue(1)
	self.hp = self:getValue(2)

	self.bufData1 =
	{
		["buffType"] = "NoDeath",
		["buffDes"] = "",
		["workRound"] = 1,
		["lastTime"] = 0,
		["workTime"] = 0,
		["delayTime"] = 100,
		["buffParam"] =
		{
			["cureHp"] = self.hp,
		},
		["buffEffect"] =
		{
		},
		["buffTags"] =
		{
		},
	}

	self.bufData2 =
	{
		["buffType"] = "AddEffect",
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
                ["prefab"] = "fx_Relics_HuiXue_01",
                ["effectType"] = "startPlay",
                ["effectParent"] = "effectpoint0",
                ["isParent"] = true,
                ["effectDestroyTime"] = self.time,
            },
            [2] = 
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
		},
	}
end

function M:gameStart()
	M.super.gameStart(self)

	EventDispatcher:registerEvent("selfHp", {self,self.selfHpHandler})

	local friend = self.mgr:getTarget("self", "all")
	for i = friend.Count, 1, -1 do
		local friend_player = friend:get(i-1)
		friend_player.bufMgr:addBuf(self.bufData1, nil)
	end
end

function M:selfHpHandler(eventName, data)
	local ply = data["ply"]
	local hp = data["value"]
	if ply ~= nil then
		if ply.camp == 1 and hp <= 0 then
			local noDeath = ply.bufMgr:findBufByType("NoDeath")
			if table.nums(noDeath) > 0 then
				ply.bufMgr:addBuf(self.bufData2, nil)
			end
		end
	end
end

function M:gameover()
	M.super.gameover(self)
	EventDispatcher:unRegisterEvent("selfHp", {self,self.selfHpHandler})
end



return M
