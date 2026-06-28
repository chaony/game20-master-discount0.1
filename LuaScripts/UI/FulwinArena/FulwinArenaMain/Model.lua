

local M = class("FulwinArenaMainModel", LikeOO.OODataBase)

function M:onCreate()
    self:getData("friend_arena_index")
end

function M:onEnter()
    --Logger.log(self.m_data,"friend_arena_index ====")
    --self.m_back_refresh = self.m_params.back_refresh
    --self.m_show_order_btn_flag = self.m_params.show_order_btn_flag
    self.m_edit_status = 1 -- 1 默认状态 2 选择要调整的队伍 3 调整顺序状态
    self.m_select_cell_index = -1
    --local is_open1 = BtnOpenUtil:isBtnOpen(334)
    --local is_open2 = BtnOpenUtil:isBtnOpen(335)
    --if is_open1 == true or is_open2 == true then
        self.m_defense_open = false
    --else
    --    self.m_defense_open = true
    --end
    self.m_tab_index = 1
    self.m_list_data = {}
    self:initData(self.m_data)
end

function M:initData(data)
    table.merge(self.m_data, data or {})
    self.mult_main_one = table.copy(UserDataManager.hero_data:getTeamByKey("friend_arena_defense1")) or {}
    self.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("friend_arena_defense3"))
    self.mult_solts = table.copy(UserDataManager:getMultWeaByKey("friend_arena_defense3"))
    for i = 1,3 do
        if self.mult_main_teams[i] == nil then
            self.mult_main_teams[i] = {}
        end
        if self.mult_solts[i] == nil then
            self.mult_solts[i] = {}
        end
    end
end

function M:updateData(data)
    table.merge(self.m_data, data or {})
end

function M:setEditStatus(m_edit_status)
    self.m_edit_status = m_edit_status
end

function M:setSelectIndex(m_select_cell_index)
    self.m_select_cell_index = m_select_cell_index
end

function M:exchangeTeam(index, exchange_index)
    self.mult_main_teams[index], self.mult_main_teams[exchange_index] = self.mult_main_teams[exchange_index], self.mult_main_teams[index]
    self.mult_solts[index], self.mult_solts[exchange_index] = self.mult_solts[exchange_index], self.mult_solts[index]
end

function M:refreshData(m_params)
    --self.m_activityData = m_params.activityData or {}
    --self.m_openId = self.m_activityData.open_id
    --self.m_version = m_params.m_version
    --self.m_xlsxActivity = m_params.xlsxActivity
    --self.m_mainActivityName = m_params.mainActivityName
    --
    --local serverData = m_params.serverData
    ---- 任务
    --self.m_taskData = self:trimTaskData(serverData.taskData)
    ----任务积分
    --self.m_score = serverData.score
    ---- 积分任务
    --self.m_scoreTaskData = self:trimScoreTaskData(serverData.scoreTaskData)
end

function M:setDefense()
    self.m_defense_open = not self.m_defense_open
end

function M:setTabIndex(index)
    self.m_tab_index = index
end

function M:updateListdata(data)
    if data then
        self.m_list_data = data
        table.sort(self.m_list_data, function(a, b) return a.create_time < b.create_time end)
    end
end

function M:getListId()
    local ids = {}
    for i,v in ipairs(self.m_list_data) do
        table.insert(ids, v.ring_id)
    end
    return ids
end

function M:getListData()
    if self.m_tab_index == 1 then
        return self.m_list_data
    elseif self.m_tab_index == 2 then
        local list = {}
        for i,v in ipairs(self.m_list_data) do
            if v.typ == 1 then
                table.insert(list, v)
            end
        end
        return list
    elseif self.m_tab_index == 3 then
        local list = {}
        for i,v in ipairs(self.m_list_data) do
            if v.typ == 2 then
                table.insert(list, v)
            end
        end
        return list
    end
end

return M