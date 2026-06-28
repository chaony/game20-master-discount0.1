local M = class("NewYearTeamRankListPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	local params = {}
	params.start = 1
	params.stop = 50
	params.version = 1
	params.rank_type = 1
	self:getData("spring_festival_member_rank_info", params)
end

function M:onEnter()
	self.m_open_tab_index = 1
	self.member_rank_info = self.m_data
	self.m_sel_tab_index = 1
	self.m_version = self.m_params.version --版本号
	self.m_day = self.m_params.day --天数
	self.m_key = 0 -- 期数
	local dinner_type_tab = ConfigManager:getCfgByName("dinner_type");
	local vsn_tab = dinner_type_tab[self.m_version]
	for i = 1, #vsn_tab do
		local cur_cfg = vsn_tab[i]
		if self.m_day >= cur_cfg.start_day and self.m_day <= cur_cfg.end_day then
			self.m_key = i
		end
	end
	if self.m_key == 0 then
		local last_cfg = vsn_tab[#vsn_tab]
		if last_cfg then
			self.m_key = #vsn_tab
		end
	end
	self.ranks_rewards = self:getRankRewards()
end

function M:updateData(index, callback)
	if index == 1 then --个人排行榜
		if self.member_rank_info then 
			if callback then 
				callback()
			end
			return
		end
		local function netCallback(response)
			self.member_rank_info = response
			if callback then 
				callback()
			end
		end
		local params = {}
		params.start = 1
		params.stop = 50
		params.version = 1
		params.rank_type = 0
		self:getNetData("spring_festival_member_rank_info", params, netCallback)
	elseif index == 2 or index == 3 then  --帮会排行榜
		if self.guild_rank_info then 
			if callback then 
				callback()
			end
			return
		end
		local function netCallback(response)
			self.guild_rank_info = response
			if callback then 
				callback()
			end
		end
		local params = {}
		params.start = 1
		params.stop = 10
		params.version = 1
		self:getNetData("spring_festival_guild_rank_info", params, netCallback)
	else	
		if callback then 
			callback()
		end
	end
end


function M:getTeamRanks()
	if self.guild_rank_info == nil or next(self.guild_rank_info) == nil then
		return {}
	end
	return self.guild_rank_info.ranks or {}
end

function M:getTeamsMainRank()
	if self.guild_rank_info == nil or next(self.guild_rank_info) == nil or self.guild_rank_info.ranks == nil then
		return {}
	end
	local m_guid = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
	for k,v in pairs(self.guild_rank_info.ranks) do
		if m_guid == v.user.uid then
			return v
		end
	end
	-- local params = {}
	-- params.user = UserDataManager.user_data.user_status
	-- params.rank = self.guild_rank_info.rank or 0
	-- params.score = self.guild_rank_info.score or 0
	-- return params
	return nil
end

function M:getInsideRanks()
	if self.member_rank_info == nil or next(self.member_rank_info) == nil then
		return {}
	end
	return self.member_rank_info.ranks or {}
end

function M:getInsideMainRank()
	if self.member_rank_info == nil or next(self.member_rank_info) == nil then
		return {}
	end
	local params = {}
	params.user = UserDataManager.user_data.user_status
	params.rank = self.member_rank_info.rank or 0
	params.score = self.member_rank_info.score or 0
	params.daily_score = self.member_rank_info.daily_score or 0
	return params
end


function M:getRankRewards()
	local dinner_rank_tab = ConfigManager:getCfgByName("dinner_rank");
	if next(dinner_rank_tab) == nil then
		return {}
	end
	local vsn_reward_tab = dinner_rank_tab[self.m_version]
	local sub_key = self:getSubKey()
	if vsn_reward_tab[self.m_key] == nil then 
		return {}
	end
	local key_tab = vsn_reward_tab[self.m_key][tonumber(sub_key)] or {}
	local new_tab = {}
	if key_tab == nil then 
		return {}
	end
	for k,v in pairs(key_tab) do
		table.insert(new_tab,{rank = tonumber(k), data = v} )
	end
	local function sortFun(data1, data2)
		return data1.rank < data2.rank
	end
	table.sort(new_tab, sortFun )
	for i = 1, #new_tab do 
		if i > 1 then 
			local lase_data = new_tab[i-1]
			new_tab[i]["last_rank"] = lase_data.rank + 1
		else
			new_tab[i]["last_rank"] = 1	
		end
	end
	return new_tab
end

function M:getMGuildRank()
	if self.guild_rank_info == nil then
		return 0
	end
	return self.guild_rank_info.rank or 0
end

function M:getSubKey()
	local cross_team_festival_tab = ConfigManager:getCfgByName("cross_team_festival");
	local server_id = UserDataManager.server_data:getServerId()
	if cross_team_festival_tab == nil or next(cross_team_festival_tab) == nil then
		return "0"
	end
	for k,v in pairs(cross_team_festival_tab) do
		local hv = false
		for kk,vv in pairs(v.servers) do
			if server_id == vv then
				hv = true
			end
		end
		if hv == true then
			return tostring(v.key) 
		end
	end
	return "0"
end

return M
