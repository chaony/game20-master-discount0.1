--亡灵法典
--异族的英雄技能CD减10% 每秒恢复15点怒气
---@class Relic_38 : Relic @
---@field super Relic @Relic
local M = class("Relic_38", Relic)

--CD
M.post_cd = nil

--每秒恢复怒气
M.restore_anger = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.post_cd = self:getValue(1)
	self.restore_anger = self:getValue(2)

end

function M:gameStart()
	M.super.gameStart(self)
	local players = self.mgr:getTarget("self", "all")


	for i=1,players.Count do
		local ply = players:get(i-1)
		if ply.plyData.race == 4 then
			self:dealWithData(ply, "cdup", 1)
			self:dealWithData(ply, "restore_anger", 2)
		end
	end
end

return M