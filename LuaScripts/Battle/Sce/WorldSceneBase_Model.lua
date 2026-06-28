--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:32:47
]]

---@class WorldSceneBase_Model : Scene_Model @
---@field super Scene_Model @Scene_Model
local M = class("WorldSceneBase_Model",Battle.Scene_Model)

--初始化场景
function M:init()
    M.super.init(self)
    self.m_encounter_npc_tab = {}
    self.m_world_boss_tab = {}
    self.cur_map = {map_id = nil, map_index = 1, day_unlock = true, isDone = false}
    --屏蔽传送场景
    self.canTransPoint = false
    self.encounter_cfg = ConfigManager:getCfgByName("encounter")
    self.worldMap_cfg = ConfigManager:getCfgByName("worldmap_open")
    self.map_table = ConfigManager:getCfgByName("regional_map")
    self.stage_table = ConfigManager:getCfgByName("stage")
    self.task_table = ConfigManager:getCfgByName("regional_task")
    self.task_team_table = ConfigManager:getCfgByName("regional_task_team")

    --世界地图数据
    self.worldInfo_cfg = ConfigManager:getCfgByName("worldsceneevent_info");
    --悬赏数据
    self.bountyQuestData = ConfigManager:getCfgByName("bounty_quest");
end

function M:getCurSceneName()

end

function M:getCurSceneObjName()
    return "";
end


function M:loadFinish()
    self.m_world_map_data = self.m_data
    --英雄
    M.super.loadFinish(self)

    SceneManager:scenestart();

    if SceneManager.eventMgr == nil then
        SceneManager.eventMgr = require("Battle.Sce.Tools.SceneEventManager").new()
        SceneManager.eventMgr:init()
    end

    EventDispatcher:registerEvent("DisplayObject",handler(self, self.displayObject))
    EventDispatcher:registerEvent("DestroyObject",handler(self, self.destroyObject))

    self.gameover = false
    self.sceneState = 3
    self.Camera = U3DUtil:GameObject_Find("Camera")
    self.worldCamera = self.Camera:GetComponent("WorldCamera")
    self.HeroRoot = U3DUtil:GameObject_Find("Hero")
    self.camera_3d = self.Camera.transform:Find("3DCamera")
    self.ui_camera = U3DUtil:GameObject_Find("shijie_UICamera"):GetComponent("Camera")
    self.Canvas = U3DUtil:GameObject_Find("SceneCanvas")

    self:refreshTranPointData()

    self.areaBarsImg = {}
    self.areaBarsText = {}
    self.areaBarsEffect = {}
    self.buildings = {}
    self.allMapData = {}
    for k,v in pairs(self.worldInfo_cfg) do
        if v.type == 1 then
            if self.map_table[v.value] ~= nil then
                table.insert(self.allMapData, {id = v.value, sceneId = v.sceneName})
            end
        end
    end
    table.sort(self.allMapData, function(a,b)
        local map1 = self.map_table[a.id]
        local map2 = self.map_table[b.id]
        return map1.stage_open < map2.stage_open
    end)
    self:refreshCurMap()

    self.maps = {}
    for k,v in pairs(self.worldMap_cfg) do
        for k1,v1 in ipairs(v.map_id) do
            self.maps[v1] = {area_id = k, stage_id = v.stage_id, task_id = v.task_id}
        end
    end

    --事件数据
    self.eventData = require("Battle.Data.SceneInfo.WorldSceneEvent_info");
    local pos, next_stage_pos = self:createStagePoint()

    local avatar,custom_prefab  = GameUtil:getUserOwnAvatar()
    local playerData = { id = tonumber(avatar), evo = 0, custom_prefab = custom_prefab }
    local player = self.plyMgr:createPlayer(playerData, 1, -1, nil, nil)
    player.loadPlayerViewFinish = function( player_view )
        self.player = player_view
        if self.player ~= nil and IsNull(self.player.obj) == false then
            self.luaViewHelper = self.player.obj:AddComponent(typeof(CS.WorldMapPlayerLuaViewHelper))
            self.luaViewHelper.isSetPosition = false;
            self.luaViewHelper.isSetRotation = false;
            self.playerHelperArr = LuaCSharpArr.New(25)
            local CSharpAccess = self.playerHelperArr:GetCSharpAccess()
            self.luaViewHelper:PinTable(CSharpAccess)

            self.player.luaViewHelper.isSetPosition = false;
            self.player.luaViewHelper.isSetRotation = false;
            self.player.tran:SetParent(self.HeroRoot.transform)
            if pos ~= nil then
                self.player.tran.localPosition = pos;
                if next_stage_pos ~= nil then
                    self.player.tran.forward = Vector3.New(next_stage_pos.x - pos.x, 0, next_stage_pos.z - pos.z)
                end
            end
            self.player.tran.localScale = Vector3(1.1,1.1,1.1);

            if IsNull(self.Camera) == false then
                self.Camera.transform.position = self.player.tran.position
            end
            
            self.view_list, self.model_list = GlobalTools:CreateSummon(player)
            
            
            self:resetPlayerPosition(self.player)
            TimeTools:delayTimeUnity(0.5,function()
                --if self.player.navAgent ~= nil then
                --    self.player.navAgent.enabled = true;
                --end
                --self.player.navAgent.speed = 10; 
                if _G.next(self.view_list) ~= nil then
                    for i, v in ipairs(self.view_list) do
                        v.luaViewHelper.isSetPosition = false;
                        v.luaViewHelper.isSetRotation = false;
                        v.tran.position = pos - self.player.tran.forward * 0.5;
                        v.luaViewHelper:FollowTo(self.player.tran, 4)
                        v.luaViewHelper.m_animator:CrossFadeInFixedTime("idle",0.1)
                    end
                end
                self:refreshFog()
            end)
        end
    end
    


    self.m_encounter_npc_tab = {}
    self.m_world_npc_icon = U3DUtil:GameObject_Find("world_npc_icon")
    self:updateEncounterNpc()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    self:initWorldBox()

    local enter_map = UserDataManager.local_data:getUserDataByKey("enter_map_list", {})
    enter_map[self.sceneId] = 1
    UserDataManager.local_data:setUserDataByKey("enter_map_list", enter_map)
