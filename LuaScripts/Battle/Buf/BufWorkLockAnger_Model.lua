--锁定怒气
---@class BufWorkLockAnger : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkLockAnger", BufWork_Model)

function M:initFinish()
    self.isAdd = self.playerBuf:checkParam("isAdd", 1) == 1 --1 是锁定增加 0是锁定减少
    if self.isAdd then
        self.playerBuf.player.data:setAngerLockAdd(true) --锁定怒气
    else
        self.playerBuf.player.data:setAngerLockReduce(true) --锁定怒气
    end
end

function M:stop()
    M.super.stop(self)
    if self.isAdd then
        if self.playerBuf.player.plyType == "W_LvB" then
            local W_LvB_skill3 = self.playerBuf.player.bufMgr:findBufByTag("LvB_Skill3")
            if table.nums(W_LvB_skill3) > 0 then
            else
                self.playerBuf.player.data:setAngerLockAdd(false) --锁定怒气
            end
        else
            self.playerBuf.player.data:setAngerLockAdd(false) --锁定怒气
        end
    else
        self.playerBuf.player.data:setAngerLockReduce(false) --锁定怒气
    end
end

return M