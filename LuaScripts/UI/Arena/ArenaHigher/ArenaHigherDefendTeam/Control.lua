---@class ArenaHigherDefendTeamControl:OOControlBase
---@field m_model ArenaHigherDefendTeamModel
local M = class("ArenaHigherDefendTeamControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        local set_flag = UserDataManager.hero_data:checkMultTeamNeedSetUp("high_arena_defense")
        if set_flag then
            --self:closeView("Arena.ArenaHigher.ArenaHigher")
        else
            if self.m_model.m_back_refresh then
                self:updateMsg("refresh_ui", nil, "Arena.ArenaHigher.ArenaHigher")
                self:updateMsg("refresh_ui", nil, "PeakArena.PeakArenaFight")
            end
        end
        self:closeView()
    elseif msg == "order_btn" then -- 调整顺序
        self.m_model.m_edit_status = 2
        self.m_view:refreshUI()
    elseif msg == "ok_btn" then -- 保存
        if self.m_model.m_battle_array == true then
            self:topArenaSetDefendTeams()
        elseif self.m_model.m_is_liansaiZF then
            self:zfLianSaiSetDefendTeams()
        else
            self:highArenaSetDefendTeams()
        end
    elseif msg == "cancle_btn" then -- 取消
        self.m_model.m_edit_status = 1
        self.m_model.m_select_cell_index = -1
        self.m_model:initData()
        self.m_view:refreshUI()
    elseif msg == "formation_edit_btn" then
       -- self:openView("Loading.BattleLoading", {callfunc = function(open_flag)
           -- if open_flag == "open_view" then
        if self.m_model.m_battle_array == true then
            self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.TOP_ARENA, formation_index = data.index})
        elseif self.m_model.m_is_liansaiZF then
            self:openView("Formation",
                    {
                        mode = GlobalConfig.BATTLE_MODE.ZF_ARENA_DEFENSE_MUL,
                        formation_index = data.index,
                        team_num=self.m_model.m_team_num,
                        ban_num=self.m_model.ban_num,
                        forbidden_hero_ids=self.m_model.ban_hero_ids,
                        rise_id=self.m_model.rise_id,
                        week_rule=self.m_model.week_rule})
        else
            self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.HIGH_ARENA_DEFENSE, formation_index = data.index})
        end
          --  end
        -- end })
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
    elseif msg=="refresh_ban_heros" then
        self.m_model.ban_hero_ids=data.heros_ban
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
	self.m_model:getNetData("high_arena_set_defend_teams",{teams = teams,relics = relics}, callfunc,false,nil, GlobalConfig.POST)	
end

-- teams: {1: [hero_oid], 2: [hero_oid], 3: [hero_oid]}
function M:topArenaSetDefendTeams()
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
	self.m_model:getNetData("top_arena_set_teams",{teams = teams,relics = relics}, callfunc,false,nil, GlobalConfig.POST)	
end

function M:zfLianSaiSetDefendTeams()
    local callfunc=function()
        self:saveCallFunc()
    end
    local teams = self.m_model:getMultTeamParam()
    local relics = self.m_model.m_mult_solts or {}
    local normal_arrays=UserDataManager:getMultNormalArray("rise_arena_def_mul")
    local deployments=UserDataManager.hero_data:getMultDeploymentByKey("rise_arena_def_mul")
    self.m_model:getNetData("rise_arena_set_defends",
            {heros_ban=self.m_model.ban_hero_ids,
             normal_arrays = normal_arrays ,
             mul_team =true, teams = teams, relics =relics,
             deployments = deployments}, callfunc,false,nil,
            GlobalConfig.POST)
end

function M:saveCallFunc()
    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
    if self.m_view then
        self.m_model.m_edit_status = 1
        self.m_model.m_select_cell_index = -1
        self.m_model:initData()
        self.m_view:refreshUI()
    end
end

return M