end

--刷新建筑数据
function M:refreshTranPointData()
    self.transPoint = {}
    self.worldSceneEventObj = U3DUtil:GameObject_Find("SceneEvent"..self.sceneId);
    if self.worldSceneEventObj ~= nil then
        self.eventBehaiour = self.worldSceneEventObj:GetComponent("WorldSceneLuaBehaiour");
        self.eventBehaiour:Register("StartMove",handler(self,self.startMove))
        self.eventBehaiour:Register("StopMove",handler(self,self.stopMove))
        self.eventBehaiour:Register("ClickObj",handler(self,self.clickObject))
        for i = 1, self.worldSceneEventObj.transform.childCount do
            local child = self.worldSceneEventObj.transform:GetChild(i - 1)
            local eventPoint = child:GetComponent("WorldEventPoint")
            if eventPoint.m_mode == CS.PointMode.TransPoint then
                self.transPoint[eventPoint.id] = eventPoint
            end
        end
    end
end

function M:getBranchTask(id)
    local task_done = UserDataManager:getRegionalTaskDoneData()
    local cur_task_done = task_done[tostring(self.sceneId)]
    local done = false
    if cur_task_done ~= nil then
        for k,v in pairs(cur_task_done.scenes) do
            for kk,vv in pairs(v.tasks) do
                if id == vv then
                    done = true
                    break
                end
            end
        end
    end
    return done, self.task_table[tonumber(id)]
end

function M:checkAreaOpen(area_id)
    local map = self.maps[area_id]
    local done = true
    if map.task_id ~= 0 then
        done = self:getBranchTask(map.task_id)
    end
    local stageOpen = UserDataManager:getCurStage() >= map.stage_id
    return stageOpen, done
end

function M:refreshBrand()
    local eventInfoData = ConfigManager:getCfgByName("worldsceneevent_info")

    local scene_lines_data = UserDataManager:getSceneLineData()
    local area = nil
    if scene_lines_data ~= nil then
        area = scene_lines_data[tostring(self.sceneId)]
    end

    if IsNull(self.Canvas) == false then
        local bar_img = UIUtil.findTrans(self.Canvas.transform, "mapAreaBarImg")
        local bar_text = UIUtil.findTrans(self.Canvas.transform, "mapAreaBarText")
        local bar_effect = UIUtil.findTrans(self.Canvas.transform, "mapAreaBarEffect")

        for k,v in pairs(eventInfoData) do
            if v.sceneName == self.sceneId and self.map_table[k] ~= nil and v.type == 1 or v.type == 0 then
                local areaBarImg = self.areaBarsImg[k]
                local areaBarText = self.areaBarsText[k]
                local areaBarEffect = self.areaBarsEffect[k]
                if self.map_table[k].stage_open >= 0 then
                    local open_flag, pre_task_end, tips_str, brand_str = self:checkMapOpen(k)
                    if areaBarImg == nil then
                        self.buildings[k] = self.worldSceneEventObj.transform:Find(v.name)
                        if self.buildings[k] ~= nil then
                            areaBarImg = self:createAreaBar(k, bar_img, "mapAreaBarImg", v)
                            areaBarText = self:createAreaBar(k, bar_text, "mapAreaBarText", v)
                            areaBarEffect = self:createAreaBar(k, bar_effect, "mapAreaBarEffect", v)

                            UIUtil.setButtonClick(areaBarImg.transform, function(trans, data)
                                self:transPointPoint(data.id)
                                audio:SendEvtUI("UI_SceneSelected")
                            end, {id = k}, "brand_btn")
                            self.areaBarsImg[k] = areaBarImg
                            self.areaBarsText[k] = areaBarText
                            self.areaBarsEffect[k] = areaBarEffect
                        else
                            Logger.logErrorAlways(v, "SceneEvent buildings not found : " .. k)
                        end
                    end
                    if areaBarImg and areaBarText and areaBarEffect then
                        local textluaBehaviour = areaBarText:GetComponent("LuaBehaviour")
                        LuaBehaviourUtil.setTextByLanKey(textluaBehaviour, "brand_text", self.map_table[k].name)
                        local is_new = false

                        local cpd, status = self:getMapCpd(self.sceneId, k)
                        local totalMapCount = self.map_table[k].scene
                        LuaBehaviourUtil.setObjectVisible(textluaBehaviour, "complete_num_text", open_flag)
                        LuaBehaviourUtil.setObjectVisible(textluaBehaviour, "complete_text", open_flag)
                        LuaBehaviourUtil.setObjectVisible(textluaBehaviour, "lock_text", open_flag == false)

                        if open_flag == true then
                            LuaBehaviourUtil.setTextByLanKey(textluaBehaviour, "complete_num_text", cpd.."/"..totalMapCount)
                            LuaBehaviourUtil.setTextByLanKey(textluaBehaviour, "complete_text", "new_str_0606")
                        else
                            LuaBehaviourUtil.setTextByLanKey(textluaBehaviour, "lock_text", brand_str)
                        end
                        if area ~= nil then
                            local scene_line = area[tostring(k)] or {}
                            if cpd <= 0 and table.indexof(scene_line, k) == false then
                                is_new = true
                            end
                        else
                            is_new = true
                        end
                        local imgluaBehaviour = areaBarImg:GetComponent("LuaBehaviour")

                        LuaBehaviourUtil.setObjectVisible(imgluaBehaviour, "new_img", open_flag and is_new)
                        areaBarEffect:SetActive(false)
                        
                        local will_show_reward = cpd < totalMapCount
                        if will_show_reward then
                            local reward_node = imgluaBehaviour:FindGameObject("reward_node")
                            if reward_node.transform.childCount == 0 then
                                local reward_items = self:getTaskReward(self.map_table[k].map_id)
                                if reward_node and reward_items then
                                    GameUtil:createRewards(reward_node.transform, reward_items, false, false, nil, 0.4, nil)
                                end
                            end
                        end
                        
                    end
                end
            end
        end
    end
    
    if LikeOO.Map2DControl.curMap2D == nil then
        static_rootControl:updateMsg("check_guide", nil, "WorldMap.WorldMapMain")
    end
