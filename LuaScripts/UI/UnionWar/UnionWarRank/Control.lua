local M = class("UnionWarRankControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:updateMsg("refresh_red_point", {red_point = self.m_model.m_red_point, id = self.m_model.m_id}, "Rank.RankMain")
        self:closeView()
    elseif msg == "reward_btn" then
        self:openView("Rank.RankReward",{id = self.m_model.m_id, rank_cfg = self.m_model.m_rank_cfg})
    elseif msg == "score_look" then
        GameUtil:lookInfoTips(self, data)
    elseif msg == "explain_btn" then
        self:openView("Pops.CommonHelpPop", { title = "tid#ranking1", content = "tid#ranking2" })
    elseif msg == "refresh_red_point" then
        self.m_model:updateRedPoint(data)
        self.m_view:refreshRedPoint()
    elseif msg == "check_tag" then
        self:switchTabBtn(data)
    elseif msg == "receive_awards" then
        local cell_data = self.m_model:getQuestsDataByIndex(data.index)
        self:rankQuestRecv(cell_data)
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
        local function netCallback(response)
            self.m_model.m_data = response
            self.m_view:switchNode(index)
        end
        self.m_model:getNetData("gvg_rank", {last_season = 1, start = 1, stop = 50}, netCallback)
    else
        local function netCallback(response)
            self.m_model.m_data = response
            self.m_view:switchNode(index)
        end
        self.m_model:getNetData("gvg_rank", {last_season = 0, start = 1, stop = 50}, netCallback)
    end
end

function M:netCallback(response)
    if self.m_view then
        self:updateMsg("refresh_red_point", {red_point = self.m_model.m_red_point, id = self.m_model.m_id})
        self.m_view:refreshUI()
        RewardUtil:rewardTipsByData(response.reward)
    end
end

return M