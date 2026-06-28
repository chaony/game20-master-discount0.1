local M = class("GuildHighWarRewardPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:updateMsg("refresh_red_point", {red_point = self.m_model.m_red_point, id = self.m_model.m_id}, "Rank.RankMain")
        self:closeView()
    elseif msg == "reward_btn" then
        self:openView("Rank.RankReward",{id = self.m_model.m_id, rank_cfg = self.m_model.m_rank_cfg})
    elseif msg == "item_click" then
        local item_data = self.m_model:getRankDataByIndex(data.id)
        self:openView("Pops.PlayerInfo", {uid = item_data.user.uid})
    elseif msg == "score_look" then
        GameUtil:lookInfoTips(self, data)
    elseif msg == "explain_btn" then
        self:openView("Pops.CommonHelpPop", { title = "tid#ranking1", content = "tid#ranking2" })
    elseif msg == "refresh_red_point" then
        self.m_model:updateRedPoint(data)
        self.m_view:refreshRedPoint()
    elseif msg == "check_tag" then
        self:switchTabBtn(data)
    elseif msg == "select_daily_index" then
        if data and data.index and data.index ~= self.m_model.m_cur_daily_index then
            self.m_model.m_cur_daily_index = data.index
            self.m_view:updateLoopDailyScroll()
            self.m_view:refreshDailyNode()
        end
    else
        local temp = string.split(msg,'reward_btn')
        if temp[1] == "" and temp[2] then
            local gift_id = temp[2]
            gift_id = self.m_model:getRewardId(gift_id)
            self:getGift(gift_id)
        end
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        local have_reward = next(self.m_model.m_daily_gift_num) and true or false
        if not have_reward and index == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("guild_high_war_text_0070"), delay_close = 2})
        else
            self.m_model.m_sel_tab_index = index
            self:rankEnter(index)
        end
       
    end
end

function M:rankEnter(index)
    self.m_view:switchNode(index)
end

-- 排行榜入口 sort: 排行榜类型 start: 开始的排名 stop: 结束的排名
function M:getGift(gift_id)
    local function netCallback(response)
        if response and self.m_model then
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
    end
    local params = { gift_id = gift_id }
    self.m_model:getNetData("guild_high_war_daily_gift_recv", params, netCallback, nil, nil, nil)
end

-- 领取排行榜任务奖励 sort: 排行榜类型 quest_id: 任务id
function M:rankQuestRecv(data)
    local params = {sort = self.m_model.m_id, quest_id = data.id}
    self.m_model:getNetData("rank_rank_quest_recv", params, handler(self, self.netCallback))
end

function M:netCallback(response)
    if self.m_view then
        self:updateMsg("refresh_red_point", {red_point = self.m_model.m_red_point, id = self.m_model.m_id})
        self.m_view:refreshUI()
        RewardUtil:rewardTipsByData(response.reward)
    end
end

return M