end

function M:createAreaBar(id, parent, name, data)
    local areaBar = ResourceUtil:GetUIItem("Map/"..name, parent.gameObject, "ui_prefabs")
    areaBar.name = data.name
    local WorldPointUI = areaBar:GetComponent("WorldPointUI")
    local titlePoint = self.buildings[id]:Find("titlePoint")
    WorldPointUI.target = titlePoint or self.buildings[id]
    return areaBar
end

function M:closeLoading()
    M.super.closeLoading(self)
    static_rootControl:updateMsg("load_scene_finish", nil, "WorldMap.WorldMapMain")
    SceneManager:setData("show_loading_black", false)
    static_rootControl:updateMsg("close_battle_loading")
end

--重新设定位置
function M:resetPlayerPosition()

end


--发送悬赏任务
--表中的静态数据 taskData
--开始位置 start_pos
--开始时间 start_time
function M:sendQuestTask( taskID,  start_time , start_pos )
    local taskData = self.bountyQuestData[taskID];
    --服务器当前时间
    --计算得到间隔时间
    local gapTime = UserDataManager:getServerTime() - start_time;
    local min = gapTime/60;

    if min < taskData.duration_time then
        local target = taskData.point;
        --任务还在
        local mache = ResourceUtil:LoadRole3d("MingJiao_mache8001/MingJiao_mache8001",self.HeroRoot)
        CS.WorldCamera.Inst:AutoSetGameObjectPosition( min, taskData.duration_time, mache, start_pos, target );
        CS.WorldCamera.Inst:AutoFindPathByIdMaChe( target , taskData.duration_time - min, mache, start_pos );
    else
        --超过表中时间，表示任务已经过了
    end
end



--显示某个物体
function M:displayObject( object_id )
    local value_type =  type(object_id)
    if value_type == "number" then
        self.eventBehaiour:ShowPoint(object_id)
    elseif value_type == "table" then
        for _,v in pairs(object_id) do
            self.eventBehaiour:ShowPoint(v)
        end
    end
end

--销毁某个物体
function M:destroyObject( object_id )
    local value_type =  type(object_id)
    if value_type == "number" then
        self.eventBehaiour:HidePoint(object_id)
    elseif value_type == "table" then
        for _,v in pairs(object_id) do
            self.eventBehaiour:HidePoint(v)
        end
    end
end

--点击UI上的Item,传入的数据
function M:clickUIItem( eventId, eventType, npc_id)
    self.curEventId = eventId;
    self.curEventType = eventType;
    local npc_number = npc_id or 0
    if npc_number > 0 then
        --自动寻路
        if SceneManager.events == nil then
            SceneManager.events = {}
        end
        CS.WorldCamera.Inst:AutoFindPathById( tonumber(npc_number ) );
        Logger.log(" 点击UI = "..eventId .." Type = "..eventType )
    else
        Logger.log(" 点击UI 未找到配置= "..eventId .." Type = "..eventType )
    end
end

--点击到场景中的某个物件
function M:clickObject( data )
    local id = tonumber(data);
    if id > 0 then
        self.curEventId = nil;
        self.curEventType = nil;
        self:transPointPoint(id)

        --自动寻路
        --CS.WorldCamera.Inst:AutoFindPathById( tonumber(id) );
        local event_point = self.eventBehaiour:GetWorldPointById(id)
        if event_point and event_point.m_mode == GlobalConfig.WORLD_MAP_POINT_MODE.TransPoint then
            audio:SendEvtUI("UI_SceneSelected")
        end
    end
    Logger.log(" 点击某个物体 ~~~~~~~~~~~~~~~~~~ "..tonumber(data))

end

--开始移动
function M:startMove( data )
    Logger.log(" 开始移动 ~~~~~~~~~~~~~~~~~~ ")
    audio:SendEvtUI("UI_Movement_Click")
end

