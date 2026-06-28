--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-01-19 16:09:28
]]

---@class EventSender 事件类型
local M = class("EventSender")

function M:init()
    self.event_list = {}
end

--加入事件监听
function M:addEventListener(eventName, listener)
    if listener == nil then
        return;
    end
    
    local temp = self.event_list[eventName];
    if temp == nil then
        temp = {}
        self.event_list[eventName] = temp;
    end

    local exit = false
    for i = 1, #temp do
        exit = self:isEqual(listener, temp[i])
        if exit then
            break
        end
    end

    --- 没有找到, 那么加入到队列中
    if not exit then
        table.insert(temp, listener)
    end
end

--删除事件
function M:removeEventListener(eventName, listener)
    local temp = self.event_list[eventName]
    if temp == nil then return end
    for i,v in ipairs(temp) do
        if self:isEqual(listener, temp[i]) then
            temp[i] = nil
            break
        end
    end
end

--是否有某个事件
function M:hasEvent( eventName )
    local temp = self.event_list[eventName]
    return temp ~= nil;
end


--发送事件
function M:dipatchEvent(eventName, data)
    if eventName == nil then return end
    local listeners = self.event_list[eventName] or {}
    for k, v in ipairs(listeners) do
        self:_notify(v, eventName, data)
    end
end

--通知事件监听主体, 内部方法
function M:_notify(listener, event, data)
    if listener == nil then return end
    local listenerType = type(listener)
    if listenerType == "function" then
        listener(event, data)
    elseif listenerType == "table" then
        if listener and listener[2] and listener[1] then
            listener[2](listener[1], event, data)
        end
    end
end


--是否是同一个监听者
function M:isEqual(data, data1)
    if data == nil or data1 == nil then return false end
    local tmp = type(data)
    local tmp1 = type(data1)
    if tmp == tmp1 then
        if tmp == "function" then  -- 如果是方法
            return data == data1
        else
            return data[1] == data1[1]
        end
    else
        return false
    end
end


return M