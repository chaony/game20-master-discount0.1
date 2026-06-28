
--圣灵披风 战斗中的生命回复效果加15%

local Artifact4_2 = require("Battle.Artifact.Artifact4_2")

---@class Artifact4_5 : Artifact4_2 @
---@field super Artifact4_2 @Artifact4_2
local M = class("Artifact4_5", Artifact4_2)

M.lastCount = 0

function M:init(player,data)
    M.super.init(self, player, data)
    self.sethp = self:getValue(1)

    self.lastCount = 0
end

function M:gameStart()
    M.super.gameStart(self)
    EventDispatcher:registerEvent("selfHp", {self,self.conditionHandler})
end
--条件触发
function M:conditionHandler( eventName, data )
	local player = data["ply"]
   if self.player:equal(player) and self.player.data:isLive() then    
          
        local hpPercent = self.player.data:get_hp() * 0.05 



        local count = (self.player.data:get_hp() - self.player.data:get_curHp() ) / hpPercent
        if count >= 15 then
        	count = 15
        end
        
        if count ~= self.lastCount then
	        self.sethp = self.sethp + (count - self.lastCount) * 0.01  

	        self.player.data.hpRecover:addToMulList( self.sethp) 

		    self.lastCount = count
    	end


    end

end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("selfHp", {self,self.conditionHandler})
end
return M