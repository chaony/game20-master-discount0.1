local M = class("ActiveBossModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.level_up = self.m_params.level_up or 1 -- 1 英雄最低提升到300级、0 等级不变
	self.m_open_id = self.m_params.open_id or 327
	self.m_version = self.m_params.version or 1
	self:getData("common_world_boss_index", {open_id = self.m_open_id, vsn = self.m_version})
end

function M:onEnter()
	 --Logger.log(self.m_data,"data === ")
	
	self.m_boss_max_hp = self.m_data.max_hp and self.m_data.max_hp or 0
	self.m_boss_hp_cid = self.m_data.boss_hp_cid and self.m_data.boss_hp_cid or 0
	self.m_boss_last_damage = self.m_data.last_damage and  self.m_data.last_damage or 0
end

--max_damage  最高伤害
function M:getMaxBattleDamage()
	local value = self.m_data.max_damage or 0
	--for i,v in ipairs(self.m_data.damage_log) do
	--	local damage = v.damage or 0
	--	if value < damage then
	--		value = damage
	--	end
	--end
	return value
end

function M:updateData(data)
	if data then
		self.m_data = data
		self.m_boss_max_hp = data.max_hp and data.max_hp or 0
		self.m_boss_hp_cid = data.boss_hp_cid and data.boss_hp_cid or 0
		self.m_boss_last_damage = data.last_damage and data.last_damage or 0
	end
	self:updateDanData()
end

function M:getBossData()
	local boss_cfg = self:getBossCfg()
	local stage_battle = ConfigManager:getCfgStageBattle(boss_cfg.battle_id)--ConfigManager:getCfgByName("stage_battle")
	if boss_cfg.battle_id and stage_battle and stage_battle.monster then
		local monster = stage_battle.monster
		local hero_detail_cfg = ConfigManager:getCfgByName("hero_detail")[monster[1].id];
		return hero_detail_cfg
	end
	return nil
end

function M:updateDanData()
	--local world_boss_reward = ConfigManager:getCfgByName("world_boss_reward")
	--local dan = self.m_data.self_rank
	--if world_boss_reward[dan] == nil then
	--	local table_key = {}
	--	for k,v in pairs(world_boss_reward) do
	--		table_key[#table_key + 1] = k
	--	end
	--	local function sort(data1, data2)
	--		return data1 < data2
	--	end
	--	table.sort(table_key,sort)
	--	local index = table.bisect(table_key, dan)
	--	-- dan = table_key[index]
	--	local damage = self:getMaxBattleDamage()
	--	for i=index, #table_key do
	--		dan = table_key[i]
	--		local dan_data = world_boss_reward[dan]
	--		if dan_data.min_damage <= damage then
	--			break
	--		end
	--	end
	--
	--end
	--self.m_dan = dan
	--self.m_reward = world_boss_reward[dan]
end

function M:updateKillRankScore(like_index)
	if self.m_data.kill_ranks and self.m_data.kill_ranks[like_index] then
		self.m_data.kill_ranks[like_index].score = self.m_data.kill_ranks[like_index].score + 1
	end
end

function M:getLeftTimes()
	local total_times = ConfigManager:getVipValueByKey("word_boss_challenge_times", 0)
	return total_times - self.m_data.battle_times
end

function M:getWorldBossHp()
	local boss_max_hp = self.m_boss_max_hp
	total_damage = math.min(self.m_boss_last_damage, boss_max_hp)
	local cur_boss_hp = boss_max_hp - total_damage
	local total_hp_percent = total_damage / boss_max_hp
	local cur_part = 0
	local cur_part_damage = 0
	local cur_hp_percent = 0
	for i = 4, 1, -1 do
		if cur_boss_hp >= (i-1)/4 * boss_max_hp then
			cur_part = 4 - i
			cur_hp_percent = (total_damage - cur_part / 4 * boss_max_hp) / (boss_max_hp / 4)
			break
		end
	end
	cur_hp_percent = math.min(1, cur_hp_percent)
	total_hp_percent = math.min(1, total_hp_percent)
	return cur_part, cur_hp_percent, total_hp_percent
end

function M:getNewBossRewardCfg()
	local world_boss_reward_cfg = ConfigManager:getCfgByName("active_world_boss_rewards")
	if world_boss_reward_cfg and next(world_boss_reward_cfg) and world_boss_reward_cfg[self.m_open_id] then
		if world_boss_reward_cfg[self.m_open_id][self.m_version] then
			local reward_data = world_boss_reward_cfg[self.m_open_id][self.m_version][self.m_boss_hp_cid] or {}
			return reward_data.reward_lost_hp
		end
	end
	return {}
end

function M:getRewardBoxNum()
	local num = 0
	local max_damage = self.m_data.last_damage or 0
	local reward_lost_hp = self:getNewBossRewardCfg()
	if not(next(reward_lost_hp)) then
		local world_boss = ConfigManager:getCfgByName("active_world_boss")
		local world_boss_item = world_boss[self.m_open_id] or {}
		world_boss_item =  world_boss_item[self.m_version] or {}
		reward_lost_hp = world_boss_item.reward_lost_hp or {}
	end
	for k,v in ipairs(reward_lost_hp) do
		if v < max_damage then
			num = k
		end
	end
	return num
end

function M:canChallenge()
	-- local hour = ConfigManager:getCommonValueById(95)
	-- Logger.log(hour, "hour ===")
	-- local lock_time = self.m_data.refresh_time - hour*3600
	-- local server_time = UserDataManager:getServerTime()
	-- return false
end

function M:getBossCfg()
	local world_boss = ConfigManager:getCfgByName("active_world_boss")
	local world_boss_item = world_boss[self.m_open_id] or {}
	local version_item = world_boss_item[self.m_version] or {}
	return version_item
end

function M:getNextRewardDamage()
	local world_boss_cfg = self:getNewBossRewardCfg()
	local reward_lost_hp = world_boss_cfg ~= {} and world_boss_cfg or self:getBossCfg().reward_lost_hp
	local cur_damage = self:getMaxBattleDamage()
	local cur_index = 1
	local need_damage = 0
	local is_max = true
	for i, v in ipairs(reward_lost_hp) do
		if cur_damage < v then
			cur_index = i
			is_max = false
			break
		end
	end
	if not(is_max) then
		need_damage = reward_lost_hp[cur_index] - cur_damage
	end
	return need_damage, is_max
end

function M:getKillRewardReceived(kill_num)
	if kill_num and self.m_data.recv_kill_num_reward then
		for i,v in pairs(self.m_data.recv_kill_num_reward) do
			if v == kill_num then
				return true
			end
		end
	end
	return false
end

--清凉夏日 获取第一个未完成任务数据
function M:getFisrtTaskData()
	local TaskCfg = ConfigManager:getCfgByName("active_world_quest")
	local data = self.m_data.daily_quests
	if TaskCfg and  data then
		--self.m_task_data = TaskCfg[self.m_data.open_id][self.m_data.m_version]
		TaskCfg = TaskCfg[self.m_open_id or 368][self.m_version or 3] or {}
		for k,v in ipairs(TaskCfg) do
			local status = data[tostring(k)].status 
			if status == 0 then 
				local data_ ={}
				data_.des = TaskCfg[k].name2 or "" --描述
				data_.reward = TaskCfg[k].reward
				data_.target_type = TaskCfg[k].target_type
				data_.target_value = TaskCfg[k].target_value
				data_.real_value = data[tostring(k)].target_value or 0
				data_.war_order = TaskCfg[k].war_order
				return data_
			end
		end
	end
	return nil -- 没有任务 或者都完成
end

--获取活动数据
function M:getActiveData(open_id)
	local id = self.m_open_id
	if open_id then
		id = open_id
	end
	local active_tab = ConfigManager:getCfgByName("active")
	for i, v in pairs(active_tab) do
		if v.open_id == id and v.version == self.m_version then
			return v
		end
	end
	return nil
end

return M
