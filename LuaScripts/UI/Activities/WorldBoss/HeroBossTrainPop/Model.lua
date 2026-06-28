local M = class("HeroBossTrainPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	if self.m_params.data == nil then
		self:getData("world_boss_trial_index")
	else
		self:getData()
	end
end

function M:onEnter()
	if self.m_params.data then
		self:updateData(self.m_params.data)
	else
		self:updateData(self.m_data.train_challenge)
	end
	self.m_is_jump = self.m_params.is_jump or false --是否是通过跳转打开的页面
	self.active_cfg = self:getActiveByHeroId()
	self.end_ts = self:getDayEnd()
	self.show_task_cfg = self:getDoingTask()
end

function M:updateData(data)
	self.m_data = data
	self.active_cfg = self:getActiveByHeroId()
	self.end_ts = self:getDayEnd()
	self.show_task_cfg = self:getDoingTask()
end

function M:getDamage()
	return self.m_data.max_damage or 0
end

function M:getHeroTrainRankReward()
	if self.m_data.rank == 0 then
		return {}
	end
	if self.m_data.rank <= 10 and self.m_data.rank > 0 then
		local tab = ConfigManager:getCfgByName("train_challenge_ranking")
		return tab[self.m_data.rank].daily_rewards
	end
	local hero_train_tab = self:getRankRewards()
	for i = 1, #hero_train_tab do
		local train_cfg = hero_train_tab[i]
		if i > 1 then
			local last_train_cfg = hero_train_tab[i-1]
			if self.m_data.rank <= train_cfg.id and self.m_data.rank > last_train_cfg.id then
				return train_cfg.daily_rewards
			end
		end
	end
    return {}
end

function M:getRankRewards()
	local tab = ConfigManager:getCfgByName("train_challenge_ranking")
	local new_tab = {}
	for k,v in pairs(tab) do
		v.id = k
		table.insert( new_tab, v)
	end
	local function sortFunc(id_one, id_two)
		return id_one.id < id_two.id
    end
	table.sort(new_tab, sortFunc)
	return new_tab
end

function M:getwDay()
	return self.m_data.train_id or 1
end

--获取一个未完成的任务
function M:getDoingTask()
	local quest_tab = ConfigManager:getCfgByName("train_challenge_quest")
	local vsn_quest_tab = quest_tab[self.m_data.train_group]
	for i=1,#vsn_quest_tab do
		local data = self.m_data.quests[tostring(i)]
		if data then
			if data.status == 0 then
				return vsn_quest_tab[i]
			end
		end 
	end
end

function M:getTasks()
	return self.m_data.quests or {}
end

function M:getHeroTrainCfg()
	local hero_train_tab = ConfigManager:getCfgByName("train_challenge")
    local c_version = self.m_data.train_id
    return hero_train_tab[c_version]
end

function M:getRanks()
    return self.m_data.ranks or {}
end

function M:getRaces()
	local train_challenge_tab = ConfigManager:getCfgByName("train_challenge")
	local c_version = self.m_data.train_id
	local train_cfg = train_challenge_tab[c_version]
	if train_cfg then
		return train_cfg.race 
	end
	return {}
end

function M:getDayEnd()
	local server_time = UserDataManager:getServerTime()
	local next_fresh_time = TimeUtil.getIntTimestamp(server_time)
	return next_fresh_time + 24*3600
end

function M:getActiveByHeroId()
	if self.m_data.train_group == nil then
		return nil
	end
	local active = ConfigManager:getCfgByName("active")
	for k,v in pairs(active) do
		if v.group_id and v.group_id == self.m_data.train_group then
			if UserDataManager:getActivesByOpenId(v.open_id) == true or UserDataManager:getActivesRechargeByOpenId(v.open_id) then
				return v
			end
		end
	end
	return nil
end

function M:getJumpFunc()
	local jump_tab = ConfigManager:getCfgByName("jump")
	for k,v in pairs(jump_tab) do
		if v.open_condition_id == self.active_cfg.open_id then
			if UserDataManager:getActivesByOpenId(v.open_condition_id) == true or UserDataManager:getActivesRechargeByOpenId(v.open_condition_id) then
				return k
			end
		end
	end
	return 0
end

return M
