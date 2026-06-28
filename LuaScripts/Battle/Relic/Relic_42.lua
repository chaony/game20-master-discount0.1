--嗜血之抓
--已方武魂杀敌时，自身恢复16生命
---@class Relic_42 : Relic @
---@field super Relic @Relic
local M = class("Relic_42", Relic)

--恢复生命
M.hp = nil



function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	self.hp = self:getValue(1)
end

function M:gameStart()
	M.super.gameStart(self)

	EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
end

function M:killerPlayerHandler(eventName, data)
    local killer = data["killer"]
    if killer ~= nil then
    	if killer.camp == 1 then
	        killer:cure("hp", nil,self.hp)
    	end
    end
end

function M:gameover()
	 M.super.gameover(self)
	EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
end

return M
