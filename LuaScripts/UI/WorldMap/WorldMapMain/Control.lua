local M = class("WorldMapMainControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.WorldMap.WorldMapMain.Guide"
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CHAT_REFRESH, {self, self.onRefreshChatInfo})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CHAT_INIT, {self, self.onInitChat})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    
    LikeOO.Map2DControl:init(self)
    local cur_map = GameUtil:getCurMapData()
    local now_map = 91
    if cur_map ~= nil then
        now_map = cur_map.area
    end

    --切换到世界地图中
    self:changeScene(now_map)
    
    RedPointUtil:jiangHuRedPointSet()
end

function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(30, 1)
    if have_guide then
        self.m_view:lockTouch()
        self.m_is_lock_view = true
    end
    if not have_guide then
        if #self.m_model.m_data.travel_log > 0 then
            self:openView("WorldMap.WorldMapJournal", {show_gift = true})
        end
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent") 
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 33})
    elseif msg == "talk" then
        local function callback(event_data)
            if data.callback then
                data.callback(event_data)
            end
        end
        self:openView("Guide.GuideDrama", {dialog_id = data.talk_id, callback = callback, choise = data.choise, choise_id = data.choise_id, dialogue_type = data.dialogue_type})
    elseif msg == "send_move_msg" then
        local function netCallback(response)
            if response then
                RewardUtil:rewardTipsByData(response.reward)
            end
        end
        local params = { map_pos = { data.x,data.y }, event_id = data.event_id, type = data.event_type }
        self.m_model:getNetData("big_map_move", params, netCallback,nil,true,GlobalConfig.POST)
    elseif msg == "bag_btn_mask" then --行囊遮罩
        local red_flag ,tips_str =  BtnOpenUtil:isBtnOpen(90)
        GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2})
    elseif msg == "qy_btn_mask" then --奇遇遮罩
        local red_flag ,tips_str =  BtnOpenUtil:isBtnOpen(91)
        GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2})
    elseif msg == "completion_reward_btn_mask" then --完成度遮罩
        local red_flag ,tips_str =  BtnOpenUtil:isBtnOpen(92)
        GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2})
    elseif msg == "xs_btn_mask" then --悬赏遮罩
        local red_flag ,tips_str =  BtnOpenUtil:isBtnOpen(93)
        GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2})
    elseif msg == "zd_btn_mask" then --驻地遮罩
        local red_flag ,tips_str =  BtnOpenUtil:isBtnOpen(94)
        GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2})
    elseif msg == "prestige_btn_mask" then --威望遮罩
        local red_flag ,tips_str =  BtnOpenUtil:isBtnOpen(100)
        GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2})
    elseif msg == "xs_btn" then -- 悬赏
        self:openView("WorldMap.WorldMapRewardNew",{map_indexData = self.m_model.m_data})
    elseif msg == "qy_btn" then -- 奇遇
        self:openView("WorldMap.WorldMapTask.WorldMapEvents", {task_id = 0})
    elseif msg == "zd_btn" then -- 驻地
        self:openView("WorldMap.WorldMapPlunder")
    elseif msg == "prestige_btn" then -- 威望
        self:openView("WorldMap.WorldMapPrestige")
    elseif msg == "click_point_msg" then -- 点击资源点  
        self:openView("WorldMap.WorldMapPlunder.WorldMapPlunderEnemy",{cell_data = data,m_data = self.m_model.m_data})    
    elseif msg == "time_limit_btn" then -- 限时
        self:switchTabBtn(1)
    elseif msg == "task_btn" then -- 任务
        self:switchTabBtn(2)
    elseif msg == "adventure_go_event_btn" then
        SceneManager.curScene:clickUIItem(data.cell_data.data.event_id, data.cell_data.event_type, data.cell_data.npc_id);
    elseif msg == "task_cell_btn" then -- 前往做任务
        local task_table = ConfigManager:getCfgByName("regional_task")
        local task = task_table[data.cell_data.task_id]
        if data.cell_data.status == 5 then
            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_0600"), delay_close = 2})
        else
            local task_team_table = ConfigManager:getCfgByName("regional_task_team")

            local task_team = task_team_table[task.tasks_types]
            self:openView("WorldMap.WorldMapTask.WorldMapEvents", {open_tab_index = task_team.tasks_types, task_id = data.cell_data.task_id})

            --local motherId = self:getMotherMapId(task.chapter)
            --local map = LikeOO.Map2DControl.curMap2D
            --if map == nil then
            --    SceneManager.curScene:clickObject(motherId);
            --else
            --    if motherId ~= map.motherMapId then
            --        local targetMap = map.map_table[motherId]
            --        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_0583", Language:getTextByKey(targetMap.name)), delay_close = 2})
            --    end
            --end
        end
    elseif msg == "map_chioce_option" then -- 选择选项
        local function netCallback(response)
            RewardUtil:rewardTipsByData(response.reward)
            if data.event_type == GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT then
                if not data.finish_flag then
                    self:closeView("WorldMap.WorldMapTask.WorldMapEncounterDetail")
                else
                    self:updateMsg("select_update_ui", nil, "WorldMap.WorldMapTask.WorldMapEncounterDetail")
                end
            end
            if data.sel_event_id then
                -- 带选项的npc id不会改变，不需要主动前往，直接触发
                SceneManager.eventMgr:addWorldMapEvent(data.sel_event_id, data.event_type)
                SceneManager.eventMgr:trigger( data.x, data.y )
            end
        end
        local params = {}
        params.event_id = data.event_id;
        params.option_id = data.option_id;
        params.type = data.event_type;
        params.map_pos = { data.x,data.y }
        self.m_model:getNetData("big_map_choice_option", params, netCallback, nil,nil,GlobalConfig.POST)
    elseif msg == "map_event_battle_start" then -- 战斗开始
        self:goBattle(data)
    elseif msg == "map_enter_map_event" then -- 进入地图
        --local function netCallback()
        --    
        --end
        --local params = {}
        --params.event_id = data.event_id;
        --self.m_model:getNetData("big_map_enter_map_event", params, netCallback, nil,nil,GlobalConfig.POST)
    elseif msg == "auto_open_func" then
        if self.m_model.m_auto_open_func == "world_map_events" then
            self.m_model.m_auto_open_func = nil
            self:openView("WorldMap.WorldMapTask.WorldMapEvents", {open_tab_index = self.m_model.m_auto_open_tab_index})
        end
        self:checkTaskGuide()
    elseif msg == "check_guide" then
        if self.m_is_lock_view then
            self.m_view:unlockTouch()
            self.m_is_lock_view = false
        end
        if not self:hasChild("Guide.GuideDrama") then
            self.m_guide:checkGuide()
        else
            Logger.logError("has Guide.GuideDrama")
        end
    elseif msg == "battle_end_refresh_ui" then
        self:closeView("WorldMap.WorldMapTask.WorldMapEncounterDetail")
        SceneManager:changeScene(self.m_model.curSceneId, self.m_model.m_data,false)
        local result = data.data.result
        local drama_id = self.m_model:getBattleEndDramaId(result)
        if drama_id ~= 0 then
            self:openView("Guide.GuideDrama", {dialog_id = drama_id, callback = function()
                self:updateMsg("check_guide")
            end})
        else
            self:updateMsg("battle_end" , {cell_data = self.m_model.m_data})
        end
        self.m_model.battle_end_data = data.data

        UserDataManager:setTempData("map_battle_event_id", nil)
        UserDataManager:setTempData("map_battle_event_type", nil)
        self:updateMsg("check_guide", nil, "Guide.GuideDrama")
    elseif msg == "load_scene_finish" then
        if self.m_model.battle_end_data then
            local battle_end_data = self.m_model.battle_end_data
            self.m_model.battle_end_data = nil
            local event_type = UserDataManager:getTempData("map_battle_event_type")
            if event_type == GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT then -- 客户端展示最后一步的信息
                local team_id = UserDataManager:getTempData("map_battle_team_id")
                local encounter_data = UserDataManager:getCompleteEncounterMapEventDataByTeamId(team_id)
                if encounter_data then
                    local encounter_cfg = ConfigManager:getCfgByName("encounter")
                    local encounter_cfg_item = encounter_cfg[encounter_data.event_id]
                    if encounter_cfg_item then
                        self:openView("WorldMap.WorldMapTask.WorldMapEncounterDetail", {event_data = encounter_cfg_item, event_type = event_type, x = 0, y = 0, finish_show = true, team_id = team_id})
                    end
                end
            end
            if battle_end_data.reward then
                RewardUtil:rewardTipsByData(battle_end_data.reward)
            end
        end
    elseif msg == "encounter_event_btn" then -- 奇遇事件按钮
        self.m_view:visibleEncounterEventBtn(false)
        local cell_data = self.m_model.m_cur_encounter_map_event
        if cell_data then
            local server_time = UserDataManager:getServerTime()
            local end_ts = self.m_model.m_cur_encounter_map_event.data.end_ts or 0
            local diff_time = end_ts - server_time
            if diff_time > 0 then
                --SceneManager.curScene:clickUIItem(cell_data.data.event_id, cell_data.event_type, cell_data.data.npc_id)
                self:openView("WorldMap.WorldMapTask.WorldMapEvents", {open_tab_index = 3})
            else
                self.m_view:refreshEncounterMapEvent()
            end
        end
    elseif msg == "big_map_encounter_trigger" then
        local function netCallback(response)

        end
        local params = { map_pos = { data.x,data.y }, npc_id = data.obj_id}
        self.m_model:getNetData("big_map_encounter_trigger", params, netCallback,nil,true,GlobalConfig.POST)
    elseif msg == "map_area_btn" then -- 地图区域
        self:openView("WorldMap.WorldMiniMap", {map_id = self.m_model.curSceneId})
    elseif msg == "bag_btn" then
        self:openView("Item.ItemList", {isShowRunescapeItem = true})
    elseif msg == "formation_btn" then
        self:openView("Formation", {mode = GlobalConfig.BATTLE_MODE.STAGE_SET_TEAM, from_view = "WorldMapMain"})
    elseif msg == 'chat_btn2' then
        self:openView("Chat2")
    elseif msg == "completion_reward_btn" then
        local params = { area_id = SceneManager.curScene.sceneId}
        self:openView("WorldMap.WorldMapLegend", params)
    elseif msg == "travels_btn" then
        self:openView("WorldMap.WorldMapComplete")
    elseif msg == "receive_world_box_reward" then
        self:receiveWorldBoxReward(data)
    elseif msg == "guide_1" then
        self:updateMsg("check_guide", nil, "Guide.GuideDrama")
    elseif msg == "guide_close_mapNode" then
        
    elseif msg == "path_btn" then
        
    elseif msg == "brand_btn" then
    
    elseif msg == "item_click" then
        
    --elseif msg == "change_scene" then
    --    SceneManager:changeScene(self.m_model.curSceneId,self.m_model.m_data,false);
    elseif msg == "refresh_task" then
        self.m_view:updateEventLoopScroll()
        if LikeOO.Map2DControl.curMap2D ~= nil then
            LikeOO.Map2DControl.curMap2D.m_cur_node:updateEventLoopScroll()
        end
    elseif msg == "challenge_btn" then --挑战首领(打开配置阵容界面)
        self:updateMsg("challenge_btn", {click_obj = data, scene = SceneManager.curScene.sceneId}, "parent")
        self:setOnceTimer(1, function()
            self:closeView()
        end)
    elseif msg == "change_scene" then
        if data ~= nil then
            if data.area_id ~= self.m_model.curSceneId then
                self:changeScene(data.area_id, data.view_callBack)
            end
        else
            if SceneManager.curScene.sceneId ~= self.m_model.curSceneId then
                self:changeScene(self.m_model.curSceneId, nil)
            end
        end
    elseif msg == "refresh_point" then
        self.m_view:refreshRedPoint()
    end 
