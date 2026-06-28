local M = class("MythArenaMainControl",LikeOO.OOControlBase)

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    self.m_view:lockTouch()
    self:setOnceTimer(0.5, function()
        self:checkDefendTeam()
        self.m_view:unlockTouch()
    end)
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
        local not_close_tab = {}
        not_close_tab = {["Loading.SyncLoadBigLoading"] = 1, ["Loading.SmallLoading"] = 1, ["Loading.BattleLoading"] = 1, ["Loading.BigLoading"] = 1, ["Main.TotalWorld"] = 1}
        static_rootControl:closeAllViewPop(not_close_tab)
    elseif msg == "stage_end" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("wlsh_text_0006"), delay_close = 2})
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    elseif msg == "rank_btn" then
        --self:openView("Shop", {shop_type = 32})
        self:openView("MythArena.MythArenaRankPop")
    elseif msg == "record_btn" then
        self:openView("MythArena.MythArenaLogPop", {vsn = self.m_model.m_version, free_times = self.m_model.m_data.free_times})
    elseif msg == "def_btn" then
        self:openView("MythArena.MythArenaDefendTeamPop", {vsn = self.m_model.m_version})
    elseif msg == "shop_btn" then
        --RedPointUtil:saveLocalRedPointFreshTime("huashan_shop_once")
        self:openView("Shop", {shop_type = 32, show_one = true})
    elseif msg == "battle_btn" then
        local quick_pass = data.quick_pass or 0 --快速通过 1. 可以 0. 不可以
        if quick_pass == 0 then
            self:arenaSelectDefendTeam(data)
        else
            self:arenaQuickPassArena(data)
        end
    elseif msg == "cell" then
        self:openView("Pops.PlayerInfo", {rank = data.rank, uid = data.user.uid, look_model = 10, vsn = self.m_model.m_version})
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
    elseif msg == "help_btn" then --说明
        local params = {}
        params.title = "wlsh_text_0004"
        params.content = "tid#myth_haixuan_tips"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "refresh_red_point" then
        self.m_view:refreshRedPoint()
    elseif msg == "refresh_btn" then
        self:arenaArenaIndex()
    end
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
        self.m_model:getNetData("myth_arena_select_arena_rank", params, netCallback)
    end
end

function M:checkDefendTeam()
    local set_flag = UserDataManager.hero_data:checkMultTeamNeedSetUp("myth_arena_defense")
    if set_flag then
        self:openView("MythArena.MythArenaDefendTeamPop", {back_refresh = true, show_order_btn_flag = false, vsn = self.m_model.m_version})
    end
    return set_flag
end

-- 战斗
function M:arenaSelectDefendTeam(data)
    local function netCallback(response)
        self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.MYTH_ARENA, defend_uid = data.user.uid, def_data = response, formation_index = 1})
    end
    local params = {defend_uid = data.user.uid}
    self.m_model:getNetData("myth_arena_select_defend_teams", params, netCallback)
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
    self.m_model:getNetData("myth_arena_refresh_challenges", params, receivetCallback)
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
    self.m_model:getNetData("myth_arena_enter", params, receivetCallback)
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "items_update" or curEvent == "red_dot_update" then
        self.m_view:refreshUI()
    end
end

-- 快速战斗
function M:arenaQuickPassArena(data)
    if data then
        local function netCallback(response)
            if response.update then -- 需要重新匹配
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0895"), delay_close = 2})
                self:updateMsg("refresh_ui")
            else
                if response.need_battle == 1 then -- 需要战斗
                    self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.MYTH_ARENA, defend_uid = data.user.uid, def_data = response, formation_index = 1})
                else -- 直接胜利
                    self:openView("Settlement", { result = 1, mode = GlobalConfig.BATTLE_MODE.MYTH_ARENA, battle_data = {}, quick_pass = true, data = response, full_mask_flag = true})
                end
            end
        end
        local params = {defend_uid = data.user.uid}
        self.m_model:getNetData("myth_arena_quick_pass_arena", params, netCallback)
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
