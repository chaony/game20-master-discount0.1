local M = class("WorldMapMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
    self:getData("big_map_index")
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateHandler})
end

function M:onEnter()
    self.m_open_tab_index = 1
    self.m_default_scene = self.m_params.default_scene
    self.m_auto_open_func = self.m_params.auto_open_func
    self.m_auto_open_tab_index = self.m_params.auto_open_tab_index
    self.regional_task_team_cfg = ConfigManager:getCfgByName("regional_task_team")
    self.regional_task_cfg = ConfigManager:getCfgByName("regional_task")
    self.article_opt_table = ConfigManager:getCfgByName("regional_article_option")
    UserDataManager:setTasksData(self.m_data.tasks)
    UserDataManager:setCloseOptionData(self.m_data.closeoption)
    UserDataManager:setDelegationData(self.m_data.delegation_ids)
    UserDataManager:setSceneLineData(self.m_data.scene_lines)
    UserDataManager:setOngoingTaskData(self.m_data.ongoing_task)
    UserDataManager:setRegionalTaskDoneData(self.m_data.regional_task_done)
    self:syncTrackTaskData()
end

function M:getEncounterMapEventData()
    local encounter_cfg = ConfigManager:getCfgByName("encounter")
    local encounter_team_cfg = ConfigManager:getCfgByName("encounter_team")
    local map_event = UserDataManager:getEncounterMapEventData()
    local show_data = {}
    for k, v in pairs(map_event) do
        local team_id = tonumber(k)
        local map_event_cfg_item = encounter_cfg[v.event_id]
        local encounter_team_cfg_item = encounter_team_cfg[team_id]
        if map_event_cfg_item and encounter_team_cfg_item and v.end_ts then
            table.insert(show_data, {team_id = team_id, cfg = map_event_cfg_item, data = v, event_type = GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT, team_cfg = encounter_team_cfg_item})
        end
    end
    table.sort(show_data, function(data1, data2)
        return data1.data.end_ts < data2.data.end_ts
    end)
    return show_data
end

function M:getBattleEndDramaId(result)
    local event_id = UserDataManager:getTempData("map_battle_event_id")
    local event_type = UserDataManager:getTempData("map_battle_event_type")
    local drama_id = 0
    if event_type == GlobalConfig.WORLD_MAP_EVENT.ADVENTURE_EVENT then
        local encounter_cfg = ConfigManager:getCfgByName("encounter")
        local item_cfg = encounter_cfg[event_id] or {}
        drama_id = result == 1 and item_cfg.event_after or item_cfg.defeat_id
    end
    return drama_id or 0
end

function M:getRegionalTaskData()
    local regional_task_cfg = ConfigManager:getCfgByName("regional_task")
    local map_event = UserDataManager:getOngoingTaskData()
    local show_data = {}
    for k, v in pairs(map_event) do
        for k1,v1 in pairs(v) do  -- "101": [1]  # 场景id: [任务id]   地图id和npc的id对应
            local regional_task_cfg_item = regional_task_cfg[v1]
            if regional_task_cfg_item then
                table.insert(show_data, {data = {event_id = v1}, cfg = regional_task_cfg_item, npc_id = tonumber(k), event_type = GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT})
            end 
        end
    end
    return show_data
end

--获取主线任务
function M:getMainTaskData()
    local map_event = UserDataManager:getTasksData()
    local show_data = {}
    for k, v in pairs(map_event) do
        local regional_task_cfg_item = self.regional_task_cfg[tonumber(k)]
        local task_team = self.regional_task_team_cfg[regional_task_cfg_item.tasks_types]
        if task_team and task_team.tasks_types == 1 then
            if v.status == 5 then
                local opt_id = regional_task_cfg_item.option_id
                local opt = self.article_opt_table[opt_id[1]]
                if opt ~= nil then
                    local task = self.regional_task_cfg[opt.start_event]
                    table.insert(show_data, {task_team_id = task.tasks_types, task_id = opt.start_event, Photo_Resources = task.Photo_Resources, event_type = GlobalConfig.WORLD_MAP_EVENT.MAIN_EVENT, status = v.status})
                end
            else
                table.insert(show_data, {task_team_id = regional_task_cfg_item.tasks_types, task_id = tonumber(k), Photo_Resources = regional_task_cfg_item.Photo_Resources, event_type = GlobalConfig.WORLD_MAP_EVENT.MAIN_EVENT, status = v.status})
            end
        end
    end
    return show_data
end

--获取支线任务
function M:getTrackBranchTaskData()
    local map_event = UserDataManager.local_data:getUserDataByKey("track_task", { })
    local tasks = UserDataManager:getTasksData()
    local show_data = {}
    local isChange = false
    for k, v in pairs(map_event) do
        if tasks[tostring(v)] ~= nil then
            local regional_task_cfg_item = self.regional_task_cfg[v]
            local task_team = self.regional_task_team_cfg[regional_task_cfg_item.tasks_types]

            if task_team == nil or task_team.tasks_types ~= 1 then
                table.insert(show_data, {task_id = v, Photo_Resources = regional_task_cfg_item.Photo_Resources, event_type = GlobalConfig.WORLD_MAP_EVENT.BRANCH_EVENT})
            end
        else
            table.removebyvalue(map_event, v)
            isChange = true
        end
    end
    if isChange == true then
        UserDataManager.local_data:getUserDataByKey("track_task", { })
    end
    return show_data
end

function M:syncTrackTaskData()
    local track_task = {}
    local update_data = UserDataManager.tasks
    for k, v in pairs(update_data) do
        local task_id = tonumber(k)
        local task_team_id = self.regional_task_cfg[task_id].tasks_types
        local task_team = self.regional_task_team_cfg[task_team_id]
        track_task[tostring(task_team.map_id)] = task_id
    end
    UserDataManager.local_data:setUserDataByKey("track_task", track_task)
end

function M:dataUpdateHandler(eventName, data)
    if data.event == "sync_map_task" then
        self:syncTrackTaskData()
        static_rootControl:closeView("Guide.GuideDrama")
        if  LikeOO.Map2DControl.curMap2D.m_cur_node ~= nil and IsNull(LikeOO.Map2DControl.curMap2D.m_cur_node.m_luaBehaviour) == false then
            LikeOO.Map2DControl.curMap2D:refreshUI()
            LikeOO.Map2DControl.curMap2D.m_cur_node:refreshTaskInfo()
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateHandler})
    M.super.destroy(self)
end

return M
