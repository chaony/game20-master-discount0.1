local M = class("UnionWarMainView",LikeOO.OOPopBase)

M.m_uiName = "UnionWar/UnionWarMain"
M.m_size_type = 1
M.m_time_added = 3
M.m_iphoneXAdapter = true

function M:onEnter()
    self:setTextByLanKey("close_title_text", "tid#GuildWar_2")
    self:setObjectVisible("UI_UnionWar_BJ_001", true)
    self:setTextByLanKey("self_union_score_text", "0")
    self:setTextByLanKey("enemy_union_score_text", "0")
    self:setTextByLanKey("attak_team_text_1", "union_str_1072", 1)
    self:setTextByLanKey("attak_team_text_2", "union_str_1072", 2)
    self:setTextByLanKey("attak_team_text_3", "union_str_1072", 3)
    self:setTextByLanKey("attak_team_use_text_1", "UnionWar_str_095")
    self:setTextByLanKey("attak_team_use_text_2", "UnionWar_str_095")
    self:setTextByLanKey("attak_team_use_text_3", "UnionWar_str_095")
    self:setTextByLanKey("round_reward_text", "UnionWar_str_062")
    self:setTextByLanKey("season_reward_text", "UnionWar_str_063")
    self:setTextByLanKey("sz_duizhandi", "new_str_0511")
    self:setTextByLanKey("log_btn_text", "UnionWar_str_006")
    self:initDownTime()
    self:isDisplaySeasonReward()
    self:refreshUI()
    --UserDataManager:removeRedDotByKey("guild_war_sign_up")
    --UserDataManager:removeRedDotByKey("guild_war_team_dispatch")
end

function M:refreshUI()
    --回合数
    local round_text = Language:getTextByKey("UnionWar_str_086",self.m_model.m_data.round,self.m_model.m_data.max_round)
    self:setTextByLanKey("round_name_text", round_text)
    local self_guild_data, self_guild_id = self.m_model:getUnionData(1)
    local server_name = UserDataManager.server_data:getServerData().server_name
    if self_guild_data ~= nil then
        self:setTextByLanKey("self_union_score_text", "UnionWar_str_010", self_guild_data.score)
        self:setTextByLanKey("self_union_name_text", tostring(self_guild_data.name))
        local self_server_name = server_name
        if self_guild_data.server ~= nil then
            self_server_name = UserDataManager.server_data:getServerNameById(self_guild_data.server)
        end
        self:setTextByLanKey("self_server_name", self_server_name)
        if self.m_last_self_score ~= self_guild_data.score then
            self:setObjectVisible("UI_UnionWar_ShuaXin_001", true)
            self.m_last_self_score = self_guild_data.score
        else
            self:setObjectVisible("UI_UnionWar_ShuaXin_001", false)
        end
    else
        self:setTextByLanKey("self_union_name_text", "---")
    end

    local enemy_guild_data, enemy_guild_id = self.m_model:getUnionData(2)
    if enemy_guild_data ~= nil then
        self:setTextByLanKey("enemy_union_score_text", "UnionWar_str_010", enemy_guild_data.score)
        self:setTextByLanKey("enemy_union_name_text", tostring(enemy_guild_data.name))
        local enemy_server_name = server_name
        if enemy_guild_data.server ~= nil then
            enemy_server_name = UserDataManager.server_data:getServerNameById(enemy_guild_data.server)
        end
        self:setTextByLanKey("enemy_server_name", enemy_server_name)
        if self.m_last_enemy_score ~= enemy_guild_data.score then
            self:setObjectVisible("UI_UnionWar_ShuaXin_002", true)
            self.m_last_enemy_score = enemy_guild_data.score
        else
            self:setObjectVisible("UI_UnionWar_ShuaXin_002", false)
        end
    else
        self:setTextByLanKey("enemy_union_name_text", "---")
    end
    
    local leftNum = self.m_model:calculateLeftTeamsNum()
    self:setObjectVisible("tip_node", leftNum > 0)
    self:setTextByLanKey("tip_text", "UnionWar_str_038", leftNum)
    local guild_data = self.m_model:getWinnerGuild()
    if guild_data then
        if self.m_time_update_id then
            self.m_control:removeTimer(self.m_time_update_id)
            self.m_time_update_id = nil
        end
        self:setTextByLanKey("battle_tip_text", "new_str_0875", tostring(guild_data.name))
    end
    self:updateSimulatedBattleStatus()
    self:refreshAttackTeams()
end

function M:initDownTime()
    
    local cur_time = TimeUtil.gmTime(UserDataManager:getServerTime())  --服务器时间    
    --local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(cur_time)
    if cur_time.hour >= 23 then
        self:setTextByLanKey("battle_tip_text", "UnionWar_str_041")
        self:setObjectVisible("UI_UnionWar_BJ_001", true)
        return        
    end
    
    self:setTimeText()

    local function tick(_, dt)
      self:setTimeText()
    end
    self.m_time_update_id = self.m_control:setTimer(1, tick)
end

function M:setTimeText()
    local guild_data = self.m_model:getWinnerGuild()
    if guild_data then
        return
    end
    local server_ts = UserDataManager:getServerTime() + 28800 + self.m_time_added
    local time_left = 23*60*60 - server_ts % 86400
    if time_left < 0 then        
        self:updateMsg("union_war_kick_out_player")
    else
        local str = GameUtil:formatTimeBySecond(time_left,999)
        self:setTextByLanKey("battle_tip_text", "UnionWar_str_042", str)
    end
end

function M:refreshAttackTeams()
    local atk_teams = UserDataManager:getGvgTeamsByKey("atk_teams")
    for i = 1, 3 do
        local hero_data, hero_cfg
        local team_item = atk_teams[tostring(i)]
        local show_hero_id = nil
        if team_item then
            local team = team_item.team or {}
            for k, v in ipairs(team) do
                if v ~= "" then
                    hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
                    if hero_data == nil then
                        hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataByDataAndId(self.m_model.m_data.atk_heros, v)
                    end
                    if hero_data then
                        show_hero_id = v
                        break
                    end
                end
            end
        end
        self:setObjectVisible("attak_team_add_" .. i, show_hero_id == nil)
        self:setObjectVisible("attak_team_head_mask_" .. i, show_hero_id ~= nil)
        if hero_cfg then
            self:setImg(hero_cfg.icon, "hero_head_ui", "attak_team_head_" .. i)
        else
            self:setObjectVisible("attak_team_add_" .. i, true)
            self:setObjectVisible("attak_team_head_mask_" .. i, false)
        end
        local user_flag = self.m_model:teamIsUseById(i)
        self:setObjectVisible("attak_team_use_" .. i, user_flag)
        self:setObjectVisible("attak_team_use_text_" .. i, user_flag)
    end
end

function M:updateSimulatedBattleStatus()
    self:setObjectVisible("simulated_battle_select_img", self.m_model.m_simulated_battle_flag == true)
end

--设置赛季奖励是否显示
function M:isDisplaySeasonReward()
    local is_display = self.m_model:getSeasonRewardIsDisPlay()
    self:setObjectVisible("season_reward_btn",is_display)
end

function M:destroy()
    M.super.destroy(self)
end

return M