---@class ArenaNormalChallengeControl:OOControlBase
local M = class("ArenaNormalChallengeControl",LikeOO.OOControlBase)

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
        local quick_pass = data.quick_pass or 0 --快速通过 1. 可以 0. 不可以
        if quick_pass == 0 then
            self:arenaSelectDefendTeam(data)
        else
            self:arenaQuickPassArena(data)
        end
    elseif msg == "arena_cell_btn" then
        self:openView("Pops.PlayerInfo", {uid = data.user.uid, look_model = 1})
    elseif msg == "refresh_btn" then
        self:arenaRefreshChallenges(true)
    elseif msg == "battle_end_refresh_ui" then
        self:arenaRefreshChallenges()
    elseif msg == "refresh_ui" then
        self:arenaRefreshChallenges()
    elseif msg == "reward_btn" then
        self:openView("Arena.ArenaNormal.ArenaNormalReward", {data = self.m_model.m_data})
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
    if data then
        local free_time = self.m_model:getFreeTimes()
        local item_data = UserDataManager.item_data:getItemDataById(1004)
        if free_time > 0 or item_data.num > 0 then
            local function netCallback(response)
               -- self:openView("Loading.BattleLoading", {callfunc = function(open_flag)
                --    if open_flag == "open_view" then
                        self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.LOCAL_ARENA, defend_uid = data.user.uid, def_data = response})
               --     end
               -- end })
            end
            local params = {defend_uid = data.user.uid}
            self.m_model:getNetData("arena_select_defend_team", params, netCallback)
        else
            self:openView("Arena.ArenaNormal.ArenaNormalTicketBuy")
        end
    end
end

-- 战斗
function M:arenaQuickPassArena(data)
    if data then
        local free_time = self.m_model:getFreeTimes()
        local item_data = UserDataManager.item_data:getItemDataById(1004)
        if free_time > 0 or item_data.num > 0 then
            local function netCallback(response)
                if response.need_battle == 1 then -- 需要战斗
                    self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.LOCAL_ARENA, defend_uid = data.user.uid, def_data = response})
                else -- 直接胜利
                    self:openView("Settlement", { result = 1, mode = GlobalConfig.BATTLE_MODE.LOCAL_ARENA, battle_data = response, quick_pass = true, full_mask_flag = true})
                end
            end
            local params = {defend_uid = data.user.uid}
            self.m_model:getNetData("arena_quick_pass_arena", params, netCallback)
        else
            self:openView("Arena.ArenaNormal.ArenaNormalTicketBuy")
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
    self.m_model:getNetData("arena_refresh_challenges", params, receivetCallback)
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
