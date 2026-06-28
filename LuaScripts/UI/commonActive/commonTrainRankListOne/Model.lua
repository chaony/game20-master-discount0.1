local M = class("commonTrainRankListOneModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self.m_select_index = self.m_params.select_index or 2
	self.hero_train_data = self.m_params.data
	self.m_active_tab_num = self.m_params.active_tab_num or 1
	self.m_url = self.m_params.url or "gacha_active_rank_info"
	self:getData(self.m_url, {open_id = self.m_params.open_id,version =self.m_params.version,start = 1,stop = 50})
end

function M:onEnter()
end

function M:getRanks()
	return self.m_data.ranks
end


function M:getMyScore()
	return self.m_data.score
end

function M:getRankScope(index)
	if index > 1 then
		local ranks = self.rank_rewards
		local last_rank = ranks[index]
		if last_rank then
			return last_rank.parameter[1],last_rank.parameter[2]
		end
	end
	return 0
end

return M