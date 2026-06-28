---@class BaseAll 所有数据类的基础类
---@field localEventSender EventSender 本地发送器
---@field worldEventSender EventSender 全局发送器
local M = class("BaseAll")

--初始化数据
function M:init()
	
end

--设定本地发送器
function M:setLocalSender( sender )
	self.localEventSender = sender;
end

--设定全局发送器
function M:setWorldSender( sender )
	self.worldEventSender = sender;
end

--加入本地监听器
function M:addEventListener_Local(eventName, listener)
	if self.localEventSender ~= nil then
		self.localEventSender:addEventListener(eventName, listener)
	else
		if GameVersionConfig.IS_SERVER == false then
			Logger.logError(eventName," 本地监听器还没有初始化已经开始监听事件了 ~~ ")
		end
	end
end

--删除本地监听器
function M:removeEventListener_Local(eventName, listener)
	if self.localEventSender ~= nil then
		self.localEventSender:removeEventListener(eventName, listener)
	else
		if GameVersionConfig.IS_SERVER == false then
			Logger.logError(eventName, " 本地监听器还没有初始化已经开始移除事件了 ~~")
		end
	end
end

--发送本地事件
function M:dispatchEvent_Local(eventName, data, callBack)
	if self.localEventSender ~= nil then
		if self.localEventSender:hasEvent(eventName) then
			self.localEventSender:dipatchEvent(eventName, data)
		else
			Logger.logError(eventName, " 还有没有注册事件 ~~ ")
		end
	else
		if callBack ~= nil then
			callBack();
		end
		if GameVersionConfig.IS_SERVER == false then
			Logger.logError(eventName, " 本地监听器还没有初始化已经开始发送事件了 ~~ ")
		end
	end
end


--加入全局监听器
function M:addEventListener_World(eventName, listener)
	if self.worldEventSender ~= nil then
		self.worldEventSender:addEventListener(eventName, listener)
	else
		if GameVersionConfig.IS_SERVER == false then
			Logger.logError(" 全局监听器还没有初始化已经开始监听事件了 ~~")
		end
	end
end

--删除全局监听器
function M:removeEventListener_World(eventName, listener)
	if self.worldEventSender ~= nil then
		self.worldEventSender:removeEventListener(eventName, listener)
	else
		if GameVersionConfig.IS_SERVER == false then
			Logger.logError(eventName, " 全局监听器还没有初始化已经开始移除事件了 ~~")
		end
	end
end

--发送全局事件
function M:dispatchEvent_World(eventName, data, callBack)
	if self.worldEventSender ~= nil then
		if self.worldEventSender:hasEvent(eventName) then
			self.worldEventSender:dipatchEvent(eventName, data)
		else
			if callBack ~= nil then
				callBack();
			end
		end
	else
		if GameVersionConfig.IS_SERVER == false then
			Logger.logError(" 全局监听器还没有初始化已经开始监听事件了 ~~")
		end
	end
end

--销毁事件发送
function M:destroy()
	self.localEventSender = nil;
	self.worldEventSender= nil;
end

return M