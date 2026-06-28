local M = class("RankRewardControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_red_point", {red_point = self.m_model.m_red_point, id = self.m_model.m_id}, "Rank.RankList") 
        self:updateMsg("refresh_red_point", {red_point = self.m_model.m_red_point, id = self.m_model.m_id}, "Rank.RankMain") 
        self:closeView()
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
    end
end

-- 领取排行榜任务奖励 sort: 排行榜类型 quest_id: 任务id
function M:rankQuestRecv(data)
    local params = {sort = self.m_model.m_id, quest_id = data.id}
    self.m_model:getNetData("rank_rank_quest_recv", params, handler(self, self.netCallback))
end

function M:netCallback(response)
    if self.m_view then
        self.m_view:refreshUI()
        RewardUtil:rewardTipsByData(response.reward)
    end
end

return M
