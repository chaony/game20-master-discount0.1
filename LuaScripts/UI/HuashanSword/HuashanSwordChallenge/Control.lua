local M = class("HuashanSwordChallengeControl",LikeOO.OOControlBase)

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "attack_btn" then
        if self.m_model:isMaxTime() then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#limit_1"), delay_close = 2})
            return
        end
        self.m_model:checkTeam()
        local quick_pass = data.quick_pass or 0 --快速通过 1. 可以 0. 不可以
        if quick_pass == 0 then
            self:arenaSelectDefendTeam(data)
        else
            self:arenaQuickPassArena(data)
        end
    elseif msg == "arena_cell_btn" then
        self:openView("Pops.PlayerInfo", {rank = data.rank, uid = data.user.uid, look_model = 8, vsn = self.m_model.m_version})
    elseif msg == "refresh_btn" then
        self:arenaRefreshChallenges(true)
    elseif msg == "battle_end_refresh_ui" then
        self:arenaRefreshChallenges()
    elseif msg == "refresh_ui" then
        self:arenaRefreshChallenges()
    elseif msg == "reward_btn" then
        self:openView("Arena.ArenaNormal.ArenaNormalReward", {data = self.m_model.m_data})
    elseif msg == "refresh_btn_time_end" then
        self.m_view:setRefreshBtnEnabled(true)
    elseif msg == "skip_select" then
        self.m_model:switchSkipFormation()
        self.m_view:refreshSkipFormationBtn()
    end
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
    local auto_battle_flag = false
    local is_full = UserDataManager.hero_data:checkMultTeamIsFull("arena_mountain_hua")
    if self.m_model.m_high_arena_skip_formation == 1 and is_full then -- 跳过布阵流程
        auto_battle_flag = true
    end
    local free_time = self.m_model:getFreeTimes()
    local item_data = UserDataManager.item_data:getItemDataById(1005)
    if free_time > 0 or item_data.num > 0 then
        local function netCallback(response)
            --self:openView("Loading.BattleLoading", {callfunc = function(open_flag)
               -- if open_flag == "open_view" then
            local races = self.m_model:getCurVsnRaces()
            self:openView("Formation",{races = races, mode = GlobalConfig.BATTLE_MODE.HUASHAN_SWORD, defend_uid = data.user.uid, def_data = response, formation_index = 1, auto_battle_flag = auto_battle_flag})
               -- end
           -- end })
        end
        local params = {defend_uid = data.user.uid}
        self.m_model:getNetData("arena_mountain_hua_select_defend_teams", params, netCallback)
    else
        self:openView("Arena.ArenaNormal.ArenaNormalTicketBuy", {buy_mode = 1, buy_times = self.m_model.m_data.buy_times})
    end
end

-- 快速战斗
function M:arenaQuickPassArena(data)
    if data then
        local free_time = self.m_model:getFreeTimes()
        local item_data = UserDataManager.item_data:getItemDataById(1005)
        if free_time > 0 or item_data.num > 0 then
            local function netCallback(response)
                if response.update then -- 需要重新匹配
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0895"), delay_close = 2})
                    self:updateMsg("refresh_ui")
                else
                    if response.need_battle == 1 then -- 需要战斗
                        self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.HUASHAN_SWORD, defend_uid = data.user.uid, def_data = response, formation_index = 1})
                    else -- 直接胜利
                        self:openView("Settlement", {version = self.m_model.m_version, result = 1, mode = GlobalConfig.BATTLE_MODE.HUASHAN_SWORD, battle_data = {}, quick_pass = true, data = response, full_mask_flag = true})
                    end
                end
            end
            local params = {defend_uid = data.user.uid}
            self.m_model:getNetData("arena_mountain_hua_quick_pass_arena", params, netCallback)
        else
            self:openView("Arena.ArenaNormal.ArenaNormalTicketBuy", {buy_mode = 1, buy_times = self.m_model.m_data.buy_times})
        end
    end
end

-- 竞技场刷新敌人
function M:arenaRefreshChallenges(tips)
    local function receivetCallback(response)
        if self.m_view then
            self.m_model:updateData(response)
            self.m_view:refreshUI()
            if tips then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0236"), delay_close = 2})
            end
        end
    end
    local params = {}
    self.m_model:getNetData("arena_mountain_hua_refresh_challenges", params, receivetCallback)
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "items_update" then
        self.m_view:refreshUI()
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M;
