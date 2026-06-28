--免疫死亡(不死但掉血)
---@class BufWorkNoDeath : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkNoDeath", BufWork_Model)


function M:initFinish()
    self.canUse = true
    self.buffId = self.playerBuf:checkParam("buffId", 0)
    self.useCallBack = {}
end

function M:use()
    if self.canUse then
        self.playerBuf.curDelayTime = 0
        table.insert(self.playerBuf.tag, "buff")
        self.playerBuf.player.bufMgr:addBufById(self.buffId, self.playerBuf.source)
        for k,v in ipairs(self.useCallBack) do
            v()
        end
        self.canUse = false
    end
end

function M:stop()
    M.super.stop(self)
end

return M