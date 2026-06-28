local M = class("EvilShadowRankListPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params.data or {}
	self.m_vsn = self.m_params.vsn or 1
	self.m_open_tab_index = 1
	self.m_sel_tab_index = 0
	self.ranks_rewards = self:getRankRewards()
end

--我的排行数据
function M:myRanks()
	-- local m_id = UserDataManager.user_data:getUid()
	-- for k,v in pairs(self.m_data.ranks) do
	-- 	if v.user.uid == m_id then
	-- 		return v
	-- 	end
	-- end
	local data = {}
	data.rank = self.m_data.rank
	data.score = self.m_data.score
	data.user = UserDataManager.user_data.user_status
	return data
end

--排行榜
function M:getRanks()
	return self.m_data.ranks or {}
end

--奖励列表
function M:getRankRewards()
	local base_reward_tab = ConfigManager:getCfgByName("evil_shadow_ranking")
	local vsn_reward_tab = base_reward_tab[self.m_vsn] or {}
	local new_tab = {}
	for k,v in pairs(vsn_reward_tab) do
		if type(k) == "number" then 
			v.id = k
			table.insert(new_tab, v)
		end
	end
	local function sortFunc(id_one, id_two)
		return id_one.id < id_two.id
    end
	table.sort(new_tab, sortFunc)
	for k,v in ipairs(new_tab) do 
		if v.id >3 and new_tab[k-1] then 
			local last_data = new_tab[k-1] 
			v.last_id = last_data.id + 1
		end
	end
	return new_tab
end

return M
