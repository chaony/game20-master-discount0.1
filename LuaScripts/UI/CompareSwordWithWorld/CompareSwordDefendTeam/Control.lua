local M = class("CompareSwordDefendTeamControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        local set_flag = UserDataManager.hero_data:checkMultTeamNeedSetUp("full_service_point_race")
        if set_flag then
            --self:closeView("Arena.ArenaHigher.ArenaHigher")
        else
            --if self.m_model.m_back_refresh then
            --    self:updateMsg("refresh_ui", nil, "Arena.ArenaHigher.ArenaHigher")
            --    self:updateMsg("refresh_ui", nil, "PeakArena.PeakArenaFight")
            --end
        end
        self:updateMsg("refresh_red", nil, "CompareSwordWithWorld.CompareSwordMyRace")
        self:updateMsg("refresh_red", nil, "CompareSwordWithWorld.CompareSwordRace")
        self:closeView()
    elseif msg == "order_btn" then -- 调整顺序
        self.m_model.m_edit_status = 2
        self.m_view:refreshUI()
    elseif msg == "ok_btn" then -- 保存
        self:setDefendTeams(self.m_model.m_teamKey)
        --if self.m_model.m_battle_array == true then
        --    self:topArenaSetDefendTeams()
        --else
        --    self:highArenaSetDefendTeams()
        --end
    elseif msg == "cancle_btn" then -- 取消
        self.m_model.m_edit_status = 1
        self.m_model.m_select_cell_index = -1
        self.m_model:initData()
        self.m_view:refreshUI()
    elseif msg == "formation_edit_btn" then
        self:openView("Formation", { mode = self.m_model.m_mode, formation_index = data.index ,race_type = self.m_model.m_race_typ})
        --self:openView("Formation", { mode = GlobalConfig.BATTLE_MODE.HIGH_ARENA_DEFENSE, formation_index = data.index })
        
    elseif msg == "exchange_btn" then
        if self.m_model.m_edit_status == 2 then --选择要调整的队伍
            self.m_model.m_edit_status = 3
            self.m_model.m_select_cell_index = data.index
            self.m_view:refreshUI()
        elseif self.m_model.m_edit_status == 3 then -- 交换
            self.m_model:exchangeTeam(self.m_model.m_select_cell_index, data.index)
            self.m_model.m_edit_status = 2
            self.m_model.m_select_cell_index = -1
            self.m_view:refreshUI()
        end
    elseif msg == "refresh_ui" then
        self.m_model:initData()
        self.m_view:refreshUI()
    end
end

function M:setDefendTeams(teamKey)
    local teams = self.m_model:getMultTeamParam()
    local relics = self.m_model.m_mult_solts or {}
    local function callfunc()
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
        if self.m_view then
            self.m_model.m_edit_status = 1
            self.m_model.m_select_cell_index = -1
            self.m_model:initData()
            self.m_view:refreshUI()
        end
    end
    if teamKey == nil then return end
    self.m_model:getNetData("full_service_set_defend_teams",{deployments = self.m_model.m_deployments,
                                                             normal_arrays = self.m_model.m_normal_arrays,
                                                             battle_pet = self.m_model.battle_pet,
                                                             typ = self.m_model.m_race_typ, 
                                                             teams = teams,
                                                             relics = relics}, 
            callfunc,false,nil, GlobalConfig.POST)
end


return M
