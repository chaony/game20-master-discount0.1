local M = class("ArenaNormalRankModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("arena_select_arena_rank", {start = 1, stop = 50})
end

function M:onEnter()

end

function M:getRankData()
	local ranks = self.m_data.ranks or {}
	return ranks
end

return M
