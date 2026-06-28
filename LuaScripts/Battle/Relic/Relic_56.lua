--死神雕像
--敌方血量低于15% 直接斩杀
---@class Relic_56 : Relic @
---@field super Relic @Relic
local M = class("Relic_56", Relic)

--血量百分比
M.hp = nil


function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.hp =  self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)

	local data =
	{
		["count"] = "all",
		["camp"] = "enemy",
		["pos"] = "not",
		["race"] = "all",
		["profession"] = "all",
		["area"] = "all",
	}
	self.targets  = self.mgr:getTargetData(data)
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
	if self.targets ~= nil then
		for i=1,self.targets.Count do
			local ply = self.targets:get(i-1)
			if ply:isLive() then
				local value = ply.data:get_hp() * self.hp
				if ply.data:get_curHp() < value  then
					ply:setHp(0)
		
					ply:dead();
				end
			end
		end
	end
end

return M
