
--希望号角 每秒获得16点能量 死亡后平均分给队友
local Artifact3_2 = require("Battle.Artifact.Artifact3_2")

---@class Artifact3_5 : Artifact3_2 @
---@field super Artifact3_2 @Artifact3_2
local M = class("Artifact3_5", Artifact3_2)

function M:init(player,data)
    M.super.init(self, player, data)
    self.energy = self:getValue(1)
end


function M:gameStart()
    M.super.gameStart(self)
    EventDispatcher:registerEvent("PlayerDead", {self,self.deadHandler})
end

--死亡回调
function M:deadHandler( eventName, data )
    local player = data["data"]
    if player:equal(self.player) then
    	local self_curAngre = player.data:get_curAnger()
        local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
		local friendCount = friends.Count - 1
        if friendCount > 0 then
        	local angre = self_curAngre / friendCount
	        for i = friends.Count, 1, -1 do
	            local friend_player = friends:get(i-1)
				if friend_player:equal(self.player) == false then
					friend_player.data:addAnger( angre )
				end
	        end
        end
        
    end
end

function M:destroy()
	M.super.destroy(self)
	EventDispatcher:unRegisterEvent("PlayerDead", {self,self.deadHandler})
end

return M