--停止移动 
function M:stopMove( data )
    ----停止移动向服务器发送位置信息
    --local data_pos = string.split( data, ",")
    --local point_data = {};
    --point_data.x = tonumber(data_pos[1] or 0);
    --point_data.y = tonumber(data_pos[2] or 0);
    --point_data.obj_id = tonumber(data_pos[3] or 0);
    --point_data.trigger_radius = tonumber(data_pos[4] or 0);
    --point_data.point_mode = tonumber(data_pos[5] or 0);
    --point_data.point_value = tonumber(data_pos[6] or 0);
    --
    --Logger.log(point_data, " 停止移动 ~~~~~~~~~~~~~~~~~~ ")
    --if point_data.point_mode == GlobalConfig.WORLD_MAP_POINT_MODE.Npc then
    --    self:sendEvent("send_move_msg",point_data,"WorldMap.WorldMapMain")
    --    self:npcPoint(point_data)
    --elseif point_data.point_mode == GlobalConfig.WORLD_MAP_POINT_MODE.AssetPoint then
    --    self:sendEvent("send_move_msg",point_data,"WorldMap.WorldMapMain")
    --    self:assetPointPoint(point_data)
    --elseif point_data.point_mode == GlobalConfig.WORLD_MAP_POINT_MODE.FunctionPoint then
    --    self:sendEvent("send_move_msg",point_data,"WorldMap.WorldMapMain")
    --    self:functionPointPoint(point_data)
    --elseif point_data.point_mode == GlobalConfig.WORLD_MAP_POINT_MODE.TransPoint then
    --    self:sendEvent("send_move_msg",point_data,"WorldMap.WorldMiniMap")
    --    self:sendEvent("send_move_msg",point_data,"WorldMap.WorldMapMain")
    --    self:transPointPoint(point_data)
    --elseif point_data.point_mode == GlobalConfig.WORLD_MAP_POINT_MODE.NpcTrigger then
    --    self:doAdventureEvent(point_data)
    --elseif point_data.point_mode == GlobalConfig.WORLD_MAP_POINT_MODE.RewardAssetPoint then
    --    self:doRewardAssetPoint(point_data)
    --else
    --    self:sendEvent("send_move_msg",point_data,"WorldMap.WorldMapMain")
    --    self:npcTrigger(point_data)
    --end
end

function M:doRewardAssetPoint(point_data)
    if self.m_world_boss_tab[point_data.obj_id] then
        self:sendEvent("receive_world_box_reward",point_data,"WorldMap.WorldMapMain")
    else
        self:sendEvent("send_move_msg",point_data,"WorldMap.WorldMapMain")
    end
end

function M:doAdventureEvent(point_data)
    local server_time = UserDataManager:getServerTime()
    if self.curEventId and self.curEventType then
        local encounter_map_event = UserDataManager:getEncounterMapEventData()
        for k,v in pairs(encounter_map_event) do
            if v.event_id == self.curEventId and v.end_ts then
                local diff_time = v.end_ts - server_time
                if diff_time > 0 then
                    SceneManager.eventMgr:addWorldMapEvent(self.curEventId, self.curEventType)
                    SceneManager.eventMgr:trigger(point_data.x, point_data.y)
                end
            end
        end
    else
        -- 奇遇事件
        local encounter_map_event = UserDataManager:getEncounterMapEventData()
        for _, v in pairs(encounter_map_event) do
            if v.end_ts then
                local diff_time = v.end_ts - server_time
                if diff_time > 0 then
                    if v.point == point_data.obj_id then
                        SceneManager.eventMgr:addWorldMapEvent(v.event_id, GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT)
                        SceneManager.eventMgr:trigger( point_data.x, point_data.y )
                    end
                end
            else
                if v.point == point_data.obj_id then
                    SceneManager.eventMgr:addWorldMapEvent(v.event_id, GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT)
                    SceneManager.eventMgr:trigger( point_data.x, point_data.y )
                end
            end
        end
    end
end

--打开某个剧情
function M:transPointPoint(sceneId)
    if self.canTransPoint == true and self.map_table[sceneId] ~= nil and self.map_table[sceneId].stage_open > 0 then
        local open_flag, pre_task_end, tips_str = self:checkMapOpen(sceneId)
        if open_flag == true then
            if pre_task_end == true then
                static_rootControl:updateMsg("brand_btn", sceneId, "WorldMap.WorldMapMain")
                LikeOO.Map2DControl:openMap2D(sceneId)
            else
                GameUtil:lookInfoTips(self.m_control, {msg = tips_str, delay_close = 2})
            end
        else
            GameUtil:lookInfoTips(self.m_control, {msg = tips_str, delay_close = 2})
        end
    end
end


function M:functionPointPoint( point_data )
    --打开某个功能界面
    --QuickOpenFuncUtil:openFunc( point_data.point_value );
end

-- 奇遇事件
function M:npcTrigger(point_data)
    --if point_data.obj_id ~= 0 then
    --    if self.curEventId and self.curEventType then
    --        --加入地图事件
    --        SceneManager.eventMgr:addWorldMapEvent(self.curEventId, self.curEventType)
    --        SceneManager.eventMgr:trigger( point_data.x, point_data.y )
    --    else -- TODO通过优先级触发不同类型的事件
    local add_event_flag = false
    --local server_time = UserDataManager:getServerTime()

    ---- 奇遇事件
    --local encounter_map_event = UserDataManager:getEncounterMapEventData()
    --for _, v in pairs(encounter_map_event) do
    --    if v.end_ts then
    --        local diff_time = v.end_ts - server_time
    --        if diff_time > 0 then
    --            if v.npc_id == point_data.obj_id then
    --                SceneManager.eventMgr:addWorldMapEvent(v.event_id, GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT)
    --                SceneManager.eventMgr:trigger( point_data.x, point_data.y )
    --                add_event_flag = true
    --            end
    --        end
    --    else
    --        if v.npc_id == point_data.obj_id then
    --            SceneManager.eventMgr:addWorldMapEvent(v.event_id, GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT)
    --            SceneManager.eventMgr:trigger( point_data.x, point_data.y )
    --            add_event_flag = true
    --        end
    --    end
    --end
    -- 主动调用奇遇触发接口
    local can_trigger = UserDataManager:isCanTriggerEncounter()
    if not add_event_flag and can_trigger then
        math.newrandomseed()
        local random_value = math.random(1,3)
        EventDispatcher:registerTimeEvent("big_map_encounter_trigger_timer", function()
            self:sendEvent("big_map_encounter_trigger",point_data,"WorldMap.WorldMapMain")
        end, random_value, random_value)
    end
    --end
    --end
end