end

function M:checkTaskGuide()
    -- 满足要求触发引导
    --if self.m_guide then
    --    local common = ConfigManager:getCommonValueById(282)
    --    if type(common) == "table" then
    --        local data = self.m_view.m_loop_scroll_view.m_show_data
    --        for i,v in ipairs(data) do
    --            if v == common[2] then
    --                UserDataManager.guide_data:setAnyTeamGuide(common[1])
    --                break
    --            end
    --        end
    --    end
    --    self.m_guide:checkGuide()
    --end
end

--  领取江湖宝箱奖励  npc_id: 1    map_pos: [1, 2]   
function M:receiveWorldBoxReward(data)
    local function netCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        SceneManager.curScene:receiveWorldBoxRewardFinish(data)
    end
    local params = {}
    params.npc_id = data.obj_id
    params.map_pos = { data.x,data.y }
    self.m_model:getNetData("big_map_receive_world_box_reward", params, netCallback, nil,nil,GlobalConfig.POST)
end

function M:goBattle(data)
    --local atk_deployment = UserDataManager.hero_data:getDeploymentByKey("stage")
    --local stage_team = UserDataManager.hero_data:getTeamByKey("stage")
    --local can_battle = false
    --local team = {}
    --for i = 1, 5 do
    --    team[i] = stage_team[i] or ""
    --    if team[i] ~= "" then
    --        can_battle = true
    --    end
    --end
    --if not can_battle then
    --    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0152"), delay_close = 2})
    --    return
    --end
    --local function netCallback(response)
    --    if data.event_type == GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT then
    --        self:closeView("WorldMap.WorldMapTask.WorldMapEncounterDetail")
    --    end
    --    self:openView("Loading.BattleLoading",{callfunc = function(open_flag)
    --        if open_flag == "open_view" then
    --            self:openView("GamePanel", {data = response, mode = GlobalConfig.BATTLE_MODE.BIG_MAP})
    --        end
    --    end})
    --end
    --local params = {}
    --params.event_id = data.event_id
    --params.type = data.event_type
    --params.team = team
    --params.deployment = atk_deployment
    --params.map_pos = { data.x,data.y }
    --self.m_model:getNetData("big_map_event_battle_start", params, netCallback, nil,nil,GlobalConfig.POST)
    UserDataManager:setTempData("map_battle_event_id", data.event_id)
    UserDataManager:setTempData("map_battle_event_type", data.event_type)
    UserDataManager:setTempData("map_battle_pos", { data.x,data.y })
    if data.event_type == GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT then
        local encounter_cfg = ConfigManager:getCfgByName("encounter")
        local encounter_cfg_item = encounter_cfg[data.event_id] or {}
        local battle_id = encounter_cfg_item.event_battle or 0
        if battle_id > 0 then
            self:openView("Formation", {battle_id = battle_id, type = "adventure_battle_start", mode = GlobalConfig.BATTLE_MODE.BIG_MAP})
        end
    end
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "map_task_update" or curEvent == "deadline_task_update" or curEvent == "ongoing_task_update" then
        --self.m_view:switchTabNode(self.m_model.m_sel_tab_index)
    elseif curEvent == "encounter_update" then
        self.m_view:refreshEncounterMapEvent()
        if UserDataManager.new_ongoing_teams then
            self.m_view:visibleEncounterEventBtn(true)
            UserDataManager.new_ongoing_teams = false
        end
    elseif curEvent == "task_done_update" then
        self.m_view:refreshRedPoint()
    elseif curEvent == "items_update" then
        self.m_view:refreshRedPoint()
    end
