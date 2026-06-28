--控制时间的工具
TimeTools = {}

TimeTools.tasklist = nil

TimeTools.curRecoverTime = 0

TimeTools._callBack = nil

function TimeTools:init()
    TimeTools.blackTime = 0;
    TimeTools.tasklist_unity = Battle.List.new()
    TimeTools.tasklist = Battle.List.new()
    TimeTools.tasklistRecover = Battle.List.new()
end

function TimeTools:killAll()
    TimeTools.tasklist:clear()
    TimeTools.tasklistRecover:clear();
    TimeTools.tasklist_unity:clear();
end

function TimeTools:killModel()
    TimeTools.tasklist:clear()
end

function TimeTools:killView()
    TimeTools.tasklist_unity:clear()
end

--视图层延迟时间使用
function TimeTools:delayTimeUnity(time, finish)
    local task = require("BattleView.Tool.TimeTask_View").new()
    task.time = time
    task.finishHandler = finish
    task:start()
    TimeTools.tasklist_unity:add(task);
    return task;
end

--延迟时间
--time
--finish
function TimeTools:delayTime(time, finish)
    local task = require("Battle.Tool.TimeTask").new()
    --把时间转换成定点数
    task.time = time
    task.finishHandler = finish
    task:start()
    TimeTools.tasklist:add(task);
    -- Logger.log(TimeTools.tasklist, " 加入任务 ")
    return task;
end


--删除一个任务
function TimeTools:stopTask(task)
    TimeTools.tasklist:remove(task)
end


--改变 TimeScale
function TimeTools:setTimeScale(timeScale, recoverTime,callBack)
    local task = require("Battle.Tool.TimeTask").new()
    task.timeScale = timeScale
    task.time = recoverTime
    task.finishHandler = callBack
    task:start()
    TimeTools.tasklistRecover:add(task);
    return task;
end

--- 创建一个定时任务，当任务
---@return TimeTask
function TimeTools:startOneDtTask(time, callback, isLoop)
    local task = require("Battle.Tool.TimeTask").new()
    task.time = time
    task.finishHandler = callback
    task.isLoop = isLoop
    task:start()
    return task
end

--- 创建一个定时循环任务，当任务
---@return TimeTask
function TimeTools:startOneLoopTask(time, callback)
    return self:startOneDtTask(time, callback, true)
end

--不受TimeScale限制
function TimeTools:update_unsdt(unsdt)
    if TimeTools.tasklistRecover ~= nil then
        --Logger.log(TimeTools.tasklist," ~~~~~~~~~~~~~~~~~~~~~~~~~ update "..TimeTools.tasklist.Count)
        for i = TimeTools.tasklistRecover.Count,1,-1 do
            local task = TimeTools.tasklistRecover:get(i-1)
            if task ~= nil then
                if task.isStart == false then
                    TimeTools.tasklistRecover:removeAt(i-1);   
                else
                    task:update_unsdt(unsdt)
                end
            else
               Logger.log(" task == nil ")
            end
        end
    end

    if TimeTools.blackTime > 0 then
        TimeTools.blackTime  = TimeTools.blackTime - unsdt;
        if TimeTools.blackTime <= 0 then
            TimeTools._callBack();
        end
    end
end


--更新时间
function TimeTools:update_dt(dt)
    if TimeTools.tasklist ~= nil then
        for i = TimeTools.tasklist.Count,1,-1 do
            local task = TimeTools.tasklist:get(i-1)
            if task ~= nil then
                if task.isStart == false then
                    TimeTools.tasklist:removeAt(i-1);   
                else
                    task:update_dt(dt)
                end
            else
               Logger.log(" task == nil ")
            end
        end
    end
end


--更新时间
function TimeTools:update_dt_unity(dt)
    if TimeTools.tasklist_unity ~= nil then
        for i = TimeTools.tasklist_unity.Count,1,-1 do
            local task = TimeTools.tasklist_unity:get(i-1)
            if task ~= nil then
                if task.isStart == false then
                    TimeTools.tasklist_unity:removeAt(i-1);
                else
                    task:update_dt(dt)
                end
            else
                Logger.log(" task == nil ")
            end
        end
    end
end 

return TimeTools