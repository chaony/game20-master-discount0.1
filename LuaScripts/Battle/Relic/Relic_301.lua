--力量型武神，在战斗前{x}秒，造成的伤害提升{y}%，受伤怒气增加{z}%
---@class Relic_301 : Relic @
---@field super Relic @Relic
local M = class("Relic_301", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.bufId = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)
	--力量型英雄
	local players = self.mgr:getTarget("self", "all")
	for i=1,players.Count do
		local ply = players:get(i-1)
		if ply.plyData.type == self.data.hero_type then
			ply.bufMgr:addBufById(self.bufId, ply)
			self:playEffect(ply)
		end
	end
end

return M