function M:npcPoint(point_data)
    if point_data.obj_id ~= 0 then
        if self.curEventId and self.curEventType then
            --加入地图事件
            SceneManager.eventMgr:addWorldMapEvent(self.curEventId, self.curEventType)
            SceneManager.eventMgr:trigger( point_data.x, point_data.y )
        end
    end
end

function M:assetPointPoint(point_data)

    self:sendEvent("click_point_msg",point_data,"WorldMap.WorldMapMain")
end

function M:update_dt(dt)
    if U3DUtil:Input_GetKeyDown("w") then
        local point_data = {}
        point_data.x = -51.2;
        point_data.y = -32.2;
        point_data.obj_id = 0;
        point_data.trigger_radius = 0;
        point_data.point_mode = 0;
        point_data.point_value = 0;
        self:sendEvent("send_move_msg",point_data,"WorldMap.WorldMapMain")
    end

    --if self.fogSaveTimer ~= nil then
    --    self.fogSaveTimer = self.fogSaveTimer - dt
    --    if self.fogSaveTimer <= 0 then
    --        self.fogSaveTimer = 5
    --        if not IsNull(self.fogOfWar) then
    --            self.fogOfWar:SaveData(UserDataManager.user_data.user_status.uid.."_OpenMap"..self.sceneId)
    --        end
    --    end
    --end
    if self.playerHelperArr ~= nil and static_rootControl:can3DTouchByViewName("WorldMap.WorldMiniMap") then
        --local x = GlobalTools:ToFloat(self.playerHelperArr[1])
        --local y = GlobalTools:ToFloat(self.playerHelperArr[2])
        --local z = GlobalTools:ToFloat(self.playerHelperArr[3])
        --static_rootControl:updateMsg("refreshHeroPos", {x = x, y = y, z = z}, "WorldMap.WorldMiniMap")

    end
end


function M:update_unsdt(unsdt)

end


function M:registerHeroAndEnemyPos()

end


function M:triggerEvent( eventData )

end


--进入场景
function M:enter(data)
    M.super.enter(self, data)
    TimeManager:set_baseUpdateDelaTime(TimeManager.hangUpUpdateDelteTime)
end


function M:destroy( nextScene)
    if self.player_move_tween ~= nil then
        self.player_move_tween:Kill(true)
        self.player_move_tween = nil
    end
    self.m_encounter_npc_tab = {}
    if self.areaBarsImg ~= nil then
        for k,v in ipairs(self.areaBarsImg) do
            ResourceUtil:ReturnItem(v)
        end
    end
    if self.areaBarsText ~= nil then
        for k,v in ipairs(self.areaBarsText) do
            ResourceUtil:ReturnItem(v)
        end
    end
    if self.areaBarsEffect ~= nil then
        for k,v in ipairs(self.areaBarsEffect) do
            ResourceUtil:ReturnItem(v)
        end
    end
    
    if IsNull(self.luaViewHelper) == false then
        self.luaViewHelper:Destroy()
    end
    if self.player ~= nil then
        self.player:destroy()
    end
    self.buildings = {}
    self.areaBarsImg = {}
    self.areaBarsText = {}
    self.areaBarsEffect = {}
    --self.fogOfWar:SaveData(UserDataManager.user_data.user_status.uid.."_OpenMap"..self.sceneId) 
    EventDispatcher:unRegisterEvent("big_map_encounter_trigger_timer")
    EventDispatcher:unRegisterEvent("big_map_encounter_npc_timer")
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self, nextScene );
    self.Camera = nil;
    self.camera_3d = nil;
end

--设定位置
function M:setPosition(dt,unsdt)
    M.super.setPosition(self,dt,unsdt)
end

function M:updateEncounterNpc()
    local min_time = 0
    local show_npc_tab = {}
    local map_event_group = UserDataManager:getEncounterMapEventData()
    local server_time = UserDataManager:getServerTime()
    for k,v in pairs(map_event_group) do
        local end_ts = v.end_ts or 0
        local diff_time = end_ts - server_time
        if diff_time > 0 then -- 显示模型
            local save_key = tostring(v.point) .. "-" .. tostring(k)
            show_npc_tab[save_key] = k
            min_time = min_time == 0 and diff_time or math.min(min_time, diff_time)
        end
    end
    for k,v in pairs(show_npc_tab) do
        if self.m_encounter_npc_tab[k] == nil then
            self:createEncounterNpc(k, map_event_group[v], v)
        end
    end
    for k,v in pairs(self.m_encounter_npc_tab) do
        if show_npc_tab[k] == nil then --需要移除
            if v.load_finish_flag then
                self:destroyEncounterNpc(k, v)
            else
                v.need_destroy = true
            end
        end
    end
    if min_time > 0 then
        EventDispatcher:registerTimeEvent("big_map_encounter_npc_timer", function()
            TimeTools:delayTimeUnity(0.5,function()
                if self.isDestoryMe ~= true then
                    self:updateEncounterNpc()
                end
            end)
        end, min_time, min_time)
    end
end

function M:destroyEncounterNpc(k, data)
    local ab_name = "role3d_"..string.lower(data.prefab_name)
    ResourceUtil:DestroyInstance(data.player_obj,"", ab_name)
    ----销毁掉池中预制和bundle物体
    ResourceUtil:UnLoadBundlePrefab(ab_name)
    U3DUtil:Destroy(data.world_npc_icon)
    self.m_encounter_npc_tab[k] = nil
end

