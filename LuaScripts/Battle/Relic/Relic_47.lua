--复仇神像
--已方英雄死亡时，将其余存活的英雄全属性提升至战斗结束
---@class Relic_47 : Relic @
---@field super Relic @Relic
local M = class("Relic_47", Relic)
--防御
M.def = nil
--攻击
M.atk = nil
function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	--self.def = self:getValue(1)
	--self.atk = self:getValue(2)
end

function M:gameStart()
	M.super.gameStart(self)
	EventDispatcher:registerEvent("PlayerDead", {self,self.deadHandler})
end

function M:deadHandler( eventName, data )
    local player = data["data"]
    if player.camp == 1 then
        local friend = self.mgr:getTarget("self", "all")

		for i = friend.Count, 1, -1 do
            local friend_player = friend:get(i-1)
            if friend_player:isLive() then
				self:dealWithData(friend_player, "def", 3)
				self:dealWithData(friend_player, "atk", 2)

				local rate = friend_player.data:get_curHp() / friend_player.data:get_hp()
				self:dealWithData(friend_player, "hp", 1)
				friend_player:setHp(friend_player.data:get_hp() * rate)

				
            end
        end
    end
end

function M:gameover()
	M.super.gameover(self)
	EventDispatcher:unRegisterEvent("PlayerDead", {self,self.deadHandler})
end

return M
