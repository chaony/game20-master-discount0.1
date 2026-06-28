local M = class("LegendRewardControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif type(msg) == "number" and msg >= 1 and msg <= 3 then
        self:switchTabBtn(msg)
    elseif msg == "daily_quests_goto_btn" then --日常奖励
        self:dailyReceiveQuest(data.cell_data)
    elseif msg == "auto_get_btn" then --日常奖励一键领取
        self:dailyReceiveQuestAll()
    elseif msg == "weekly_quests_goto_btn" then --周常奖励
        self:weeklyReceiveQuest(data.cell_data)
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchTabNode(index)
    end
end

--  领取日常任务奖励 quest_id: 任务id
function M:dailyReceiveQuest(data)
    local function netCallback(response)
        if response.update == 1 then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
            self:updateMsg("refresh_data", response, "Legend")
            self:closeView()
        else
            self.m_view:switchTabNode(self.m_model.m_sel_tab_index)
            RewardUtil:rewardTipsByData(response.reward)
            self:updateMsg("refresh_data", response, "Legend")
        end
    end
    local params = {quest_id = data.id}
    self.m_model:getNetData("legend_recv_daily_reward", params, netCallback)
end

--  领取日常任务奖励-已将领取
function M:dailyReceiveQuestAll()
    local function netCallback(response)
        if response.update == 1 then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
            self:updateMsg("refresh_data", response, "Legend")
            self:closeView()
        else
            self.m_view:switchTabNode(self.m_model.m_sel_tab_index)
            RewardUtil:rewardTipsByData(response.reward)
            self:updateMsg("refresh_data", response, "Legend")
        end
    end
    self.m_model:getNetData("legend_recv_reward_all", nil, netCallback)
end

--  领取周常任务奖励 quest_id: 任务id
function M:weeklyReceiveQuest(data)
    local function netCallback(response)
        if response.update == 1 then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
            self:updateMsg("refresh_data", response, "Legend")
            self:closeView()
        else
            self.m_view:switchTabNode(self.m_model.m_sel_tab_index)
            RewardUtil:rewardTipsByData(response.reward)
            self:updateMsg("refresh_data", response, "Legend")
        end
    end
    local params = {quest_id = data.id}
    self.m_model:getNetData("legend_recv_weekly_reward", params, netCallback)
end

return M
