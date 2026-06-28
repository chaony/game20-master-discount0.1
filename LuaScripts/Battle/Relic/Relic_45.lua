--钢铁护甲
--力量型防御增加10% 每秒生命恢复
---@class Relic_45 : Relic @
---@field super Relic @Relic
local M = class("Relic_45", Relic)

--防御
M.def = nil
--每秒生命恢复
M.hp = nil

M.targets = nil
function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.def = self:getValue(1)
	self.hp = self:getValue(2)
end

function M:gameStart()
	M.super.gameStart(self)
	
    local data =
	{
		["count"] = "all",
		["camp"] = "self",
		["pos"] = "not",
		["race"] = "all",
		["profession"] = "strength",
		["area"] = "all",
	}
	self.targets = self.mgr:getTargetData(data)

	if self.targets ~= nil then
		for i=1,self.targets.Count do
			local ply = self.targets:get(i-1)
			self:dealWithData(ply, "def", 1)
		end
	end
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)

	if self.hp > 0 and self.targets ~= nil then
		for i=1,self.targets.Count do
			local ply = self.targets:get(i-1)
			if ply:isLive() and ply.data:get_curHp() < ply.data:get_hp() then
				ply:cure("hp", nil, self.hp,true)
			end
		end
	end
	

end



return M
