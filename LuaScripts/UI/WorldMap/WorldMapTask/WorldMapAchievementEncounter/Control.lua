local M = class("WorldMapAchievementEncounterControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "score_box_reward" then
        if self.m_model.m_select_group_data then
            local status = self.m_model.m_select_group_data.status or 0
            if status == 1 then
                self:bigMapReceiveEgQuest()
            elseif status == 0 then
                local rewards = self.m_model.m_select_group_data.group_cfg.reward or {}
                self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = self.m_view.m_score_box_reward.transform, show_check_mark = status == 2, offset_y = -40})
            end
        end
    elseif msg == "box_reward_btn" then
        local status = data.cell_data.status or 0 -- 0：未完成，1：可领取，2：已领取
        if status == 1 then
            self:bigMapReceiveEQuest(data.cell_data)
        elseif status == 0 then
            local rewards = data.cell_data.cfg.reward or {}
            self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = status == 2})
        end
    end
end

-- 领取奖励(奇遇group获取成就点任务)  quest_id: 1
function M:bigMapReceiveEgQuest()
    if self.m_model.m_select_group_data == nil then
        return
    end
    local function netCallback(response)
        self.m_view:refreshUI(true)
        RewardUtil:rewardTipsByData(response.reward)
    end
    local params = {quest_id = self.m_model.m_select_group_data.group_id}

    self.m_model:getNetData("big_map_receive_eg_quest", params, netCallback)
end

-- 领取奖励(奇遇完成事件次数任务)  quest_id: 10101002
function M:bigMapReceiveEQuest(data)
    local function netCallback(response)
        self.m_view:refreshUI(true)
        RewardUtil:rewardTipsByData(response.reward)
    end
    local params = {quest_id = data.id}
    self.m_model:getNetData("big_map_receive_e_quest", params, netCallback)
end

return M;
