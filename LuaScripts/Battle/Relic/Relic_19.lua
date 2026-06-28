--急速之靴
--闪避+20
---@class Relic_19 : Relic @
---@field super Relic @Relic
local M = class("Relic_19", Relic)

--内外伤减伤
M.dodge = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.dodge = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	local targets = self.mgr:getTarget("self", "all")
	for i = 1, targets.Count do
		local ply = targets:get(i - 1)
		self:dealWithData(ply, "dodge", 1)
	end
end

return M