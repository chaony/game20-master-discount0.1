local M = class("HuashanSwordTop3Control",LikeOO.OOControlBase)

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    self.m_view:lockTouch()
    self:setOnceTimer(0.5, function()
        self:checkDefendTeam()
        self.m_view:unlockTouch()
    end)
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
    RedPointUtil:saveLocalRedPointFreshTime("huashan_index_once")
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
        local not_close_tab = {}
        not_close_tab = {["Loading.SyncLoadBigLoading"] = 1, ["Loading.SmallLoading"] = 1, ["Loading.BattleLoading"] = 1, ["Loading.BigLoading"] = 1, ["Main.TotalWorld"] = 1}
        static_rootControl:closeAllViewPop(not_close_tab)
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    elseif msg == "rank_btn" then
        self:openView("HuashanSword.HuashanSwordTop3")
    elseif msg == "attack_btn" then
        self:arenaSelectDefendTeam(data)
    elseif msg == "cell" then
        self:openView("Pops.PlayerInfo", {rank = data.rank, uid = data.user.uid, look_model = 8, vsn = self.m_model.m_version})
    elseif msg == "refresh_btn" then
        self:arenaRefreshChallenges()
    elseif msg == "battle_end_refresh_ui" then
        self:arenaArenaIndex()
    elseif msg == "refresh_ui" then
        self:arenaArenaIndex()
    elseif msg == "update_data" then
        self.m_model:updateData(data.data)
        self.m_view:refreshUI()
    elseif msg == "refresh_btn_time_end" then
        self.m_view:setRefreshBtnEnabled(true)
    elseif msg == "challenge_btn2" then
        local open_status = self.m_model:getActStatus()
        if open_status == 1 then
            local cur_time = TimeUtil.gmTime(UserDataManager:getServerTime())  --服务器时间    
            if self:checkDefendTeam() then
            elseif cur_time.hour >= 0 and cur_time.hour < 1 and self.m_model.m_cur_day > 1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("huashan_sword_text0011"), delay_close = 2})
            else
                if self.m_model:isMaxTime() then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#limit_1"), delay_close = 2})
                    return
                end
                local daily_times =  self.m_model:getCurTimes()
                self:openView("HuashanSword.HuashanSwordChallenge",{vsn = self.m_model.m_version, daily_times = daily_times})
            end
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        end
        
    elseif msg == "record_btn" then
        self:openView("HuashanSword.HuashanSwordLog", {vsn = self.m_model.m_version, free_times = self.m_model.m_data.free_times})
    elseif msg == "explain_btn" then --说明
        self:openView("Pops.CommonHelpPop", { title = "huashan_sword_text0001", content = "tid#HuashanlunjianDes001" })
    elseif msg == "reward_btn" then
        self:openView("HuashanSword.HuashanSwordReward", {data = self.m_model.m_data})
    elseif msg == "season_rank_btn" then
        self:openView("HuashanSword.HuashanSwordSeasonRank")
    elseif msg == "def_btn" then
        self:openView("HuashanSword.HuashanSwordDefendTeam", {vsn = self.m_model.m_version})
    elseif msg == "shop_btn" then
        RedPointUtil:saveLocalRedPointFreshTime("huashan_shop_once")
        self:openView("Shop", {shop_type = 29})
        self.m_view:refreshUI()
    elseif msg == "load_rank" then
        self:requestLoadRank()
    elseif msg == "box_reward_btn" then
        self:highArenaReceiveArenaCoin()
    elseif msg == "refresh_red_point" then
        self.m_view:refreshRedPoint()
    end
end

function M:highArenaReceiveArenaCoin()
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    local params = {}
    self.m_model:getNetData("arena_mountain_hua_receive_arena_coin", params, receivetCallback)
end

function M:requestLoadRank()
    local start_pos, end_pos = self.m_model:getLoadIndex()
    if start_pos > 0 then
        local function netCallback(response)
            if self.m_view then
                self.m_mail_load = true
                self.m_model:insertRankData(response.ranks)
                self.m_view:updateListScroll()
            end
        end
        local params = {}
        params.start = start_pos
        params.stop = end_pos
        self.m_model:getNetData("arena_mountain_hua_select_arena_rank", params, netCallback)
    end
end

function M:checkDefendTeam()
    local set_flag = UserDataManager.hero_data:checkMultTeamNeedSetUp("arena_mountain_hua_defense")
    if set_flag then
        self:openView("HuashanSword.HuashanSwordDefendTeam", {back_refresh = true, show_order_btn_flag = false, vsn = self.m_model.m_version})
    end
    return set_flag
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

--计时器
function M:updateTime()
    self.m_view:updateActivityTimer()
end


function M:destroy()
    self:removeTimer(self.m_timer_id)
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M;
