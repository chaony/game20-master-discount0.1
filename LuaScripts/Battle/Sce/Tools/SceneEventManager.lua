--场景事件管理器
---@class SceneEventManager @
local M = class("SceneEventManager")
function M:init()
	self.scene = SceneManager.curScene
	--事件
	self.events = Battle.List.new();
	--self.eventData = ConfigManager:getCfgByName("roleplaying_event")
	--self.objectData = ConfigManager:getCfgByName("roleplaying_object")
	--事件地图
	self.m_all_event_cfgs = {
		[GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT] = ConfigManager:getCfgByName("encounter"),
		[GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT] = ConfigManager:getCfgByName("regional_task"),
	}
	
	--EventDispatcher:registerEvent("viewToEvent", {self,self.viewToEventHandle})
	EventDispatcher:registerEvent("battleEnd", {self, self.battleEndHandle})
end

--关卡开始
function M:start()
	
end

function M:clear()
	self.events:clear();
end


function M:addWorldMapEvent( map_event_id, event_type, waitForChoise )
	local mapEventItem = nil
	local event_cfg = self.m_all_event_cfgs[event_type]
	if event_cfg then
		mapEventItem = event_cfg[map_event_id]
	end
	if mapEventItem then
		local event = require("Battle.Sce.WorldScene.WorldMapEvent").new()
		event:init(mapEventItem, event_type, waitForChoise);
		self.events:add(event)
		Logger.log(" addWorldMapEvent 事件 id : ".. tostring(map_event_id) .. "--" .. tostring(event_type) );
	else
		Logger.log(" addWorldMapEvent 事件 id failed : ".. tostring(map_event_id) .. "--" .. tostring(event_type) );
	end
end


--事件触发开始
function M:trigger( x, y, finish )
	if self.events.Count > 0 then
		local event = self.events:get(0)
		self.events:removeAt(0)
		event:start( x, y, 
			--循环触发，如果后面有事件继续触发
			function(event_data)
				self:trigger(finish);
				if finish then
					finish(event_data)
				end
			end);
	end
end


--加入一个事件
function M:addEvent( event_id, grid_data )
	local common_data = self.eventData[0][event_id]
	if common_data ~= nil then
		local event = require("Battle.Sce.Tools.SceneEvent").new()
		event:init(event_id, common_data, self, grid_data)
		Logger.log(" 加入一个事件 id "..event_id );
		self.events:add(event)
	else
		local event_data = self.eventData[self.scene.map_id][event_id];
		if event_data ~= nil then
			local event = require("Battle.Sce.Tools.SceneEvent").new()
			event:init(event_id, event_data, self, grid_data)
			Logger.log(" 加入一个事件 id "..event_id );
			self.events:add(event)
		end
	end
end

--继续触发
--战斗结束
function M:battleEndHandle( eventName, data )
	self:trigger();
end

return M