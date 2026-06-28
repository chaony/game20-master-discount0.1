local M = class("ArenaFiveRaceControl",LikeOO.OOControlBase)

function M:onEnter()
    --self.m_guide_file_name = "UI.Arena.ArenaRace.ArenaRace.Guide"
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    self:setOnceTimer(0.5, function()
        self:checkDefendTeam()
    end)
    SceneManager:changeScene(SceneManager.SceneID.HangUpScene, {playBGM = false})
end

function M:startGuide()
    --local have_guide = UserDataManager.guide_data:setAnyTeamGuide(44, 3)
    --if have_guide then
    --    if self.m_guide then
    --        self.m_guide:start()
    --    end
    --end
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:updateMsg("refreshRedPoint" ,nil ,"Main.TotalWorld")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 36})
    elseif msg == "record_btn" then
        self:openView("Arena.ArenaRace.ArenaRaceLog", {free_times = self.m_model.m_data.free_times, match_type = self.m_model.m_match_type, races = self.m_model.races})
    elseif msg == "good1" or msg == "top_good1" then
        local user = self.m_model:getTopDataByIndex(1)
        self:goodUser(user);
    elseif msg == "good2" or msg == "top_good2" then
        local user = self.m_model:getTopDataByIndex(2)
        self:goodUser(user);
    elseif msg == "good3" or msg == "top_good3" then
        local user = self.m_model:getTopDataByIndex(3)
        self:goodUser(user);
    elseif msg == "def_btn" then
        self:openView("Arena.ArenaRace.ArenaTopDefendTeam", { mode = GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA_DEFENSE, races = self.m_model.races })
    elseif msg == "rank_btn" then
        self:openView("Arena.ArenaRace.ArenaRaceRank", { open_type = self.m_model.m_match_type})
    elseif msg == "attack_btn" then
        self:arenaSelectDefendTeam(data)
    elseif msg == "arena_cell_btn" then
        self:openView("Pops.PlayerInfo", {uid = data.user.uid, look_model = 1})
        --elseif msg == "cell_btn" then
        --self:openView("Pops.PlayerInfo", {uid = data.user.uid, look_model = 1})
    elseif msg == "refresh_btn" then
        self:arenaRefreshChallenges()
    elseif msg == "battle_end_refresh_ui" then
        --关闭列表
        --self:closeView("Arena.ArenaRace.ArenaRaceChallenge")
        self:arenaArenaIndex()
        if data and data.data and data.data.reward then
            RewardUtil:rewardTipsByData(data.data.reward)
        end
        self:updateMsg("refresh_top_race_rank",{rank = self.m_model.m_data.rank},"Arena.ArenaSelectMain")

    elseif msg == "update_data" then
        self.m_model.m_data.free_times = data.data.free_times;
        local cross_season = self.m_model.m_data.cross_season or 1
        local daily_times =  self.m_model:getCurTimes()
        self:updateMsg("update_data",{ daily_times = daily_times, races = self.m_model:getRaceData(),
                                       remain_time = self.m_model:getFreeTimes(),
                                       self_rank = self.m_model.m_data.rank,
                                       self_score = self.m_model.m_data.score,
                                       match_type = self.m_model.m_match_type,
                                       cross_season = cross_season},"Arena.ArenaRace.ArenaRaceChallenge")
        self.m_view:refreshUI()
    elseif msg == "refresh_ui" then
        self:arenaArenaIndex()
    elseif msg == "shop_btn" then
        self:openView("Shop", {shop_type = 8, pop_from_func_id = -1})
    elseif msg == "reward_btn" then
        local data = self.m_model.m_data
        data.last_settlement_time = self.m_model.m_data.season_etime
        
        self:openView("Arena.ArenaNormal.ArenaNormalReward", {open_type = 2, data = self.m_model.m_data, cfg_name = "season_race_arena_reward", content = "tid#arena_explain8"})
    elseif msg == "challenge_btn" then
        if self.m_model.m_match_type == 2 and self:checkDefendTeam() then
        else
            if self.m_model:isMaxTime() then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#limit_1"), delay_close = 2})
                return
            end
            local daily_times = self.m_model:getCurTimes()
            local cross_season = self.m_model.m_data.cross_season or 1
            --把种族传过去
            self:openView("Arena.ArenaRace.ArenaRaceChallenge", { match_type = self.m_model.m_match_type,
                                                                  daily_times = daily_times,
                                                                  races = self.m_model:getRaceData(),
                                                                  remain_time = self.m_model:getFreeTimes(),
                                                                  self_rank = self.m_model.m_data.rank,
                                                                  self_score = self.m_model.m_data.score,
                                                                  cross_season = cross_season})
        end

    elseif msg == "explain_btn" then --说明
        local cfg_name = "season_race_arena_reward"
        local content = "tid#LianSai_des_6"
        local data = self.m_model.m_data
        data.last_settlement_time = self.m_model.m_data.season_etime --:getRemainingTime()
        self:openView("Arena.ArenaNormal.ArenaNormalReward", {open_type = 2, data = data, cfg_name = cfg_name, content = content})
    elseif msg == "rank_first_node" then
        local list_data = self.m_model:getTopData()
        if #list_data and list_data[1].rank == 1 then
            self:openView("Pops.PlayerInfo", {uid = list_data[1].user.uid, look_model = 1})
        end
    elseif msg == "box_click" then
        local rewards = data.data.cfg.rewards or {}
        self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = data.data.status == -1})
    elseif msg == "box_reward" then
        self:arenaRecvWeekReward(data.data)
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint()
    elseif msg == "open_top_tips_pop" then
        local function ok_call_back()
            self:updateMsg("refresh_ui" ,nil ,"Arena.ArenaSelectMain")
            self:updateMsg(99999)
        end
        self:openView("Arena.ArenaRace.ArenaRaceTopTips",{ok_call_back = ok_call_back, rank = data.rank, title = data.title, title_des = data.title_des, content_des = data.content_des})
    end
