------------------- EventManager
---@class EventManager
local M = class("EventManager")

function M:init()
    --全局发送器
    self.sender = require("Battle.Evt.EventSender").new()
    self.sender:init();
end

--注册视图和数据层
function M:register(view, model)
    local sender = require("Battle.Evt.EventSender").new()
    sender:init();
    if view ~= nil then
        view:setLocalSender(sender);
        view:setWorldSender(self.sender);
    end
    model:setLocalSender(sender);
    model:setWorldSender(self.sender);
end

--全局监听事件
function M:addEventListener(eventName, listener)
    if self.sender ~= nil then
        self.sender:addEventListener(eventName, listener)
    end
end

--全局删除事件
function M:removeEventListener(eventName, listener)
    if self.sender ~= nil then
        self.sender:removeEventListener(eventName, listener)
    end
end

--发送全局事件
function M:dispatchEvent(eventName, data)
    if self.sender ~= nil then
        self.sender:dipatchEvent(eventName, data)
    end
end

return M
