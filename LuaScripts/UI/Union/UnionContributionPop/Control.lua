local M = class("UnionContributionPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "back_btn" then
    	self:closeView()
    elseif msg == "sub_btn" then
        self.m_model:subTimes()
        self.m_view:refreshUI()
    elseif msg == "add_btn" then
        self.m_model:addTimes()
        self.m_view:refreshUI()
    elseif msg == "ok_btn" then
        self:contributionRequest()
    elseif msg == "cell_btn" then
        self.m_model.m_select_id = data or 1
        self.m_view:refreshUI()
    end
end

function M:contributionRequest()
    if self.m_model.m_max_times - self.m_model.m_guild_donate_times <= 0 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0017"), delay_close = 2})
        return
    end
    local cost = self.m_model:getCost()
    local cost_data = RewardUtil:getProcessRewardData(cost[1])
    --local diamond_num = UserDataManager.user_data:getUserStatusDataByKey("diamond") or 0
    if cost_data.user_num >= cost_data.data_num then
        local function contributionCallback(response)
            self:updateMsg("update_data", {guild = response.guild, players = response.players, contribution_times = response.contribution_times}, "Union.UnionMain")
            self:updateMsg("update_data", {guild = response.guild, players = response.players, contribution_times = response.contribution_times}, "Union.UnionArtifactPop")
            RewardUtil:rewardTipsByData(response.reward)
            self:closeView()
        end
        local params = {}
        --params.times = self.m_model.m_times
        params.index = self.m_model.m_select_id
        self.m_model:getNetData("guild_doing_contribution", params, contributionCallback)
    else
        GameUtil:lookInfoTips(self, {msg = string.format(Language:getTextByKey("union_str_0015"), cost_data.name), delay_close = 2})
        self:closeView()
    end
end

return M;
