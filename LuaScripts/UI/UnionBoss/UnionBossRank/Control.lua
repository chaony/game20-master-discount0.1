local M = class("UnionBossRankControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "change_btn" then
    	self.m_model:setYesterDay()
    	self:requestRankdata()
    elseif msg == "fresh_btn" then
    	if self.m_model.m_day == 0 then
    		self.m_model:resetRank()
    		self:requestRankdata()
    	end
    elseif msg == "reward_btn" then
    	if self.m_model.m_today_rank.self_rank.rank > 0 then
	    	local params = {}
	    	params.rank = self.m_model.m_today_rank.self_rank.rank
	        params.dan_data = self.m_model:getDanData(params.rank)
	        params.max_damage = self.m_model.m_today_rank.self_rank.score
	        self:openView("Activities.WorldBoss.WorldBossReward", params)
	    else
	    	GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("world_boss_str_0016"), delay_close = 2})
	    end
    elseif msg == "log_btn" then

    elseif msg == "self_log_btn" then

    elseif msg == "help_btn" then
    	local params = {}
        params.title = "world_boss_str_0018"
        params.content = "tid#boss_rush2"
        self:openView("Pops.CommonHelpPop", params)
    end
end

function M:requestRankdata()
    local function netCallback(response)
        self.m_model:updateRankData(response)
        self.m_view:refreshUI()
    end
    local rank_data = self.m_model:getRankData()
    local length = #rank_data
    local params = {start = 1, stop = 50}
    self.m_model:getNetData("world_boss_get_ranks", params, netCallback)
end

return M
