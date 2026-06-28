--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:32:47
]]

---@class SceneStoryMgr @
local M = class("SceneStoryMgr")

function M:init()

    self.storyCount = 0;
    --关卡表
    local level = UserDataManager:getBattleStage();
    local curStage = ConfigManager:getCfgByName("stage")[level];
    local scene_start_event_str = curStage.scenario_event;
    --得到场景事件表
    --local scenario_event = ConfigManager:getCfgByName("scenario_event") --无配置
    --事件链表
    self.event_list = Battle.List.new();
    self.playIndex = 0;
    --有剧情
    if scene_start_event_str ~= nil and scene_start_event_str ~= "" then
        local scene_start_strs = string.split( scene_start_event_str,',');
        --开始的事件id
        local scene_start_event = scene_start_strs[1]
        --是否开始先播放我 
        --0 先播放别的剧情
        --1 先播放我
        self.playIndex = tonumber(scene_start_strs[2])
  
        --取到一个初始事件
        local event_table_item = scenario_event[scene_start_event];
        event_table_item.scenario_id = scene_start_event;
        local cur_event_item = self:createEventItem();
        cur_event_item.list:add( event_table_item );
        self.event_list:add( cur_event_item );
        
        --通过while循环去取所有的触发事件
        while cur_event_item.list.Count > 0 do
            local event_item = self:createEventItem();
            for i = 1, cur_event_item.list.Count do
                local table_item = cur_event_item.list:get(i-1);
                for i, v in ipairs(table_item.next) do
                    local next_item = scenario_event[v];
                    next_item.scenario_id = v;
                    event_item.list:add( next_item );
                end
            end

            cur_event_item = event_item;
            if event_item.list.Count > 0 then
                self.event_list:add( event_item );
            end
        end
    end
    self.storyCount = self.event_list.Count;
end

--是否有剧情
function M:hasStory()
    return self.storyCount > 0;
end


function M:createEventItem()
    local event_item = {}
    event_item.list = Battle.List.new();
    return event_item;
end

--执行 剧情
function M:runningStory( callBack )
    if self.storyCount > 0 and self.event_list.Count == self.storyCount then
        ResourceUtil:LoadRoleSound("Amb")
        self.m_amb_wind_sound_id = audio:PlayFmodSound("Amb_Wind","Amb")
    end
    
    if self.event_list.Count > 0 then
        local event_item = self.event_list:get(0)
        self.event_list:remove(event_item);
        self:triggerEvent(event_item, function()
            self:runningStory( callBack );
        end);
    else
        if self.storyCount > 0 then
            ResourceUtil:UnLoadRoleSound("Amb")
        end
        if callBack ~= nil then
            callBack();
        end
    end
end

--事件处理函数
function M:triggerEvent( event_item, callBack )
    --完成数量
    local finishNum = 0;
    for i = 1, event_item.list.Count do
        local cur_item = event_item.list:get(i-1);
        self:triggerSameEvent(cur_item, function()
            local param = cur_item.type_param
            local bankName = param.bank
            if bankName and bankName ~= "" then
                ResourceUtil:UnLoadRoleSound(bankName)
            end
            finishNum = finishNum + 1;
            if finishNum == event_item.list.Count then
                event_item.list:clear();
                --停止风声
                audio:StopPlayingID(self.m_amb_wind_sound_id)
                self.m_amb_wind_sound_id = nil
                if callBack ~= nil then
                    callBack();
                end
               
            end
        end)
    end
end


function M:triggerSameEvent( cur_item, callBack )
    local param = cur_item.type_param;
    --事件类型
    local event_type = cur_item.event_type;
    --延迟
    local delay = cur_item.delay/1000;
    --是否发送到服务器
    local to_server = cur_item.to_server;
    --是否开始事件
    local start_scenario = cur_item.start_scenario;
    --是否结束事件
    local end_scenario = cur_item.end_scenario;
    
    --延迟 delay 秒事件
    TimeTools:delayTime(delay, function()
        local bankName = param.bank;
        --dialog_101
        if bankName ~= nil and bankName ~= "" then
            ResourceUtil:LoadRoleSound(bankName)
        end
        --处理事件
        self:eventHandler( event_type, param, function()
            if callBack ~= nil then
                callBack();
            end
        end);
    end)
end


--事件处理函数
function M:eventHandler( event_type, param, callback )
    if event_type == 1 then
        --开场事件

        if callback ~= nil then
            callback();
        end
    elseif event_type == 2 then
        --说话
        --位置
        local unit = param.unit;
        local camp = 1;
        local index = unit;
        local language = param.language;
        local time = param.time/1000;
        if unit > 5 then
            camp = -1;
            index = unit - 5;
        end
        local text = Language:getTextByKey(language)
        text = string.gsub(text, "\\n", "\n")
        index = index - 1;
        self:talk(camp,index,text,time,callback)
        
        local soundName = param.sound;
        --dialog_101_1
        local bankName = param.bank;
        if soundName ~= "" then
            StateSoundManager:playFmodSound(soundName,"plot_dialog/" .. bankName);
        end
        
    elseif event_type == 3 then
        --特殊符号表情
        if callback ~= nil then
            callback();
        end
    elseif event_type == 4 then
        --结束事件
        --进入战斗
        local enter_battle = param.enter_battle == 1;
        --进入布阵界面
        local enter_deploy = param.enter_deploy == 1;
        --返回上级界面
        local enter_hub = param.enter_hub == 1;
        --直接跳过战斗获得奖励
        local skip_battle = param.skip_battle == 1;

        if callback ~= nil then
            callback();
        end
        
    elseif event_type == 5 then
        
        --出现单位
        --入场方式
        --1 轻功入场
        --2 跑步入场
        --3 特殊入场 动画 + 特效
        local type = param.type;
        type = 2;
        --我放入场英雄
        local self_unit = param.self_unit;
        --敌方入场英雄
        local enemy_unit = param.enemy_unit;
        --用于第三种入场方式
        local anim = param.anim;
        local createNum = 0;
        local finihsNum = 0;
        for i, v in ipairs(self_unit) do
            if v ~= 0 then
                createNum = createNum + 1;
                SceneManager.curScene:moveToScene(v,i-1,1,type,function()
                    finihsNum = finihsNum + 1
                    if createNum == finihsNum then
                        if callback ~= nil then
                            callback();
                        end
                    end
                end);
            end
        end

        for i, v in ipairs(enemy_unit) do
            if v ~= 0 then
                createNum = createNum + 1;
                SceneManager.curScene:moveToScene(v,i-1,-1,type,function()
                    finihsNum = finihsNum + 1
                    if createNum == finihsNum then
                        if callback ~= nil then
                            callback();
                        end
                    end
                end);
            end
        end
        
        EventDispatcher:dipatchEvent("addSkillBtns")
    end
end


--弹出对话
function M:talk( camp, index, text, time, finish )
    local player = nil;
    if camp == 1 then
        for i = 1, SceneManager.curScene.plyMgr.hero_list.Count do
            local ply = SceneManager.curScene.plyMgr.hero_list:get(i-1);
            if ply.index == index then
                player = ply;
            end
        end
    else
        for i = 1, SceneManager.curScene.plyMgr.enemy_list.Count do
            local ply = SceneManager.curScene.plyMgr.enemy_list:get(i-1);
            if ply.index == index then
                player = ply;
            end
        end
    end
    
    if player ~= nil then
        player.player_talk:talk( text, time );
        TimeTools:delayTime(time, finish);
    else
        TimeTools:delayTime(time, finish);
    end
end


return M;