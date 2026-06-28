--诅咒勾玉
--战斗开始10秒敌方受到伤害会所有敌对目标溅射15%伤害
---@class Relic_6 : Relic @
---@field super Relic @Relic
local M = class("Relic_6", Relic)

--缠绕时长
M.time = nil
--伤害
M.damage = nil

M.timer = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.time = self:getValue(1)
	self.damage = self:getValue(2)
end

function M:gameStart()
	M.super.gameStart(self)	
	self.timer = self.time
	EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
	if self.timer > 0 then
		self.timer = self.timer - dt
		if self.timer <= 0 then
			EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
		end
	end
end

function M:injureHandler(eventName, data)
	local killer = data["killer"]
	local victim = data["victim"]
	local wantdata = data["wantdata"]
	
	if victim ~= nil and victim.camp == -1 then
		local targets = self.mgr:getTarget("enemy", "all")
	   
		for i = 1, targets.Count do
			local ply = targets:get( i - 1)
			if ply:equal(victim) == false then
				local dmg_data = {}
				dmg_data["damage"] = wantdata["damage"] * self.damage
				dmg_data["suck_value"]  = 0
				ply:beHitDirect(killer, data["attackData"], dmg_data, false, false)
			end
		end
	end
end

function M:gameover()
	M.super.gameover(self)
	EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end

return M