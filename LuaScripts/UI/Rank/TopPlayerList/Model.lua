local M = class("TopPlayerListModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("rank_rank_quest_log", {sort = self.m_params.id, quest_id = self.m_params.quest_id})
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

return M