function M:createEncounterNpc(save_key, data, team_id)
    if data and data.point then
        local encounter_team_cfg = ConfigManager:getCfgByName("encounter_team")
        local encounter_team_cfg_item = encounter_team_cfg[tonumber(team_id)]
        local event_point = self.eventBehaiour:GetWorldPointById(data.point)
        if self.m_encounter_npc_tab[save_key] == nil and encounter_team_cfg_item and event_point then
            local prefab_name = encounter_team_cfg_item.npc_model
            local npc_pic = encounter_team_cfg_item.npc_pic
            local npc_tab = {load_finish_flag = false, event_point = event_point, data = data, prefab_name = prefab_name}
            self.m_encounter_npc_tab[save_key] = npc_tab
            ResourceUtil:LoadRole3dAsync(prefab_name, event_point.gameObject, function(obj)
                if not IsNull(obj) then
                    npc_tab.player_obj = obj
                    npc_tab.load_finish_flag = true
                    if self.isDestoryMe then
                        self:destroyEncounterNpc(save_key, npc_tab)
                    else
                        local luaViewHelper = obj:GetComponent("LuaViewHelper")
                        if luaViewHelper then
                            luaViewHelper.enabled = false
                        end
                        obj.transform.localScale = Vector3(1,1,1)
                        obj.transform.localPosition = Vector3.New(0, -1.7, 0)
                        obj.transform.localRotation = Quaternion.Euler(0,70,0);
                        --local helper = obj:GetComponent("LuaTransformHelper")
                        --helper:SetAnimator(true);
                        GlobalTools:CloseShadow(obj.transform)

                        if npc_tab.need_destroy then
                            self:destroyEncounterNpc(save_key, npc_tab)
                        else
                            if not IsNull(self.m_world_npc_icon) then
                                local world_npc_icon_new = U3DUtil:Instantiate(self.m_world_npc_icon)
                                world_npc_icon_new.transform:SetParent(self.m_world_npc_icon.transform.parent, false)
                                world_npc_icon_new.transform.localScale = Vector3(2,2,2)
                                local follow3D = world_npc_icon_new:GetComponent("WorldPointUI")
                                follow3D.target = obj.transform
                                follow3D.offset = Vector3(0,3,0)
                                --follow3D:Init()
                                --local position = world_npc_icon_new.transform.position
                                --position.y = position.y + 6
                                --world_npc_icon_new.transform.position = position
                                local img = UIUtil.findImage(world_npc_icon_new.transform, "Image")
                                img.sprite = ResourceUtil:GetSprite(npc_pic,"main_ui")
                                npc_tab.world_npc_icon = world_npc_icon_new
                            end
                        end
                    end
                else
                    Logger.logError(prefab_name,"LoadRole3d failed : ")
                end
            end)
        end
    end
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "encounter_update" then
        self:updateEncounterNpc()
    elseif curEvent == "scene_lines_update" then
        self:refreshBrand()
    elseif curEvent == "task_done_update" then
        self:refreshCurMap()
        self:refreshBrand()
    end
end

function M:initWorldBox()
    local world_box_received = self.m_world_map_data.world_box_received or {}
    local world_box_received_key = {}
    for k,v in pairs(world_box_received) do
        world_box_received_key[v] = k
    end
    local MiGong_lingmushouwei_01 = U3DUtil:GameObject_Find("MiGong_lingmushouwei_01")
    self.m_world_boss_tab = {}
    local world_box_cfg = ConfigManager:getCfgByName("world_box") or {}
    local cur_stage = UserDataManager:getCurStage()
    for k,v in pairs(world_box_cfg) do
        local event_point = self.eventBehaiour:GetWorldPointById(k)
        local stage = v.stage or 999999
        if event_point and cur_stage >= stage and not world_box_received_key[k] then
            local box_obj = U3DUtil:Instantiate(MiGong_lingmushouwei_01)
            box_obj.transform:SetParent(event_point.gameObject.transform, false)
            box_obj.transform.localScale = Vector3(0.3,0.3,0.3)
            box_obj.transform.localPosition = Vector3.New(0, 0, 0)
            self.m_world_boss_tab[k] = box_obj
        end
    end
end

function M:receiveWorldBoxRewardFinish(point_data)
    if not IsNull(self.m_world_boss_tab[point_data.obj_id]) then
        U3DUtil:Destroy(self.m_world_boss_tab[point_data.obj_id])
        self.m_world_boss_tab[point_data.obj_id] = nil
    end
    local world_box_received = self.m_world_map_data.world_box_received or {}
    table.insert(world_box_received, point_data.obj_id)
end

function M:getMapCpd(area_id, scene_id)
    local task_data = UserDataManager:getTasksData()
    local regional_task_done = UserDataManager:getRegionalTaskDoneData()
    local scene_line = UserDataManager:getSceneLineData()
    local cpd = 0 --百分比进度
    local status = 0 -- 0：未完成，1：可领取，2：已领取
    local area = regional_task_done[tostring(area_id)]
    local scene_line_area = scene_line[tostring(area_id)]
    local map_count = 0
    if area ~= nil then
        local scene = area.scenes[tostring(scene_id)]
        if scene ~= nil then
            cpd = scene.cpd
            status = scene.status or 0
        end
    end
    if scene_line_area ~= nil then
        local scene_line_map = scene_line_area[tostring(scene_id)]
        if scene_line_map ~= nil then
            map_count = #scene_line_map
        end
    end
    return map_count, status
end

