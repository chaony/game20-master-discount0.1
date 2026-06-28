local M = class("GuildHighWarRankListControl",LikeOO.OOControlBase)

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
        if self.m_model.m_sel_tab_index == 1 then return end
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
    elseif msg == "load_rank" then
        self:requestLoadRank()
        -------------------
    elseif msg == "hint_btn" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("guild_high_war_new_0050"), delay_close = 2})
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        if self.m_model.m_total_rank_data[self.m_model.m_sel_tab_index] == nil and (index == 1 or index==3) then
            self:requestRankData(index)
        else
            if (index ==2 or index ==4) and self.m_model.is_fist_quest  then
                local function netCallback(response)
                    if response and self.m_model then
                        if self.m_model.big_stage == 4 then 
                            self.m_model.big_stage = response.big_stage
                            self.m_model.playoff_type = response.playoff_type
                        end
                        self.m_model:UpdateRewardData(response)
                        self.m_model.is_fist_quest = false
                        self.m_view:switchNode(index)
                        return
                    end
                end
                self.m_model:getNetData("guild_high_war_daily_gift_index",nil,netCallback)
            else
                self.m_view:switchNode(index)
            end
        end
    end
end

-- 排行榜入口 sort: 排行榜类型 start: 开始的排名 stop: 结束的排名daily_gift_index
function M:requestRankData(sort, start_pos, end_pos)
    local sort = sort == 1 and 1 or 2
    local function netCallback(response)
        if response and self.m_model then
            self.m_model:initData(response)
            self.m_view:switchNode(self.m_model.m_sel_tab_index)
        end
    end
    start_pos = start_pos or 1
    end_pos = end_pos or 10
    local params = { sort = sort, start = start_pos, stop = end_pos}
    self.m_model:getNetData("guild_high_war_rank_info", params, netCallback, nil, nil, nil)
end

function M:requestLoadRank()
    local start_pos, end_pos = self.m_model:getLoadIndex()
    if start_pos > 0 then
        local function netCallback(response)
            if self.m_view then
                self.m_mail_load = true
                self.m_model:insertRankData(response.ranks)
                self.m_view:switchNode(self.m_model.m_sel_tab_index)
            end
        end
        local params = {}
        params.start = start_pos
        params.stop = end_pos
        params.sort = self.m_model.m_sel_tab_index == 1 and 1 or 2
        self.m_model:getNetData("guild_high_war_rank_info", params, netCallback)
    end
end
return M
