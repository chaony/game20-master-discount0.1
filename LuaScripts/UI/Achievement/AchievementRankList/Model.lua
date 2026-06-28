---@class AchievementRankListModel:OODataBase
local M = class("AchievementRankListModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("quest_season_select_top_rank")
end

function M:onEnter()
	self.m_sel_tab_index = nil
	self.m_open_tab_index = 1
	self.m_click_self = false --是否点击自己爬塔的详情
	self.m_season_id = self.m_params.season_id -- 当前赛季
end

function M:getFloorByRace(rece_id)
	local cur_floor = UserDataManager:getRaceFloorByRace(rece_id)
	return cur_floor
end

function M:initData(data)
	self.m_data = data or self.m_data
end

function M:getRankData()
	local ranks = self.m_data.ranks or {}
	return ranks
end

function M:getRankItemCount()
	local ranks = self.m_data.ranks or {}
	return #ranks
end

function M:getRankDataByIndex(index)
	local ranks = self.m_data.ranks or {}
	return ranks[index]
end

function M:getOwnRankData()
	local data = UserDataManager.user_data:getOwnRankData(self.m_data.self_rank)
	if self.m_data.self_rank then
		data.time = self.m_data.self_rank.time
		data.chapter = self.m_data.self_rank.chapter
	end
	return data
end

-- 获取排行奖励
function M:getRankReward()
	local cur_season = self.m_season_id --UserDataManager:getCurSeason() -- 当前赛季
	local achievement_rank_reward_cfg = ConfigManager:getCfgByName("achievement_rank_reward")
	local achievement_rank_reward = achievement_rank_reward_cfg[cur_season] or {}
	local reward_info = {}
	for i, v in pairs(achievement_rank_reward) do
		reward_info[#reward_info+1] = v
	end
	local function sortFun(data1, data2)
		return data1.rank[1] < data2.rank[1]
	end
	table.sort(reward_info, sortFun)
	return reward_info
end

return M
