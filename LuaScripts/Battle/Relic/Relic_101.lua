--远程武神，伤害增加{x}%，且命中增加{y}，持续{z}秒
---@class Relic_101 : Relic @
---@field super Relic @Relic
local M = class("Relic_101", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.bufId = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	local players = self.mgr:getTarget("self", "all")
	for i=1,players.Count do
		local ply = players:get(i-1)
		if self:hasRoleType(ply.plyData.role_type) then
			ply.bufMgr:addBufById(self.bufId, ply)
			self:playEffect(ply)
		end
	end
end

return M