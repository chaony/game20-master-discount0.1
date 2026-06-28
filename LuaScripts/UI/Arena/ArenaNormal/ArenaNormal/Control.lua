local M = class("ArenaNormalControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Arena.ArenaNormal.ArenaNormal.Guide"
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    self:setOnceTimer(0.5, function()
        self:openEditName()
    end)
    SceneManager:changeScene(SceneManager.SceneID.HangUpScene, {playBGM = false})
end

function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(38, 3)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent") 
        self:updateMsg("refreshRedPoint" ,nil ,"Main.Outskirts")
        self:updateMsg("refreshRedPoint" ,nil ,"Arena.ArenaSelectMain")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 24})
    elseif msg == "record_btn" then
        self:openView("Arena.ArenaNormal.ArenaNormalLog", {free_times = self.m_model.m_data.free_times})     
    elseif msg == "def_btn" then
      --  self:openView("Loading.BattleLoading", {callfunc = function(open_flag)
     --       if open_flag == "open_view" then
                self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.LOCAL_ARENA_DEFENSE})
        --    end
       -- end })
    elseif msg == "rank_btn" then
        self:openView("Arena.ArenaNormal.ArenaNormalRank")     
    elseif msg == "attack_btn" then
        self:arenaSelectDefendTeam(data)
    elseif msg == "arena_cell_btn" then
        self:openView("Pops.PlayerInfo", {uid = data.user.uid, look_model = 1})
    --elseif msg == "cell_btn" then
        --self:openView("Pops.PlayerInfo", {uid = data.user.uid, look_model = 1})
    elseif msg == "refresh_btn" then
        self:arenaRefreshChallenges()
    elseif msg == "battle_end_refresh_ui" then
        self:arenaArenaIndex()
        if data and data.data and data.data.reward then
            RewardUtil:rewardTipsByData(data.data.reward)
        end
    elseif msg == "refresh_ui" then
        self:arenaArenaIndex()
    elseif msg == "reward_btn" then
        self:openView("Arena.ArenaNormal.ArenaNormalReward", {data = self.m_model.m_data, cfg_name = "arena_reward", content = "tid#arena_explain2"})
    elseif msg == "challenge_btn" then
        if self.m_model:isMaxTime() then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#limit_1"), delay_close = 2})
            return
        end
        local daily_times =  self.m_model:getCurTimes()
        self:openView("Arena.ArenaNormal.ArenaNormalChallenge", {combat = self.m_model.m_data.combat, daily_times = daily_times})
    elseif msg == "explain_btn" then --说明
        self:openView("Arena.ArenaNormal.ArenaNormalReward", {data = self.m_model.m_data, cfg_name = "arena_reward", content = "tid#arena_explain2"})
        --self:openView("Pops.CommonHelpPop", { title = "tid#arena_explain1", content = "tid#arena_explain2" })
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
    elseif msg == "shop_btn" then
        self:openView("Shop", {shop_type = 8, pop_from_func_id = -1})
    elseif msg == "good1" then
        local user = self.m_model:getTopDataByIndex(1)
        self:goodUser(user);
    elseif msg == "good2" then
        local user = self.m_model:getTopDataByIndex(2)
        self:goodUser(user);
    elseif msg == "good3" then
        local user = self.m_model:getTopDataByIndex(3)
        self:goodUser(user);
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint()    
    end
end

--点赞某个人
function M:goodUser( userData )
    local params = { target_uid = userData.user.uid }
    --点赞
    self.m_model:getNetData("arena_like", params, function(data)
        RewardUtil:rewardTipsByData(data.reward, nil, function() end, {allDouble = false})
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
    self.m_model:getNetData("arena_recv_week_reward", params, netCallback)
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
        self.m_model:getNetData("arena_select_defend_team", params, netCallback)
    else
        self:openView("Arena.ArenaNormal.ArenaNormalTicketBuy")
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
    self.m_model:getNetData("arena_refresh_challenges", params, receivetCallback)
end

function M:arenaRefreshTop()
    local function receivetCallback(response)
        if self.m_view then
            self.m_model:updateData(response)
            self.m_view:refreshUI()
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0236"), delay_close = 2})
        end
    end
    local params = {}
    self.m_model:getNetData("arena_select_top_arena_rank", params, receivetCallback)
end

-- 竞技场刷新
function M:arenaArenaIndex()
    local function receivetCallback(response)
        if self.m_view then
            self:updateMsg("update_arena_data", response.rank, "Arena.ArenaSelectMain")
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    self.m_model:getNetData("arena_arena_index", params, receivetCallback)
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "items_update" or curEvent == "ArenaNormalView_refresh" then
        if self.m_view:isVisible() then
            self.m_view:refreshUI()
        else
            self.m_view.m_dirty = true
        end
    end
end

function M:openEditName()
    if UserDataManager:getIsFirstName() ~= 0 then
        return
    end
    local cost = ConfigManager:getSystemCostValueById(2)
	local name = UserDataManager.user_data:getUserStatusDataByKey("name")
    local params =
    {
        on_ok_call = function(msg)
            self:requestSetName(msg)
        end,
        cost = cost[1] or {RewardUtil.REWARD_TYPE_KEYS.DIAMOND,0,999999},
        tips = Language:getTextByKey("options_str_0003"),
        title = Language:getTextByKey("options_str_0004"),
        placeholder = Language:getTextByKey("options_str_0003"),
        text = name,
        no_close_btn = true,
        is_free = UserDataManager:getIsFirstName() == 0,
        popType = 1,
    }
    self:openView("Pops.CommonInputPop", params)
end

function M:requestSetName(msg)
    local function nameCallback(response, tag, status_code)
        if response then
            self:closeView("Pops.CommonInputPop")
            UserDataManager:setIsFirstName(response.is_first_name)
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("options_str_0007"), delay_close = 2})
            if self.m_view then
                self.m_view:refreshUI()
                self:updateMsg("refresh_ui")
            end
        else
            if status_code == GlobalConfig.SENSITIVE_WORDS_CODE then
                self:updateMsg("reset_input_text", nil, "Pops.CommonInputPop")
            end
        end
    end
    local params = {}
    params.name = msg
    self.m_model:getNetData("user_set_name", params, nameCallback, nil, true)
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M;
