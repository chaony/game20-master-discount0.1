--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:32:47
]]

--大地图事件
---@class WorldMapEvent @
local M = class("WorldMapEvent")

--初始化事件
function M:init( data, event_type, waitForChoise)
    self.eventData = data;
    self.event_type = event_type
    --self.waitForChoise = waitForChoise
end

--开始执行事件
function M:start( x, y, eventOver )
    Logger.log("事件开始：")
    self.x = x;
    self.y = y;
    --事件结束回调
    self.eventOver = eventOver;
    if self.event_type == GlobalConfig.WORLD_MAP_EVENT.NORMAL_EVENT or self.event_type == GlobalConfig.WORLD_MAP_EVENT.LIMIT_TIME_EVENT or self.event_type == GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT then
        local event_before = self.eventData.event_before or 0
        if event_before > 0 then
            if self.event_type == GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT and self.eventData.isArticle ~= true then
                if self.eventData.option_switch == 1 then
                    local article_option = ConfigManager:getCfgByName("regional_article_option")
                    local choise = {}
                    local choise_id = {}
                    for k,v in pairs(self.eventData.option_id) do
                        local opt_id = tonumber(v)
                        table.insert(choise, article_option[opt_id].option_text)
                        table.insert(choise_id, opt_id)
                    end
                    self:talk(event_before, choise, choise_id, self.eventData.can_choise, self.eventData.no_choise_tips)
                else
                    self:talk(event_before, {}, {}, self.eventData.can_choise, self.eventData.no_choise_tips)
                end
            else
                self:talk(event_before, self.eventData.choise, self.eventData.choise_id, self.eventData.can_choise, self.eventData.no_choise_tips)
            end
        else
            self:finish(nil)
        end
    elseif self.event_type == GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT then
        local data = {event_id = self.eventData.id, event_type = self.event_type, x = self.x, y = self.y}
        static_rootControl:updateMsg("send_move_msg",data,"WorldMap.WorldMapMain")
        local event_before = self.eventData.event_before or 0
        if event_before > 0 then
            self:talk(event_before)
        else
            self:finish(nil)
        end
    else
        self:finish(nil)
    end
end

function M:talk(talk_id, choise, choise_id, can_choise, no_choise_tips)
    local data = {}
    --剧情事件
    data.talk_id = talk_id
    --事件选择
    data.choise = choise
    --事件选择id
    data.choise_id = choise_id
    
    data.waitForChoise = self.waitForChoise
    
    data.dialogue_type = self.event_type
    data.callback = function( event_data )
        if event_data ~= nil then
            if self.event_type ~= GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT then
                local data = {}
                data.event_id = self.eventData.id
                data.option_id = event_data.index
                data.event_type = self.event_type
                data.sel_event_id = choise_id[event_data.index]
                data.x = self.x
                data.y = self.y
                static_rootControl:updateMsg("map_chioce_option",data,"WorldMap.WorldMapMain")
            end
        else
            if self.eventData.type == 1 then
                --local data = {}
                --data.event_id = self.eventData.id;
                --static_rootControl:updateMsg("map_enter_map_event",data,"WorldMap.WorldMapMain")
            else
                if self.event_type ~= GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT and self.event_type ~= GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT then
                    local data = {}
                    data.event_id = self.eventData.id
                    data.event_type = self.event_type
                    data.x = self.x
                    data.y = self.y
                    static_rootControl:updateMsg("send_move_msg",data,"WorldMap.WorldMapMain")
                end
            end
        end
        self:finish(event_data)
    end
    --通知UI弹出对话框
    local function callback(event_data)
        if data.callback then
            data.callback(event_data)
        end
    end
    static_rootControl:openView("Guide.GuideDrama", {dialog_id = data.talk_id, callback = callback, choise = data.choise, choise_id = data.choise_id, can_choise = can_choise, no_choise_tips = no_choise_tips, dialogue_type = data.dialogue_type, waitForChoise = data.waitForChoise}, nil , true)
end

--事件完成
function M:finish(event_data)
    Logger.log(" 事件结束：" )
    if self.eventOver ~= nil then
        self.eventOver(event_data)
    end
    --剧情结束要显示物体
    EventDispatcher:dipatchEvent("DisplayObject", self.eventData.display_object or {})
    --剧情结束要销毁物体
    EventDispatcher:dipatchEvent("DestroyObject", self.eventData.destroy_object or {})
    if self.event_type == GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT then
        static_rootControl:openView("WorldMap.WorldMapTask.WorldMapEncounterDetail", {event_data = self.eventData, event_type = self.event_type, x = self.x, y = self.y})
    else
        local event_battle = self.eventData.event_battle or 0
        if event_battle > 0 and self.event_type ~= GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT then
            --进入战斗
            static_rootControl:updateMsg("map_event_battle_start", {event_id = self.eventData.id, event_type = self.event_type}, "WorldMap.WorldMapMain")
        end
    end
end



return M;