end

function M:onRefreshChatInfo()
    self.m_view:RefreshChatInfo()
end

function M:onInitChat()
    self.m_view:InitMsg()
end

--获取任务根场景id
function M:getMotherMapId(id)
    local map_table = ConfigManager:getCfgByName("regional_map")

    local mother_map_id = map_table[id].mother_map_id
    if mother_map_id > 0 then
        return self:getMotherMapId(mother_map_id)
    end
    return id
end

function M:closeViewEvent(event, data)
    local view_name = data.name or ""
    if view_name == "Loading.SyncLoadBigLoading" then
        self:updateMsg("auto_open_func")
    elseif view_name == "Item.ItemList" then
        self.m_view:refreshRedPoint()
    end
end

function M:changeScene(sceneId, callBack)
    self.m_model.curSceneId = sceneId
    local param = {view_callBack = callBack}
    SceneManager:changeScene(sceneId, param, false);
    if UserDataManager.new_ongoing_teams then
        self.m_view:visibleEncounterEventBtn(true)
        UserDataManager.new_ongoing_teams = false
    end
    self.m_view:refreshTitle(sceneId)
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CHAT_REFRESH, {self, self.onRefreshChatInfo})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CHAT_INIT, {self, self.onInitChat})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    M.super.destroy(self)
end

return M