--创建关卡点
function M:createStagePoint()
    local cur_pos = nil
    local next_stage_pos = nil
    local cur_stage_obj = nil
    local build_stage_obj = nil
    local cur_stage_id = UserDataManager:getCurStage()
    self.all_stage_tran = {}
    
    local max_stage_id = 0

    for k,v in pairs(self.transPoint) do
        local stage_point = v.transform:Find("stagePoint")
        if stage_point ~= nil then
            local build_stage_id = 0
            for i = 1, stage_point.childCount do
                local child = stage_point:GetChild(i - 1).gameObject
                local stage_id = tonumber(child.name)

                if stage_id > max_stage_id then
                    max_stage_id = stage_id
                end

                if build_stage_id < stage_id then
                    build_stage_id = stage_id
                end

                local stage_obj = ResourceUtil:GetItem("Common/stage_normal", child,"common")
                local stage_tran = stage_obj.transform
                stage_tran.localPosition = Vector3.zero
                self.all_stage_tran[stage_id] = stage_tran
                
                local stageName = "stage"
                if self.stage_table[stage_id] ~= nil and self.stage_table[stage_id].type == 2 then
                    stageName = "boss_stage"
                end
                if cur_stage_id < stage_id then
                    stageName = stageName
                elseif cur_stage_id == stage_id then
                    stageName = "cur_"..stageName
                    --cur_pos = child.transform.position

                    cur_stage_obj = child
                    self:createStageBrand(cur_stage_obj, stage_id)
                elseif cur_stage_id > stage_id then
                    stageName = "new_"..stageName
                end
                for i = 1, stage_tran.childCount do
                    local child = stage_tran:GetChild(i - 1).gameObject
                    child:SetActive(child.name == stageName)
                end
                if self.stage_table[cur_stage_id].next_stage == stage_id then
                    next_stage_pos = child.transform.position
                end
            end
            if self.stage_table[build_stage_id] then
                if cur_stage_obj ~= nil and build_stage_obj == nil and self.stage_table[build_stage_id].open_rivers ~= 0 then
                    build_stage_obj = stage_point:Find(build_stage_id).gameObject
                    if build_stage_id ~= cur_stage_id then
                        self:createStageBrand(build_stage_obj, build_stage_id)
                    end
                end
            else
                Logger.logError(build_stage_id, " stage not found id :  ")
            end
        end
        --end
    end
    local cur_stage_data = UserDataManager:getTempData("worldScene_stage") or {}
    if cur_stage_data.stage == nil or cur_stage_data.sceneId ~= SceneManager.curScene.sceneId then
        if cur_pos == nil and cur_stage_id > 0 then
            local stage_id = max_stage_id
            if cur_stage_id < max_stage_id then
                stage_id = cur_stage_id
            end
            cur_pos = self.all_stage_tran[stage_id].position
            self.cur_player_stage = stage_id
            if self.cur_map.map_id ~= nil then
                local map = self.map_table[self.cur_map.map_id]
                if self.all_stage_tran[map.stage_open] ~= nil and map.stage_open < stage_id then
                    cur_pos = self.all_stage_tran[map.stage_open].position
                    self.cur_player_stage = map.stage_open
                end
            end
        end
        UserDataManager:setTempData("worldScene_stage", {stage = self.cur_player_stage, sceneId = SceneManager.curScene.sceneId})
    else
        self.cur_player_stage = cur_stage_data.stage
        if self.all_stage_tran[cur_stage_data.stage] ~= nil then
            cur_pos = self.all_stage_tran[cur_stage_data.stage].position
        end
    end
    return cur_pos, next_stage_pos
end

--创建关卡名牌展示id
function M:createStageBrand(tran, stage_id)
    local stage_obj = ResourceUtil:GetUIItem("WorldMap/stage_brand", self.Canvas, "ui_prefabs")
    local WorldPointUI = stage_obj:GetComponent("WorldPointUI")
    WorldPointUI.target = tran.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(stage_obj.transform)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "stage_text", self.stage_table[stage_id].map_point_name)
end

--刷新迷雾和阻挡
function M:refreshFog()
    local open_map = UserDataManager.local_data:getUserDataByKey("open_map", nil)
    local is_new = open_map == nil
    open_map = open_map or {}
    local new_map = nil
    self.bridge = U3DUtil:GameObject_Find("Bridge")
    self.obstacle = U3DUtil:GameObject_Find("Obstacle")
    self.wall = U3DUtil:GameObject_Find("Wall")
    local map_table = {}
    for k,v in pairs(self.worldMap_cfg) do
        if v.worldmap_id == self.sceneId then
            table.insert(map_table, {id = k, data = v})
        end
    end
    table.sort(map_table, function(a,b) return a.data.stage_id < b.data.stage_id end)
    for k,v in pairs(map_table) do
        local open = UserDataManager:getCurStage() >= v.data.stage_id
        local effect = U3DUtil:GameObject_Find("LOD0_DSJ_Effect_Plan" .. v.id)
        if effect ~= nil then
            effect:SetActive(not open)
        end
    end
    --特效迷雾
    UserDataManager.local_data:setUserDataByKey("open_map", open_map or {})

    local yanwu = ResourceUtil:GetUIEffectItem("WorldMapMain/UI_WorldMapMain_YanWu_003", self.Canvas)
    local rect = yanwu:GetComponent("RectTransform")
    rect.anchoredPosition3D = Vector3.New(0,0,0)
    rect.localScale = Vector3.New(3,3,3)
    TimeTools:delayTimeUnity(1.2, function()
        ResourceUtil:ReturnItem(yanwu)
    end)
    TimeTools:delayTimeUnity(1, function()
        self:refreshBrand()
        self.canTransPoint = true
    end)
end

function M:setCameraPos(mapId)
    if self.transPoint[mapId] ~= nil and self.worldCamera.canMove == true then
        self.worldCamera:MoveToPos(self.transPoint[mapId].transform.position, 1, function()
            if LikeOO.Map2DControl.curMap2D == nil then
                LikeOO.Map2DControl:openMap2D(mapId)
            end
        end)
    end
end

