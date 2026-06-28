local M = class("TowerStageRankModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	local race = self.m_params.race or 0
	local sort = 2
	if race > 0 then
		sort = 2000 + race
	end
	self:getData("rank_rank_info", {sort = sort, start = 1, stop = 50})
end

function M:onEnter()

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
	return UserDataManager.user_data:getOwnRankData(self.m_data)
end

return M
