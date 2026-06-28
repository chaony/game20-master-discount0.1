---@class ArenaTopDefendTeamControl:OOControlBase
---@field m_model ArenaTopDefendTeamModel
local M = class("ArenaTopDefendTeamControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        local set_flag = UserDataManager.hero_data:checkMultTeamNeedSetUp("top_race_arena_defense", 2)
        if set_flag then
            --self:closeView("Arena.ArenaRace.ArenaRace")
        else
            if self.m_model.m_back_refresh then
                self:updateMsg("refresh_ui", nil, "Arena.ArenaRace.ArenaFiveRace")
                self:updateMsg("refresh_ui", nil, "Arena.ArenaRace.ArenaRace")
                self:updateMsg("refresh_ui", nil, "PeakArena.PeakArenaFight")
            end
        end
        self:closeView()
    elseif msg == "help_btn" then
        local params = {}
        params.title = "hunt_treasure_str_028"
        params.content = "tid#TianJiSai_des_5"
        self:openView("Pops.CommonHelpPop", params)
  
    elseif msg == "ok_btn" then -- 保存
        if self.m_mode and self.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA_DEFENSE then
            self:topRaceArenaSetDefendTeams()
        elseif self.m_mode and self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA_DEFENSE then
            self:fiveRaceArenaSetDefendTeams()
        end
    elseif msg == "cancle_btn" then -- 取消
        self.m_model.m_edit_status = 1
        self.m_model.m_select_cell_index = -1
        self.m_model:initData()
        self.m_view:refreshUI()
    elseif msg == "formation_edit_btn" then
       -- self:openView("Loading.BattleLoading", {callfunc = function(open_flag)
           -- if open_flag == "open_view" then
        if self.m_model.m_mode  then
            local races = nil 
            if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA_DEFENSE then
                races =  self.m_model.m_races[data.index]
            else
                races = GameUtil:getRacesByTopArenaRaceTeamIdx(data.index, self.m_model.m_races)
            end
            self:openView("Formation",{mode = self.m_model.m_mode, formation_index = data.index, races = races, top_arena_races = self.m_model.m_races})
        end
    elseif msg == "refresh_ui" then
        self.m_model:initData()
        self.m_view:refreshUI()
    end
end

-- teams: {1: [hero_oid], 2: [hero_oid], 3: [hero_oid]}
function M:topRaceArenaSetDefendTeams()
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
    self.m_model:getNetData("top_arena_set_teams",{teams = teams}, callfunc,false,nil, GlobalConfig.POST)
end

-- teams: {1: [hero_oid], 2: [hero_oid], 3: [hero_oid]}
function M:fiveRaceArenaSetDefendTeams()
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
    self.m_model:getNetData("season_arena_set_teams",{teams = teams}, callfunc,false,nil, GlobalConfig.POST)
end
return M
