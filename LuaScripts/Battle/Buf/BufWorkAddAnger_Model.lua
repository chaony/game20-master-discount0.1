---@class BufWorkAddAnger_Model : BufWork_Model 怒气增加
local M = class("BufWorkAddAnger_Model", BufWork_Model)

function M:initFinish()
    self.value = self.playerBuf:checkParam("anger", 0)
    --1：fix，2：curAnger
    self.type = self.playerBuf:checkParam("type", 1)
end

function M:work()
    M.super.work(self)
    local value = self.value
    if self.type == 2 then
        value = GlobalTools:Mul(value, self.playerBuf.player.data:get_curAnger())
    end
    value = GlobalTools:Mul(value, self.playerBuf.player.data.rageregenper:getValue())
    if self.playerBuf.player:get_master() == nil then
        self.playerBuf.player.data:addAnger(value, true)
    end
end

return M