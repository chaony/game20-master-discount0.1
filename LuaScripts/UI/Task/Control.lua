---@class TaskControl:OOControlBase
local M = class("TaskControl",LikeOO.OOControlBase)

function M:onEnter()
    self:switchTabBtn(self.m_model.m_open_tab_index)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent") 
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    -- 1日常、2周常、3主线
    elseif type(msg) == "number" and msg >= 1 and msg <= 3 then
        self:switchTabBtn(msg)
    elseif msg == "box_click" then
        local rewards = data.data.rewards or {}
        self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = data.data.status == -1})
    elseif msg == "daliy_reward" then
        self:questRecvDailyReward(data)
    elseif msg == "main_reward" then
        self:questRecvMainReward(data)
    elseif msg == "weekly_reward" then
        self:questRecvWeeklyReward(data)
    elseif msg == "daily_box_reward" then
        self:questRecvDailyScoreReward(data.data)
    elseif msg == "weekly_box_reward" then
        self:questRecvWeeklyScoreReward(data.data)
    elseif msg == "goto_btn" then
        self:updateMsg("common_refresh", nil, "parent") 
        static_rootControl:closeAllViewPop()
        local go_type = data.cfg.go_type or {}
        QuickOpenFuncUtil:openFunc(go_type)
    elseif msg == "score_btn" then
        GameUtil:lookInfoTips(self, data)
    elseif msg == "refresh" then
        self:questIndex()
    elseif msg == "more_btn" then
        self.m_model:changeMainQuestsMoreStatus(data.id)
        self.m_view:refreshCommonNode()
    elseif msg == "war_order_btn" then -- 战令
        QuickOpenFuncUtil:openFunc(10009)
    elseif msg == "quest_auto_recv_btn" then
        if self.m_model.m_sel_tab_index == 1 then
            self:questAutoRecvDailyReward()
        elseif self.m_model.m_sel_tab_index == 2 then
            self:questAutoRecvWeeklyReward()
        elseif self.m_model.m_sel_tab_index == 3 then
            self:questAutoRecvMainReward()
        end
    elseif msg == "update_task_token" then -- 战令
        self.m_view:refreshTokenData(true)
    elseif msg == "season_achievement_btn" then --赛季成就
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(240)
        if open_flag then
            self:openView("Achievement")
        else
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(tips_str), delay_close = 2})
        end
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_view:switchTabNode(index)
        self.m_model.m_sel_tab_index = index
    end
end

-- 领取主线奖励 quest_id: 任务id
function M:questRecvMainReward(data)
    local function netCallback(response)
        if self.m_view then
            self.m_model:initData(response)
            self.m_view:runAnim(response)
        end
    end
    local params = {quest_id = data.id}
    self.m_model:getNetData("quest_recv_main_reward", params, netCallback)
end

-- 领取日常奖励 quest_id: 任务id
function M:questRecvDailyReward(data)
    local function netCallback(response)
        if self.m_view then
            self.m_model:initData(response)
            self.m_view:runAnim(response)
        end
    end
    local params = {quest_id = data.id}
    self.m_model:getNetData("quest_recv_daily_reward", params, netCallback)
end

-- 领取日常积分奖励 score_id: 积分表id
function M:questRecvDailyScoreReward(data)
    local params = {score_id = data.id}
    self.m_model:getNetData("quest_recv_daily_score_reward", params, handler(self, self.netCallback))
end

-- 领取周常奖励 quest_id: 任务id    
function M:questRecvWeeklyReward(data)
    local function netCallback(response)
        if self.m_view then
            self.m_model:initData(response)
            self.m_view:runAnim(response)
        end
    end
    local params = {quest_id = data.id}
    self.m_model:getNetData("quest_recv_weekly_reward", params, netCallback)
end

-- 领取周常积分奖励 score_id: 积分表id
function M:questRecvWeeklyScoreReward(data)
    local params = {score_id = data.id}
    self.m_model:getNetData("quest_recv_weekly_score_reward", params, handler(self, self.netCallback))
end

function M:netCallback(response)
    if self.m_view then
        self.m_model:initData(response)
        self.m_view:refreshCommonNode()
        RewardUtil:rewardTipsByData(response.reward)
    end
end

function M:questIndex()
    self.m_model:getNetData("quest_index", {}, handler(self, self.netCallback))
end

-- 一键领取日常奖励
function M:questAutoRecvDailyReward()
    self.m_model:getNetData("quest_auto_recv_daily_reward", {}, handler(self, self.netCallbackRewardFly))
end

-- 一键领取周常奖励
function M:questAutoRecvWeeklyReward()
    self.m_model:getNetData("quest_auto_recv_weekly_reward", {}, handler(self, self.netCallbackRewardFly))
end
-- 一键领取主线奖励
function M:questAutoRecvMainReward()
    self.m_model:getNetData("quest_auto_recv_main_reward", {}, handler(self, self.netCallbackRewardFly))
end

function M:netCallbackRewardFly(response)
    self.m_model:initData(response)
    self.m_view:runAnimRewardFly(response)
end

return M
