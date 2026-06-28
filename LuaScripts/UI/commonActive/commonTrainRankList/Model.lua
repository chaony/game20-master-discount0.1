local M = class("commonTrainRankListModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self.m_select_index = self.m_params.select_index or 1
	self.hero_train_data = self.m_params.data
	self.m_active_tab_num = self.m_params.active_tab_num or 1
	self:getData("common_train_challenge_ranks", {open_id = self.m_params.open_id,version = self.m_params.version,is_version = 0,start = 1,stop = 20})
end

function M:onEnter()
	self.refresh_id = 1
	--Logger.logError(self.m_data,"排行榜数据~~~~~~~~~~~~~~")
end

--刷新服务器数据
function M:updateServer(response)
	table.merge(self.m_data,response)
end

function M:getRanks()
	return self.m_data.ranks
end

function M:getMyRank()
	local rank_reward_tab = self:getRankRewards()
	return 1, self.m_data.self_rank
end

function M:getMyScore()
	return self.m_data.self_score
end

function M:getRankRewards()
	local table_name = self.read_table_name
	local table_name = ConfigManager:getCfgByName(table_name)
	local rewards = {}
	if table_name[self.m_params.open_id] then
		rewards = table_name[self.m_params.open_id][self.m_params.version]
	end
	local new_tab = {}
	for k,v in pairs(rewards) do
		v.id = k
		table.insert( new_tab, v)
	end
	local function sortFunc(id_one, id_two)
		return id_one.id < id_two.id
    end
	table.sort(new_tab, sortFunc)
	self.rank_rewards = new_tab
	return new_tab
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