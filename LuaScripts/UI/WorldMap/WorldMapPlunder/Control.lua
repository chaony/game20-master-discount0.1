local M = class("WorldMapPlunderControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "tab_click" then --点击选择驻地详情和驻地信息按钮
        self.m_view:switchTabForPlunderNode(data)
    elseif msg == "select_Item_click" then --点击英雄框打开选择武神界面
        -- local function callback( ... )
        --     print("点击")
        -- end
        -- self:openView("Pops.HeroSelectPop",{callback = callback})
    elseif msg == "atk_btn" then --点击驻地界面的打回来
        self:pillage_battle_start(data)
    elseif msg == "event_dispatch_btn" then--点击一键派遣 ，点击驻地界面的一键派遣
        self:dispatch_oneKeyData(data)
    elseif msg == "event_confirm_btn" then--点击确定，点击驻地界面的确定
         self:dispatchData(data)
    -- elseif msg == "cell_btn" then -- 点击驻守阵容
    --    --点击驻守阵容 打开选择武神界面
    --     local function callback( response )
    --          self.m_view:setGarrisonUI(response,data) 
    --     end

    --     local function filter_func( heroIds )
    --         return self.m_model:getAllHero(heroIds)
    --     end
        
    --     self:openView("Pops.HeroSelectPop",{callback = callback,filter_func = filter_func})
    
    end
end
--掠夺战斗前
function M:pillage_battle_start(data)

         local map_info_cfg = ConfigManager:getCfgByName("fort_info")
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
            local battle_type = "pillage_battle_start"

            self:openView("Formation", {mode = GlobalConfig.BATTLE_MODE.BIG_MAP,battle_id = map_info_cfg[data.item_cell_data.cell_data.building_id].init_enemy,building_id = data.item_cell_data.cell_data.building_id,type = battle_type,event_id = data.index})
           
        end
        local params = {}
        params.team = team
        params.deployment = atk_deployment
        params.event_id = data.index 
        params.building_id = data.item_cell_data.cell_data.building_id
        self.m_model:getNetData("big_map_plunder_seize_front", params, netCallback, nil,nil,GlobalConfig.POST)

        UserDataManager:setTempData("plunder_seize_front_battle",{building_id = data.item_cell_data.cell_data.building_id,event_id = data.index });
       
end
function M:dataUpdateEvent(event, data)

end
--一键派遣
function M:dispatch_oneKeyData(data)
   -- local function netCallback(response)
        self.m_view:dispathHeroData(data)
        --self:closeView()
    -- end
    -- local params = {}
    -- params.building_id = data.cell_data.building_id
    -- self.m_model:getNetData("big_map_plunder_dispatch_onekey", params, netCallback, nil,nil,GlobalConfig.POST)
end

--完成派遣数据
function M:dispatchData(data)
    local function netCallback(response)
        --s-elf.m_model.cur_buildingTeam_data = response
        --self:closeView()
    end
    local params = {}
    params.building_id = data.cell_data.building_id
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