end

function M:checkDefendTeam()
    local set_flag = UserDataManager.hero_data:checkMultTeamNeedSetUp("season_race_arena_defense", 3)
    if set_flag then
        self:openView("Arena.ArenaRace.ArenaTopDefendTeam", { mode = GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA_DEFENSE, races = self.m_model.races })
    end
    return set_flag
end

--点赞某个人
function M:goodUser( userData )
    local params = {
        target_uid = userData.user.uid
    }
    --点赞
    self.m_model:getNetData("race_arena_season_like", params, function(data)
        RewardUtil:rewardTipsByData(data.reward, nil, function()
        end, {allDouble = false})
        userData.like = userData.like + 1;
        self.m_view:updateGoodNumTxt(userData.rank, userData.like);
        self.m_view:updateLikeUsers(data.like);
    end)
end

--  领取周奖励 reward_id: 1
function M:arenaRecvWeekReward(data)
    local function netCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    local params = {reward_id = data.id}
    self.m_model:getNetData("race_arena_season_recv_week_reward", params, netCallback)
end

function M:requestReceive(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.quest_id = data.id
    self.m_model:getNetData("quest_recv_recruit_reward", params, receivetCallback)
end

-- 战斗
function M:arenaSelectDefendTeam(data)
    local free_time = self.m_model:getFreeTimes()
    local item_data = UserDataManager.item_data:getItemDataById(1004)
    if free_time > 0 or item_data.num > 0 then
        local function netCallback(response)
            --  self:openView("Loading.BattleLoading", {callfunc = function(open_flag)
            --     if open_flag == "open_view" then
            self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.LOCAL_ARENA, defend_uid = data.user.uid, def_data = response})
            --   end
            -- end })
        end
        local params = {defend_uid = data.user.uid}
        self.m_model:getNetData("race_arena_season_select_defend_team", params, netCallback)
    else
        self:openView("Arena.ArenaRace.ArenaRaceTicketBuy")
    end
end

-- 竞技场刷新敌人
function M:arenaRefreshChallenges()
    local function receivetCallback(response)
        if self.m_view then
            self.m_model:updateData(response)
            local flag = self.m_model:checkTopDataRefresh()
            if flag then
                self:arenaRefreshTop()
                return
            end
            self.m_view:refreshUI()
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0236"), delay_close = 2})
        end
    end
    local params = {}
    self.m_model:getNetData("race_arena_season_refresh_challenges", params, receivetCallback)
end

function M:arenaRefreshTop()
    local function receivetCallback(response)
        if self.m_view then
            self.m_model:updateData(response)
            self.m_view:refreshUI()
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0236"), delay_close = 2})
        end
    end
    local params = {start = 1, stop = 3, match_type = 2}
    if self.m_match_type == 2 then
        self.m_model:getNetData("race_arena_season_select_arena_rank", params, receivetCallback)
    else
        self.m_model:getNetData("race_arena_select_arena_rank", params, receivetCallback)
    end
end

-- 竞技场刷新
function M:arenaArenaIndex()
    local function receivetCallback(response)
        --Logger.logError(response," 竞技场战斗之后刷新 ")
        if self.m_view then
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
        local cross_season = self.m_model.m_data.cross_season or 1
        local daily_times = response.daily_times or self.m_model:getCurTimes()
        self:updateMsg("update_arenarace_data", response.rank, "Arena.ArenaSelectMain")
        self:updateMsg("update_data",{daily_times = daily_times,
                                      races = self.m_model:getRaceData(),
                                      remain_time = self.m_model:getFreeTimes(),
                                      self_rank = self.m_model.m_data.rank,
                                      self_score = self.m_model.m_data.score,
                                      match_type = self.m_model.m_match_type,
                                      cross_season = cross_season},"Arena.ArenaRace.ArenaRaceChallenge")
    end
    local params = {}
    self.m_model:getNetData("race_arena_season_race_arena_index", params, receivetCallback)
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "items_update" or curEvent == "ArenaRaceView_refresh" then
        if self.m_view:isVisible() then
            self.m_view:refreshUI()
        else
            self.m_view.m_dirty = true
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M;
