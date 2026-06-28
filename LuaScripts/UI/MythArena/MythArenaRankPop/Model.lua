local M = class("MythArenaRankPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("myth_arena_select_arena_rank", {start = 1, stop = 20})
end

function M:onEnter()

end

function M:getRankData()
	local ranks = self.m_data.ranks or {}
	return ranks
end

function M:insertRankData(new_rank_data)
	for i = 1, #new_rank_data do
		table.insert(self.m_data.ranks, new_rank_data[i])
	end
end

function M:getLoadIndex()
	local max_rank_count = 128
	local cur_rank_nums = table.nums(self:getRankData())
	local start_pos, end_pos = 0, 0
	if cur_rank_nums + 10 <= max_rank_count then
		start_pos = cur_rank_nums + 1
		end_pos = cur_rank_nums + 10
	elseif max_rank_count - cur_rank_nums > 0 then
		start_pos = cur_rank_nums + 1
		end_pos = max_rank_count
	end
	return start_pos, end_pos
end

return M
