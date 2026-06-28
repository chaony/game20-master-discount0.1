--能量水晶
--在本场战斗中英雄首次使用终极技能，可在5秒内回复大量能量（回复700）
---@class Relic_62 : Relic @
---@field super Relic @Relic
local M = class("Relic_62", Relic)

--时长
M.time = nil
--回复总量
M.totalAnger = nil

M.plyList = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.time = self:getValue(1)
	self.totalAnger = self:getValue(2)
end

function M:gameStart()
	M.super.gameStart(self)
	EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
	self.plyList = Battle.ListMap.new()
end

--技能释放
function M:SkillEnterHandler( eventName, data )
	local ply = data["player"]
	local config = data["skillConfig"]
	if ply.camp == 1 and config ~= nil and "skill3" == config.anim_name and self.plyList[ply] == nil then
		self.plyList:add(ply, self.time)
	end
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
	for i = 1, self.plyList.list.Count do
		local k = self.plyList.list:get(i-1)
		local v = self.plyList:get(k)
		if k:isLive() and 	v > 0 then
			self.plyList[k] = v - dt
			k.angerData:addAnger(self.totalAnger/self.time * dt)
		end
	end
end

function M:gameover()
	M.super.gameover(self)
	EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})

end

return M