function M:getTaskDone(scene_id, map_id)
    local regional_task_done = UserDataManager:getRegionalTaskDoneData()
    local task_count = 0
    local area = regional_task_done[tostring(scene_id)]
    if area ~= nil then
        local scene = area.scenes[tostring(map_id)]
        if scene ~= nil then
            for k,v in pairs(scene.tasks) do
                local task = self.task_table[v]
                if task.task_count ~= 1 then
                    task_count = task_count + 1
                end
            end
        end
    end
    local map_data = self.map_table[map_id]

    return task_count, map_data.regional
end

function M:refreshCurMap()
    local start_index = self.cur_map.map_index
    self.cur_map.map_id = nil
    self.cur_map.map_index = 1
    self.cur_map.day_unlock = true
    self.cur_map.isDone = false
    for i = start_index, #self.allMapData do
        local mapData = self.allMapData[i]
        local open_flag, tips_str = GameUtil:getStageUnlock(self.map_table[mapData.id].stage_open)

        if open_flag == true  then
            local task_count, total_count = self:getTaskDone(mapData.sceneId, mapData.id)
            if task_count <= total_count then
                self.cur_map.map_id = mapData.id
                self.cur_map.map_index = i

                local curDay = GameUtil:dayCompute()
                local unlock_days = self.map_table[mapData.id].unlock_days or 1
                self.cur_map.day_unlock = curDay >= unlock_days
                self.cur_map.isDone = task_count == total_count

                if task_count < total_count then
                    break
                end
            end

        end
    end
    --刷新主界面和对话界面红点
    static_rootControl:updateMsg("refresh_point", nil, "WorldMap.WorldMapMain")
    if LikeOO.Map2DControl.curMap2D ~= nil and LikeOO.Map2DControl.curMap2D.m_cur_node ~= nil then
        LikeOO.Map2DControl.curMap2D.m_cur_node:refreshRedPoint()
    end
end

function M:checkPlayerMove()
    if self.player ~= nil then
        local map = self.map_table[self.cur_map.map_id]
        local isAreaInSeason = false
        local user_season_data = UserDataManager.m_season_data
        local map_area_table = ConfigManager:getCfgByName("map_area")
        if user_season_data and map_area_table then
            isAreaInSeason = map_area_table[map.area].season <= user_season_data.season
        end
        
        if map.area == self.sceneId or isAreaInSeason == false then
            if map ~= nil and self.cur_player_stage < map.stage_open then
                local posList = {}
                local next_stage = self.cur_player_stage
                while next_stage <= map.stage_open do
                    local stage = self.stage_table[next_stage]
                    if self.all_stage_tran[next_stage] ~= nil then
                        local pos = self.all_stage_tran[next_stage].position
                        pos.y = 0
                        table.insert(posList, pos)
                        next_stage = stage.next_stage
                    else
                        break
                    end
                end
                self.player.luaViewHelper.m_animator:CrossFadeInFixedTime("run")
                self.worldCamera:SetFollow(self.player.tran)
                self.player_move_tween = self.player.tran:DOPath(posList, #posList * 0.2):OnWaypointChange(function(index)
                    if index + 1 < #posList then
                        self.player.tran.forward = posList[index + 1] - posList[index]
                    end
                end):OnComplete(function()
                    self.worldCamera:SetFollow(nil)
                    self.player.luaViewHelper.m_animator:CrossFadeInFixedTime("idle")
                    local stage = self.stage_table[map.stage_open]
                    if stage ~= nil then
                        local dir = self.all_stage_tran[stage.next_stage].position - self.player.tran.position
                        dir.y = 0
                        self.player.tran.forward = dir
                        if LikeOO.Map2DControl.curMap2D == nil and self.cur_map.day_unlock == true then
                            LikeOO.Map2DControl:openMap2D(self.cur_map.map_id)
                        end
                    end
                end)
                self.cur_player_stage = map.stage_open
                UserDataManager:setTempData("worldScene_stage", {stage = self.cur_player_stage, sceneId = SceneManager.curScene.sceneId})
            end
        else
            static_rootControl:updateMsg("change_scene", {area_id = map.area }, "WorldMap.WorldMapMain")
        end
    end
end

function M:checkMapOpen(map_id)
    local curDay = GameUtil:dayCompute()
    local unlock_days = self.map_table[map_id].unlock_days or 1
    local day_open_flag = curDay >= unlock_days
    local stage_open_flag, tips_str = GameUtil:getStageUnlock(self.map_table[map_id].stage_open)
    local mapName = self.map_table[map_id].name
    local pre_task_end = true
    local brand_str = tips_str

    if day_open_flag == false then
        if stage_open_flag == true then
            tips_str = Language:getTextByKey("worldMap_str_008", mapName, unlock_days - curDay)
            brand_str = Language:getTextByKey("worldMap_str_009", unlock_days - curDay)
        end
    else
        if stage_open_flag == true then
            if self.cur_map.map_id ~= nil and self.cur_map.map_id ~= 0 then
                if map_id ~= self.cur_map.map_id and self.map_table[map_id].stage_open > self.map_table[self.cur_map.map_id].stage_open then
                    pre_task_end = false
                    tips_str = Language:getTextByKey("worldMap_str_007", self.map_table[self.cur_map.map_id].name)
                end
            end
        end
    end

    return stage_open_flag and day_open_flag, pre_task_end, tips_str, brand_str
end

--获取任务奖励
function M:getTaskReward(map_id)
    local rewards = {}
    local task_id = {}
    for k, v in pairs(self.task_team_table) do
        if v.map_id == map_id then
            task_id = v.task_id
            break
        end
    end
    if #task_id >= 2 then
        local lastTask_id = task_id[2]
        local lastTask = self.task_table[lastTask_id]
        if lastTask then
            rewards = lastTask.item_reward or {}
        end
    end
    return rewards
end

return M;
