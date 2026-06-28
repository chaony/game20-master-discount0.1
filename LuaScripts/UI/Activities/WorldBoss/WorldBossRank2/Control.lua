local M = class("WorldBossRank2Control",LikeOO.OOControlBase)

function M:onEnter()
    --self.m_timer_id = self:setTimer(1,handler(self,self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "box_click" then --查看奖励
        local reawrd_index = data.data
        local is_look = data.is_look
        local rewards = self.m_model:getBoxReward()
        if rewards[reawrd_index] then
            local itemData = { rewards[reawrd_index] }
            local show_check_mark =  true
            if is_look then
                show_check_mark = false
            end
            self:openView("Pops.LookRewardTips",{rewards = itemData, click_transform = data.click_transform, show_check_mark = show_check_mark})
        end
    elseif msg == "good" then    --点赞
        local function callback(response)
            if response and response.reward then
                RewardUtil:rewardTipsByData(response.reward)
            end
            self.m_model:updateData(response,  data.like_index)
            self:updateMsg("refresh_score", data.like_index, "parent")
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("world_boss_like", { target_uid = data.uid }, callback)
    elseif msg == "box_reward" then --领奖
        local function callback(response)
            if response and response.reward then
                RewardUtil:rewardTipsByData(response.reward)
            end
            self.m_model:updateData(response)
            --self:updateMsg("refresh_score", data.data, "parent")
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("world_boss_recv_reward", { rank = data.data }, callback)
    elseif msg == "auto_btn" then
        local function callback(response)
            if response and response.reward then
                RewardUtil:rewardTipsByData(response.reward)
            end
            self.m_model:updateData(response)
            self.m_model:updateAllLikeData()
            --self:updateMsg("refresh_score", data.data, "parent")
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("world_boss_auto_recv_reward", nil, callback)
    elseif msg == "HeadNode" then
        if data and data.uid then
            self:openView("Pops.PlayerInfo", {uid = data.uid, look_model = 1})
        end
    elseif msg == "statistics_btn" then
        if data and data.battle_id then
            Logger.logWarningAlways(data.battle_id, "data.battle_id ======x==")
            self:openView("Pops.BattleStatistics", {battle_id = data.battle_id, round = 1, mode = GlobalConfig.BATTLE_MODE.WORLD_BOSS})
        end
    end
end

function M:updateTime()
     self.m_view:updateTime()
end

function M:destroy()
    --self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end
return M
