---@class TimeTask @
local M = class("TimeTask")

--时间
M.time = 0

--计时结束时候回调
M.finishHandler = nil

--Time.Scale 任务控制
M.isUnScaleDelta = false

--是否开始任务
M.isStart = false;

--最大时间
M.maxTime = 0;

--当前时间
M.curTime = 0;

-- 是否是循环任务
M.isLoop = false

   
--开始任务
function M:start()
    self.isStart = true
    self.maxTime = self.time
    self.curTime = self.maxTime
    if self.timeScale ~= nil then
        TimeManager:set_timeScale(self.timeScale)
    end
end

-- 如果是循环任务，那么就要重新开始任务
function M:startIfLoop()
    if self.isLoop then
        self.isStart = true
        self.curTime = self.maxTime
    end
end

--更新任务
function M:update_dt(dt)
    if self.isStart then 
        if self.curTime > GlobalTools.base0 then
            self.curTime = self.curTime - dt
        end

        if self.curTime <= GlobalTools.base0 then
            self.isStart = false
            if self.finishHandler ~= nil then
                self:finishHandler()
            end
            self:startIfLoop()
        end
    end
end

function M:update_unsdt(unsdt)
    if self.isStart then
        if self.curTime > GlobalTools.base0 then
            self.curTime = self.curTime - unsdt
        end

        if self.curTime <= GlobalTools.base0 then
            self.isStart = false
            if self.finishHandler ~= nil then
                self:finishHandler()
            end
            self:startIfLoop()
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