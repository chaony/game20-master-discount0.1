---@class TimeTask_View @
local M = class("TimeTask_View")


--时间
M.time = 0

--计时结束时候回调
M.finishHandler = nil

--Time.Scale 任务控制
M.isUnScaleDelta = false

--是否开始任务
M.start = false;

--最大时间
M.maxTime = 0;

--当前时间
M.curTime = 0;

   
--开始任务
function M:start()
    self.isStart = true
    self.maxTime = self.time
    self.curTime = self.time
    if self.timeScale ~= nil then
        TimeManager:set_timeScale(self.timeScale)
    end
end

--更新任务
function M:update_dt(dt)
    if self.isStart then 
        if self.curTime > 0 then
            self.curTime = self.curTime - dt
        end

        if self.curTime <= 0 then
            self.isStart = false
            if self.finishHandler ~= nil then
                self:finishHandler()
            end
        end
    end
end

function M:update_unsdt(unsdt)
    if self.isStart then 
        if self.curTime > 0 then
            self.curTime = self.curTime - unsdt
        end

        if self.curTime <= 0 then
            self.isStart = false
            if self.finishHandler ~= nil then
                self:finishHandler()
            end
        end
    end
end

function M:timeTaskFinish()
    self.isStart = false
    if self.finishHandler ~= nil then
        self:finishHandler()
    end
end

return M