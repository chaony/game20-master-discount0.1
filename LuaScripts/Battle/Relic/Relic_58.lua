--追击号角
--每次击败敌方武魂，战场上所有己方武魂获得全属性提升到获得结束
---@class Relic_58 : Relic @
---@field super Relic @Relic
local M = class("Relic_58", Relic)

--生命提升
M.hp = nil
--攻击提升
M.atk = nil
--防御提升
M.def = nil

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	self.hp = self:getValue(1)
	self.atk = self:getValue(2)
	self.def = self:getValue(3)
end

function M:gameStart()
	M.super.gameStart(self)
	EventDispatcher:registerEvent("killPlayer", {self,self.killPlayerHandler})
end

--技能开始
function M:killPlayerHandler( eventName, data )
	local killer = data["killer"]
	local victim = data["victim"]
	if victim.camp == -1 then
		local targets = self.mgr:getTarget("self", "all")
		for i = 1, targets.Count do
			local target = targets:get(i - 1)
			self:dealWithData(target, "atk", 2)

			self:dealWithData(target, "def", 3)
			
			local rate = target.data:get_curHp() / target.data:get_hp()
			self:dealWithData(target, "hp", 1)

			target:setHp(target.data:get_hp() * rate)

			
		end
	end
end

function M:gameover()
	M.super.gameover(self)
	EventDispatcher:unRegisterEvent("killPlayer", {self,self.killPlayerHandler})

end

return M