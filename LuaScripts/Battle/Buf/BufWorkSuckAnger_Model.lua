--吸怒气
---@class BufWorkSuckAnger_Model : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkSuckAnger_Model", BufWork_Model)


function M:initFinish()
end

function M:work()
    M.super.work(self)
    local anger = self.playerBuf:checkParam("perSuckValue", GlobalTools.base0)
    local cur_anger = self.playerBuf.player.data:get_curAnger()
    if anger ~= 0 then
        if anger > cur_anger then
            anger = cur_anger
        end
    else
        local angerPer = self.playerBuf:checkParam("perSuckPercent", GlobalTools.base0)
        if angerPer ~= 0 then
            anger = GlobalTools:Mul(cur_anger,angerPer)
        end
    end

    if anger > 0 then
        self.playerBuf.player.data:addAnger( -anger, true )
        self.playerBuf.source.data:addAnger( anger, true )
    end

end

function M:stop()
    M.super.stop(self)
end

return M