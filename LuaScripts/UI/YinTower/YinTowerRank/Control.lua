local M = class("YinTowerRankControl",LikeOO.OOControlBase)

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
    -- elseif msg == "sliding_right" then
    --     self.m_model:changeIndex(1)
    --     self:rankEnter2()
    -- elseif msg == "sliding_left" then
    --     self.m_model:changeIndex(-1)
    --     self:rankEnter2()
    elseif msg == "check_tag" then
        self:switchTabBtn(data)
    elseif msg == "look_top_player" then
        local data = self.m_model:getQuestsDataByIndex(data.index)
        local user = data.data.user or {}
        if _G.next(user) then
            self:openView("Rank.TopPlayerList", {id = self.m_model.m_id, quest_id = data.id})
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0081"), delay_close = 2})
        end
    elseif msg == "receive_awards" then
        local cell_data = self.m_model:getQuestsDataByIndex(data.index)
        self:rankQuestRecv(cell_data)
    elseif msg == "look_player" then
        local cell_data = self.m_model:getQuestsDataByIndex(data.index)
        self:openView("Pops.PlayerInfo", {uid = cell_data.data.user.uid})
    elseif msg == "handle_point_btn" then
        if self.m_model.m_cur_select_id == data.uid then
            self.m_model.m_cur_select_id = nil
        else
            self.m_model.m_cur_select_id = data.uid
            self.m_model.m_click_self = false
        end
        self.m_view:refreshUI()
        self.m_view:refreshOwnPrebPosition()
        if data and data.index then
            self.m_view.m_loop_scroll_view:moveToCellIndex(data.index)
        end
    elseif msg == "click_self_info" then
        self.m_model.m_click_self = not(self.m_model.m_click_self)
        self.m_model.m_cur_select_id = nil
        self.m_view:refreshUI()
        self.m_view:refreshOwnPrebPosition()
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self:rankEnter(index)
    end
end

function M:rankEnter(index)
    if index == 2 then
        self.m_view:switchNode(index) 
    else
        self.m_view:switchNode(index)
    end
end

-- 排行榜入口 sort: 排行榜类型 start: 开始的排名 stop: 结束的排名
function M:rankEnter2()
    local sort = self.m_model.m_id
    local function netCallback(response)
        if response and self.m_model then
            self.m_model:initData(response)
            self.m_view:refreshUI()
        end
    end
    local params = { sort = sort, start = 1, stop = 50 }
    self.m_model:getNetData("rank_enter", params, netCallback, nil, nil, nil)
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
