local M = class("BudoServerRankListPopModel", LikeOO.OODataBase)

local __max_rank_count = 100
function M:onCreate()
	M.super.onCreate(self)
	local params = {}
	params.start = 1
	params.stop = 10
	self:getData("tower_active_show_cross_rank", params)
end

function M:onEnter()
	--Logger.logWarningAlways(table.nums(self.m_total_rank_data)," x=c=x=cx=c=x=======")
	self.m_rank_tab = {} --自己的排名数据
	self.m_my_rank_tab = {} --自己的排名数据
	self.m_count_tab = {} --各个排行榜的人数
	self.m_is_corss = 1 -- 是否跨服 2 本服 1 跨服
	--self.m_temp_user = self.m_params.temp_user
	self:initRankData()
end

function M:initRankData(response)
	if response then
		self.m_data = response
	end
	if not(self.m_my_rank_tab[tostring(self.m_is_corss)]) then
		--for i = 1, 10 do
		--	self.m_data.ranks[i] = {rank = i, score = i, time = i, user = self.m_temp_user.user}
		--end
		--self.m_data.self_rank = { rank = 99, score = 100, user = {}}
		if self.m_is_corss == 2 then
			self.m_data.self_rank = {}
			self.m_data.self_rank.rank = self.m_data.rank
			self.m_data.self_rank.score = self.m_data.score
		end
		self.m_my_rank_tab[tostring(self.m_is_corss)] = self.m_data.self_rank or {} --自己的排名数据
		
		self.m_rank_tab[tostring(self.m_is_corss)] = self.m_data.ranks or {}
		self.m_count_tab[tostring(self.m_is_corss)] = self.m_data.count or 0
	end
end

function M:getLoadIndex()
	local max_rank_count = math.min(self:getCurRankCount(), __max_rank_count)
	local cur_rank_nums = table.nums(self:getCurRankData())
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

function M:getCurMyRankData()
	return self.m_my_rank_tab[tostring(self.m_is_corss)]
end

function M:getCurRankCount()
	return self.m_count_tab[tostring(self.m_is_corss)]
end

function M:getCurRankData()
	return self.m_rank_tab[tostring(self.m_is_corss)]
end

function M:setRankCross(is_corss)
	self.m_is_corss = is_corss
end

function M:insertRankData(new_rank_data)
	for i = 1, #new_rank_data do
		table.insert(self.m_rank_tab[tostring(self.m_is_corss)], new_rank_data[i])
	end
end

function M:isHaveRankDataByCross(rank_cross)
	if not(self.m_rank_tab[tostring(rank_cross)]) then
		return true
	else
		return false
	end
end

return M
