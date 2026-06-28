--多宝如意
--战斗开始给前排侠客提高自身血量上限，如前排侠客是坦克职业提升60%，如前排是战士提升40%，其他职业则提升20%，维持时间5秒
---@class Relic_405 : Relic @
---@field super Relic @Relic
local M = class("Relic_405", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	--坦克职业提升60%的BUFF
	self.bufId1 = self:getValue(1)
	--战士提升40%的BUFF
	self.bufId2 = self:getValue(2)
	--其他职业则提升20%的BUFF
	self.bufId3 = self:getValue(3)
end

function M:gameStart()
	M.super.gameStart(self)
	local targets = self.mgr:getTarget("self","frontrow")
	for i = 1, targets.Count  do
		---@type PlayerModel
		local ply = targets:get(i-1)
		local bufId = self.bufId3
		if ply.plyData.role_type == 1 then --护卫
			bufId = self.bufId1
		elseif ply.plyData.role_type == 2 then --战士
			bufId = self.bufId2
		end
		ply.bufMgr:addBufById(bufId, ply)
		self:playEffect(ply)
	end
end

return M