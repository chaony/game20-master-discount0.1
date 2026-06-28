local M = class("HuashanSwordDefendTeamControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        local set_flag = UserDataManager.hero_data:checkMultTeamNeedSetUp("high_arena_defense")
        if set_flag then
            --self:closeView("Arena.ArenaHigher.ArenaHigher")
        else
            if self.m_model.m_back_refresh then
                self:updateMsg("refresh_ui", nil, "HuashanSword.HuashanSwordMain")
                --self:updateMsg("refresh_ui", nil, "PeakArena.PeakArenaFight")
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
        local races = self.m_model:getCurVsnRaces()
        self:openView("Formation",{races = races, mode = GlobalConfig.BATTLE_MODE.HUASHAN_SWORD_DEFENSE, formation_index = data.index})
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
	self.m_model:getNetData("arena_mountain_hua_set_defend_teams",{teams = teams,relics = relics}, callfunc,false,nil, GlobalConfig.POST)	
end

return M
