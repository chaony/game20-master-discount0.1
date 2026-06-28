--击杀敌人获得奖励
---@class BufWorkKillReward : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkKillReward", BufWork_Model)


function M:initFinish()
    self.data = {}
    self.data["buffType"] = "Data"
    self.data["workRound"] = 1
    self.data["lastTime"] = self.playerBuf:checkParam("time", 0)
    self.data["workTime"] = 0
    self.data["buffTags"] = {"buff"}
    self.data["buffEffect"] = {}
    self.data["buffParam"] = table.copy(self.playerBuf.param)
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
end

function M:killerPlayerHandler(eventName, data)
    local victim = data["victim"]
    local killer = data["killer"]
    if killer == self.playerBuf.player or victim == self.playerBuf.player:get_enemy() then
        self.playerBuf.player.bufMgr:addBuf(self.data, self.playerBuf.player)
    end
end

function M:stop()
    M.super.stop(self)
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
end

return M