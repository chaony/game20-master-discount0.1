--毒液之爪
--武魂每次攻击有几率给敌对目标造成额外的中毒效果
---@class Relic_54 : Relic @
---@field super Relic @Relic
local M = class("Relic_54", Relic)

--伤害
M.atk = nil
--随机
M.prop = nil
--buf数据
M.buffData = {}
--持续时间
M.time = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.prop = self:getValue(1)
	self.atk =  self:getValue(2)
	self.time =  self:getValue(3)
end

function M:gameStart()
	M.super.gameStart(self)

	self.buffData =
	{
		["buffType"] = "Bleed",
		["buffDes"] = "",
		["workRound"] = self.time,
		["lastTime"] = 0,
		["workTime"] = 1,
		["delayTime"] = 0,
		["buffParam"] =
		{
			["damage"] = self.atk,
		},
		["buffEffect"] =
		{
		},
		["buffTags"] =
		{
			[1] = "debuff",
		},
	}

	EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end


function M:injureHandler(eventName, data)
	local victim = data["victim"]
	local killer = data["killer"]
	if killer ~= nil and victim ~= nil and victim.camp ~= 1 then
		local value = WRandom:randomNum(0, 100)
		if value < self.prop * 100 then
			victim.bufMgr:addBuf(self.buffData, killer)
		end
	end
end

function M:gameover()
	M.super.gameover(self)
	EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end

return M
