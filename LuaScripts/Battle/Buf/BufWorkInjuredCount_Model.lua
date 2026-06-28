---@class BufWorkInjuredCount_Model : BufWork_Model 受击计数，当达到计数后做某事
local M = class("BufWorkInjuredCount_Model", BufWork_Model)

function M:initFinish()
    self.count = self.playerBuf:checkParam("count", 0)
    self.type = self.playerBuf:checkParam("type", 1)

    self.injuredCnt = 0
    self.canTrigger = true

    if self.count <= 0 then
        Logger.logError(self.playerBuf.id, "BufWorkInjuredCount_Model 参数问题")
    end

    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.canTrigger then
        if self.playerBuf.player:equal(eventData.victim) then
            if eventData.wantdata.damage > 0 then
                self.injuredCnt = self.injuredCnt + 1
                self:checkTrigger()
            end
        end
    end
end

function M:checkTrigger()
    -- 受击次数达到
    if self.injuredCnt >= self.count then
        self.canTrigger = false
        if self.type == 1 then
            -- 移除本buff
            self.playerBuf.player.bufMgr:removeBuf(self.playerBuf)
        end
    end
end

function M:stop()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.stop(self)
end
return M