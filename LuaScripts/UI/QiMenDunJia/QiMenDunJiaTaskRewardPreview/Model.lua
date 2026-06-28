local M = class("QiMenDunJiaTaskRewardPreviewModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params.main_data or {}
	self.m_version = self.m_data.ver or 0
	self.m_explore_value = self.m_data.explore_value or 0
	self.m_explore_done_data = self.m_data.explore_done or {}
	self.m_explore_data = self.m_params.explore_data or {}
end

function M:getVersion()
	return self.m_version
end

function M:updateExploreDoneData(data)
	table.merge(self.m_explore_done_data, data)
	self:initExploreData()
end

function M:initExploreData()
	self.m_explore_data = {}
	local cur_season = UserDataManager:getCurSeason()
	local gve_tab = ConfigManager:getCfgByName("gve") or {}
	local gve_season_tab = gve_tab[cur_season] or {}
	local gve_explore_score_tab = gve_season_tab.explore_scale or {}
	local gve_explore_reward_tab = gve_season_tab.explore_reward or {}

	for k,v in pairs(gve_explore_score_tab) do
		local score = v
		local status = 0
		if table.keyof(self.m_explore_done_data, k) then
			status = 2	-- 已领取
		else
			if self.m_explore_value >= score then
				status = 1 -- 可领取
			else
				status = 0 -- 未完成
			end
		end
		table.insert(self.m_explore_data, {id = k, score = score, status = status, reward = {gve_explore_reward_tab[k]} or {}})
	end
	table.sort(self.m_explore_data, function(data1, data2)
		return data1.score < data2.score
	end)
end

function M:getExploreData()
	return self.m_explore_data, self.m_explore_value
end

return M
