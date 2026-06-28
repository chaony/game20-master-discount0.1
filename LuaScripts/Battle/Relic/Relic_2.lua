--风骨之剑
--攻击时有几率削弱对手防御力，同时拥有屠龙之剑之剑，降低的属性变为伤害者的属性提升
---@class Relic_2 : Relic @
---@field super Relic @Relic
local M = class("Relic_2", Relic)

M.prop = nil

M.defReduce = nil

M.count = 0
function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.prop = self:getValue(2)
	self.defReduce = 1
end

function M:gameStart()
	M.super.gameStart(self)
	self.count = 0
	self.players = {}
	EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:injureHandler(eventName, data)
	local value = WRandom:randomNum(0, 100)
	local killer = data["killer"]
	local victim = data["victim"]
	local prop_value = GlobalTools:Mul(self.prop, GlobalTools.base100)
	local instanceId = victim.playerInstanceId
	if killer ~= nil and killer:get_camp() == self:get_camp() and value < prop_value and instanceId ~= nil and self.players[instanceId] == nil then
		self:dealWithData(victim, "def", self.defReduce, "reduce")
		self.count = self.count + 1
		self.players[instanceId] = 1
		
		if self.mgr:findById(1) ~= nil then
			self:dealWithData(killer, "def", self.defReduce)
		end
	end
end

function M:gameover()
	M.super.gameover(self)
	self.players = {}
	EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end

return M