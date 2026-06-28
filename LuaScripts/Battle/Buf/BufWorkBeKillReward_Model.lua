--被击杀对方获得奖励
---@class BufWorkBeKillReward : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkBeKillReward", BufWork_Model)


function M:initFinish()
    self.buffIds = self.playerBuf:checkParam("buffId", 0)
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
end

function M:killerPlayerHandler(eventName, data)
    local victim = data["victim"]
    local killer = data["killer"]
    if victim:equal(self.playerBuf.player) then
        if type(self.buffIds) == "table" then
            for k,v in ipairs(self.buffIds) do
                killer.bufMgr:addBufById(v, self.playerBuf.source)
            end
        elseif type(self.buffIds) == "number" then
            killer.bufMgr:addBufById(self.buffIds, self.playerBuf.source)
        end
    end
end

function M:stop()
    M.super.stop(self)
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
end

return M