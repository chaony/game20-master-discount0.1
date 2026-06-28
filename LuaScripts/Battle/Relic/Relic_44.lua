--野兽之抓
--敏捷型武魂吸血增加10%
---@class Relic_44 : Relic @
---@field super Relic @Relic
local M = class("Relic_44", Relic)

--吸血
M.leeching = nil



function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.leeching = self:getValue(1)

end

function M:gameStart()
	M.super.gameStart(self)
	
    local data =
	{
		["count"] = "all",
		["camp"] = "self",
		["pos"] = "not",
		["race"] = "all",
		["profession"] = "agility",
		["area"] = "all",
	}
	local targets = self.mgr:getTargetData(data)

	if targets ~= nil then
		for i=1,targets.Count do
			local ply = targets:get(i-1)
			self:dealWithData(ply, "leeching", 1)
		end
	end
end

return M
