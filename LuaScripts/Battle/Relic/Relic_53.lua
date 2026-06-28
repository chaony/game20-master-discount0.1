--雷电符咒
--武魂每次攻击有几率给敌对目标造成额外的真实伤害
---@class Relic_53 : Relic @
---@field super Relic @Relic
local M = class("Relic_53", Relic)

--伤害
M.atk = nil
M.prop = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, data)
	self.prop = self:getValueSimple(1)
	self.atk =  self:getValue(2)
end

function M:gameStart()
	M.super.gameStart(self)
	EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:update(dt, unsdt)
	M.super.update(self, dt, unsdt)
end


function M:injureHandler(eventName, data)
	local victim = data["victim"]
	local killer = data["killer"]
	if victim ~= nil and victim ~= nil and victim.camp ~= 1 then
		local value = WRandom:randomNum(0, 100)
		if value < self.prop * 100 then
			local wantData = {}
			wantData["damage"] = self.atk * killer.data.atk:getValue()
			victim:beHitDirect(nil, nil, wantData, false, false)
		end
	end
end

function M:gameover()
	M.super.gameover(self)
	EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end

return M
