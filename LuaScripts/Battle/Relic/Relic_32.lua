--协同作战
--前排都阵亡前，后排受到伤害下降50%
---@class Relic_32 : Relic @
---@field super Relic @Relic
local M = class("Relic_32", Relic)

--减伤
M.atd = nil
M.res = nil

M.frontTargets = nil
function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.atd = self:getValue(1)
	self.res = self:getValue(1)

end

function M:gameStart()
	M.super.gameStart(self)
	
	self.frontTargets = self.mgr:getTarget("friend","frontrow")
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
	
	if self.frontTargets ~= nil then
		local index = 0
		for i = 1, self.frontTargets.Count  do
			local ply_front = self.frontTargets:get(i-1)

			if ply_front:isLive()  then
				index = index +1
			end
		end
		if index <= 0 then
			local backTargets = self.mgr:getTarget("friend","backrow")

			for i = 1, backTargets.Count  do
				local ply_back = backTargets:get(i-1)
				if ply_back.data:get_curHp() > 0 then
					self:dealWithData(ply_back, "atd", 1)
					self:dealWithData(ply_back, "res", 1)
					self.frontTargets = nil
				end
			end
		end
		
	end

	
end

return M