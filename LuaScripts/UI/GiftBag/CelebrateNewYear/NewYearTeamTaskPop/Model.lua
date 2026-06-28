local M = class("NewYearTeamTaskPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_open_tab_index = 1
	self.m_sel_tab_index = 1
	self.m_version = self.m_params.version or 1 --版本号
	self.m_day = self.m_params.day or 1 --天数
	self.m_key = 0 -- 期数
	self.m_guild_score = self.m_params.guild_score or 0 --积分
	self.m_dinner_done = self.m_params.dinner_done or {} --领取记录
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
	elseif index == 2 then  --帮会排行榜
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


function M:getRankRewards()
	local dinner_rank_tab = ConfigManager:getCfgByName("dinner_reward");
	if next(dinner_rank_tab) == nil then
		return {}
	end
	local vsn_reward_tab = dinner_rank_tab[self.m_version]
	local key_tab = vsn_reward_tab[self.m_key]
	local new_tab = {}
	for k,v in pairs(key_tab) do
		table.insert(new_tab,{id = tonumber(k), data = v} )
	end
	local function sortFun(data1, data2)
		return data1.id < data2.id
	end
	table.sort(new_tab, sortFun )
	return new_tab
end

function M:getTaskData(id, score)
	-- 0 进行中
	-- 1 可领奖
	-- 2 已完成
	local key_dinner_done = self.m_dinner_done[tostring(self.m_key)]
	if key_dinner_done then
		for k,v in pairs(key_dinner_done) do
			if v == id then
				return 2
			end
		end
	end
	if self.m_guild_score >= score then
		return 1
	end
	return 0
end


return M
