local M = class("MythArenaDefendTeamPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        local set_flag = UserDataManager.hero_data:checkMultTeamNeedSetUp("myth_arena_defense")
        if set_flag then
            --self:closeView("Arena.ArenaHigher.ArenaHigher")
        else
            if self.m_model.m_back_refresh then
                self:updateMsg("refresh_ui", nil, "MythArena.MythArenaMain")
            end
        end
        self:closeView()
    elseif msg == "order_btn" then -- 调整顺序
        self.m_model.m_edit_status = 2
        self.m_view:refreshUI()
    elseif msg == "ok_btn" then -- 保存
        self:highArenaSetDefendTeams()
    elseif msg == "cancle_btn" then -- 取消
        self.m_model.m_edit_status = 1
        self.m_model.m_select_cell_index = -1
        self.m_model:initData()
        self.m_view:refreshUI()
    elseif msg == "formation_edit_btn" then
        self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.MYTH_ARENA_DEFENSE, formation_index = data.index})
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

-- teams: {1: [hero_oid], 2: [hero_oid], 3: [hero_oid]}
function M:highArenaSetDefendTeams()
    local teams = self.m_model:getMultTeamParam()
    local function callfunc()
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
        if self.m_view then
            self.m_model.m_edit_status = 1
            self.m_model.m_select_cell_index = -1
            self.m_model:initData()
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("myth_arena_set_defend_teams",{teams = teams}, callfunc,false,nil, GlobalConfig.POST)
end


return M
