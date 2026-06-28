local M = class("WorldMapPlunderEnemyControl",LikeOO.OOControlBase)

function M:onEnter()
    
    if #self.m_model.m_data.station_list <= 0 then
        self.m_view:refreshUI()
    end
    for k, v in pairs(self.m_model.m_data.station_list) do
        if self.m_model.m_params.cell_data.obj_id == tonumber(v.building_id)  then
            self.m_view:battle_end_initialUI()
            -- self:occupy_battle_end(v)
        end
         self.m_view:refreshUI()
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "evacuate_btn" then -- 撤离
        self:evacuateData(self.m_model.m_params.cell_data)
    elseif msg == "punishment_btn" then -- 惩戒
        self:occupy_battle_start(self.m_model.m_params.cell_data)

    elseif msg == "dispatch_btn" then -- 一键派遣
        self:dispatch_oneKeyData(self.m_model.m_params.cell_data)
    elseif msg == "accomplish_btn" then -- 完成
        self:dispatchData(self.m_model.m_params.cell_data)

    elseif msg == "cell_btn" then -- 点击驻守阵容
       --点击驻守阵容 打开选择武神界面
        local function callback( response )
             self.m_view:setGarrisonUI(response,data) 
        end

        local function filter_func( heroIds )
            return self.m_model:getAllHero(heroIds)
        end
        
        self:openView("Pops.HeroSelectPop",{callback = callback,filter_func = filter_func})
    end

end
--惩戒 战斗前发送战斗前数据
function M:occupy_battle_start(data)


    local map_info_cfg = ConfigManager:getCfgByName("fort_info")
    --local stage_battle_tab = ConfigManager:getCfgByName("stage_battle")

    local atk_deployment = UserDataManager.hero_data:getDeploymentByKey("stage")
        local stage_team = UserDataManager.hero_data:getTeamByKey("stage")
        local can_battle = false
        local team = {}
        for i = 1, 5 do
            team[i] = stage_team[i] or ""
            if team[i] ~= "" then
                can_battle = true
            end
        end
        if not can_battle then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0152"), delay_close = 2})
            return
        end
        local function netCallback(response)
            local battle_type = "occupy_battle_start"
            self:closeView()
        self:openView("Formation", {mode = GlobalConfig.BATTLE_MODE.BIG_MAP,battle_id = map_info_cfg[data.obj_id].init_enemy,building_id = data.obj_id,type = battle_type})
        end
        local params = {}
        params.team = team
        params.deployment = atk_deployment
        params.building_id = data.obj_id
        self.m_model:getNetData("big_map_plunder_occupy_front", params, netCallback, nil,nil,GlobalConfig.POST)
        UserDataManager:setTempData("map_occupy_battle_building_id", data.obj_id)
        -- UserDataManager:setTempData("map_battle_event_type", data.event_type)
end

function M:dataUpdateEvent(event, data)

end
--撤离数据
function M:evacuateData(data)
   
    local map_event_cfg = ConfigManager:getCfgByName("fort_info")
    local map_event_cfg_item = map_event_cfg[data.obj_id]
   

    local params = 
    {
        on_ok_call = function(msg)
            --点击确定的处理！！                  
            local function netCallback(response)
                self:closeView()
            end
            local params = {}
            params.building_id = data.obj_id
            self.m_model:getNetData("big_map_plunder_evacuate", params, netCallback, nil,nil,GlobalConfig.POST)
        end,
        no_close_btn = false,
        text =string.format(Language:getTextByKey("worldMapPlunder_hint"),Language:getTextByKey(map_event_cfg_item.name))
    }
    static_rootControl:openView("Pops.CommonPop", params)
end

--一键派遣数据
function M:dispatch_oneKeyData(data)
    --local function netCallback(response)
        self.m_view:dispathHeroData(data)
    --end
    --local params = {}
    --params.building_id = data.obj_id
    --self.m_model:getNetData("big_map_plunder_dispatch_onekey", params, netCallback, nil,nil,GlobalConfig.POST)
end

--完成派遣数据
function M:dispatchData(data)
    local function netCallback(response)
        self.m_model.cur_buildingTeam_data = response
        self:closeView()
    end
    local params = {}
    params.building_id = data.obj_id
    if self.m_model.cur_Garrison ~= nil and #self.m_model.cur_Garrison[self.m_model.cur_building_id] > 0 then
        params.team = self.m_model.cur_Garrison[self.m_model.cur_building_id]

        self.m_model:getNetData("big_map_plunder_dispatch", params, netCallback, nil,nil,GlobalConfig.POST)
    else
        self:closeView()
    end
    
end

function M:destroy()
    M.super.destroy(self)
end



return M
