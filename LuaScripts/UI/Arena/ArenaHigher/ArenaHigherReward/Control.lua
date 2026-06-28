local M = class("ArenaHigherRewardControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif type(msg) == "number" and msg >= 1 and msg <= 3 then
        self:switchTabBtn(msg)
    elseif msg == "daily_quests_goto_btn" then
        self:highArenaReceiveQuest(data.cell_data)
    elseif msg == "dw_goto_btn" then
        self:questRecvSpecial(data.cell_data)
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
function M:highArenaReceiveQuest(data)
    local function netCallback(response)
        self.m_view:switchTabNode(self.m_model.m_sel_tab_index)
        RewardUtil:rewardTipsByData(response.reward)
    end
    local params = {quest_id = data.id, season = self.m_model.m_data.season}
    self.m_model:getNetData("high_arena_receive_quest", params, netCallback)
end

--  特殊任务领奖  quest_type: 任务类型  quest_id: 任务id
function M:questRecvSpecial(data)
    local function netCallback(response)
        self.m_view:switchTabNode(self.m_model.m_sel_tab_index)
        RewardUtil:rewardTipsByData(response.reward)
    end
    local params = {quest_id = data.id, quest_type = data.cfg.target_type}
    self.m_model:getNetData("quest_recv_special", params, netCallback)
end

return M
