local M = class("HuashanSwordTop3Control",LikeOO.OOControlBase)

function M:onEnter()
    --self.m_guide_file_name = "UI.Arena.ArenaHigher.ArenaHigher.Guide"
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    self.m_view:lockTouch()
    self:setOnceTimer(0.5, function()
        self:checkDefendTeam()
        self.m_view:unlockTouch()
    end)
    --SceneManager:changeScene(SceneManager.SceneID.HangUpScene, {playBGM = false})
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent") 
        self:updateMsg("refresh_red_point", nil, "HuashanSword.HuashanSwordMain") 
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
      elseif msg == "rank_btn" then
        self:openView("HuashanSword.HuashanSwordRank")
    elseif msg == "cell" then
        self:openView("Pops.PlayerInfo", {rank = data.rank, uid = data.user.uid, look_model = 8, vsn = self.m_model.m_version})
    elseif msg == "refresh_btn" then
        self:arenaRefreshChallenges()
    elseif msg == "battle_end_refresh_ui" then
        self:arenaArenaIndex()
        --self:updateMsg("refresh_ui", nil, "Arena.ArenaSelectMain")
    elseif msg == "refresh_ui" then
        self:arenaArenaIndex()
    elseif msg == "update_data" then
        self.m_model:updateData(data.data)
        self.m_view:refreshUI()
    elseif msg == "refresh_btn_time_end" then
        self.m_view:setRefreshBtnEnabled(true)
    elseif msg == "challenge_btn" then
        self:openView("HuashanSword.HuashanSwordMain")
    elseif msg == "attack_btn" then
        self:arenaSelectDefendTeam(data)
    elseif msg == "explain_btn" then --说明
        self:openView("Pops.CommonHelpPop", { title = "huashan_sword_text0001", content = "tid#HuashanlunjianDes001" })
    elseif msg == "reward_btn" then
        self:openView("HuashanSword.HuashanSwordReward", {data = self.m_model.m_data})
    elseif msg == "season_rank_btn" then
        self:openView("HuashanSword.HuashanSwordSeasonRank")
    elseif msg == "good1" then
        local user = self.m_model:getTopDataByIndex(1)
        self:goodUser(user);
    elseif msg == "good2" then
        local user = self.m_model:getTopDataByIndex(2)
        self:goodUser(user);
    elseif msg == "good3" then
        local user = self.m_model:getTopDataByIndex(3)
        self:goodUser(user);
    elseif msg == "shop_btn" then
        self:openView("Shop", {shop_type = 29})
    elseif msg == "jiantou_left_btn" or msg == "jiantou_right_btn" then
        local is_left = msg == "jiantou_left_btn" and -1 or 1
        local day = self.m_model:getDayByDirection(is_left)
        if self.m_model:isNeedRequest(day) then
            self:requestLoadRank(day)
        elseif day ~= self.m_model.m_cur_day then
            self.m_model:setCurDay(day)
            self.m_view:refreshUI(true)
        end
    elseif msg == "add_btn" then
        self.btn_trans = self.m_view:findGameObject("add_btn")
        local tips_str = self.m_model:getAddDes()
        GameUtil:lookInfoTips(self.m_control, {top = true, click_transform = self.btn_trans.transform, msg = tips_str, text_anchor_value = "MiddleLeft"} )
    elseif msg == "load_rank" then
        self:requestLoadRank()
    end
end

function M:requestLoadRank(day)
    local start_pos, end_pos = self.m_model:getLoadIndex()
    if day then
        start_pos, end_pos = 1, 15
    end
    if start_pos > 0 then
        local function netCallback(response)
            if self.m_view then
                if day then
                    if response and response.ranks and next(response.ranks) then
                        self.m_model:setCurDay(day)
                        self.m_model:insertRankData(response.ranks)
                        self.m_view:refreshUI(true) 
                    else
                        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("huashan_sword_text0013"), delay_close = 2})
                    end
                else
                    self.m_mail_load = true
                    self.m_model:insertRankData(response.ranks)
                    self.m_view:updateListBottomScroll()
                end
            end
        end
        local params = {}
        params.start = start_pos
        params.stop = end_pos
        params.active_day = day or self.m_model.m_cur_day
        self.m_model:getNetData("arena_mountain_hua_select_arena_rank", params, netCallback)
    end
end
-- 战斗
function M:arenaSelectDefendTeam(data)
    local free_time = self.m_model:getFreeTimes()
    local item_data = UserDataManager.item_data:getItemDataById(1005)
    if free_time > 0 or item_data.num > 0 then
        local function netCallback(response)
            -- self:openView("Loading.BattleLoading", {callfunc = function(open_flag)
            -- if open_flag == "open_view" then
            self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.HUASHAN_SWORD, defend_uid = data.user.uid, def_data = response, formation_index = 1})
            -- end
            -- end })
        end
        local params = {defend_uid = data.user.uid}
        self.m_model:getNetData("arena_mountain_hua_select_defend_teams", params, netCallback)
    else
        self:openView("Arena.ArenaNormal.ArenaNormalTicketBuy", {buy_mode = 1, buy_times = self.m_model.m_data.buy_times})
    end
end

--点赞某个人
function M:goodUser( userData )
    local params = { target_uid = userData.user.uid }
    --点赞
    self.m_model:getNetData("arena_mountain_hua_like", params, function(data)
        self.m_model:updateData(data)
        RewardUtil:rewardTipsByData(data.reward, nil, function() end, {allDouble = false})
        userData.like = userData.like + 1;
        self.m_view:updateGoodNumTxt(userData.rank, userData.like);
        self.m_view:updateLikeUsers(data.like);
    end)
end

function M:checkDefendTeam()
    local set_flag = UserDataManager.hero_data:checkMultTeamNeedSetUp("arena_mountain_hua_defense")
    if set_flag then
        self:openView("HuashanSword.HuashanSwordDefendTeam", {back_refresh = true, show_order_btn_flag = false})
    end
    return set_flag
end

function M:highArenaReceiveArenaCoin()
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    local params = {}
    self.m_model:getNetData("high_arena_receive_arena_coin", params, receivetCallback)
end

-- 竞技场刷新敌人
function M:arenaRefreshChallenges()
    local function receivetCallback(response)
        if self.m_view then
            self.m_model:updateData(response)
            self.m_view:refreshUI()
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0236"), delay_close = 2})
        end
    end
    local params = {}
    self.m_model:getNetData("arena_mountain_hua_refresh_challenges", params, receivetCallback)
end

-- 竞技场刷新
function M:arenaArenaIndex()
    local function receivetCallback(response)
        if self.m_view then
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    self.m_model:getNetData("arena_mountain_hua_arena_index", params, receivetCallback)
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "items_update" or curEvent == "red_dot_update" then
        self.m_view:refreshUI()
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M;
