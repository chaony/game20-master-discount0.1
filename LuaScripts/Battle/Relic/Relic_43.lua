--大魔术法典
--智力型武魂伤害增加15%
---@class Relic_43 : Relic @
---@field super Relic @Relic
local M = class("Relic_43", Relic)

--伤害增加
M.atk = nil



function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.atk = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	
    local data =
	{
		["count"] = "all",
		["camp"] = "self",
		["pos"] = "not",
		["race"] = "all",
		["profession"] = "fashi",
		["area"] = "all",
	}
	local targets = self.mgr:getTargetData(data)

	for i=1,targets.Count do
		local ply = targets:get(i-1)
		self:dealWithData(ply, "physicaldamage", 1)
		self:dealWithData(ply, "magicdamage", 1)
	end
end

return M
