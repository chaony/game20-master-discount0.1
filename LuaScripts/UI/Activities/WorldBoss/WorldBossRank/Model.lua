local M = class("WorldBossRankModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("world_boss_get_ranks", {start = 1, stop = 50})
end

function M:onEnter()
	self.m_boss_id = self.m_params.boss_id
end

function M:updateRankData(data)
	table.merge(self.m_data, data)
end

function M:getRankData()
	return self.m_data.ranks or {}
end

function M:getSelfRankData()
	local data = {
		score = self.m_data.self_score,
		rank = self.m_data.self_rank,
		user = UserDataManager.user_data.user_status or {},
		battle_id = 0,
	}
	return data
end

return M
