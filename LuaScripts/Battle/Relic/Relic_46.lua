--复苏戒指
--战斗开始第15秒，使最虚弱的己方英雄恢复最大生命的30%
---@class Relic_46 : Relic @
---@field super Relic @Relic
local M = class("Relic_46", Relic)


--生命恢复
M.hp = nil
--计时
M.time = nil

M.timer = nil

M.data = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.hp = self:getValue(1)
	self.time = self:getValue(2)

	self.data =
	{
		["count"] = "one",
		["camp"] = "self",
		["pos"] = "bloodLeast",
		["race"] = "all",
		["profession"] = "all",
		["area"] = "all",
	}

	self.bufData =
	{
		["buffType"] = "AddEffect",
		["buffDes"] = "",
		["workRound"] = 1,
		["lastTime"] = 2,
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
                ["effectDestroyTime"] = 2,
            }
		},
		["buffTags"] =
		{
		},
	}

end

function M:gameStart()
	M.super.gameStart(self)
	self.timer = self.time
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
	
	if self.timer > 0 then
		self.timer = self.timer - dt
		if self.timer <= 0 then
			self.timer = 0
			
			local targets = self.mgr:getTargetData(self.data)

			for i=1,targets.Count do
				local ply = targets:get(i-1)
				if ply ~= nil then
					if ply:isLive() then
						ply:cure("hp", nil, self.hp)
						ply.bufMgr:addBuf(self.bufData, nil)
					end
				end				
			end	
		end		
	end	
end



return M
