local M = class("HuntTreasuresMyTeamPop", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("mining_my_mine")
end

function M:onEnter()
	self.m_mining_region_config = ConfigManager:getCfgByName("mining_region") or {}
	self.m_mining_location_config = ConfigManager:getCfgByName("mining_location") or {}
	self.m_mining_idle_drop_config = ConfigManager:getCfgByName("mining_idle_drop") or {}
	self.m_mining_setting_config = ConfigManager:getSeasonCfgData("mining_setting")

	self.m_back_refresh = self.m_params.back_refresh
	self.m_show_order_btn_flag = self.m_params.show_order_btn_flag
	self.m_cur_desc = ""
	self.m_edit_status = 1 -- 1 默认状态 2 选择要调整的队伍 3 调整顺序状态
	self:initData(self.m_data, true)
	self.m_reward_status = {false, false, false, false}
	self.m_first_enter = true
	self.m_max_owner_time = self.m_mining_setting_config.time
	local vip = UserDataManager.user_data:getUserStatusDataByKey("vip")
	local vip_cfg = ConfigManager:getCfgByName("vip")
	local vip_time = 0
	if vip_cfg[tonumber(vip)].mining_time  then
		vip_time = vip_cfg[tonumber(vip)].mining_time
	end
	self.m_max_owner_time  = self.m_max_owner_time  + vip_time
	self.m_max_owner_time = self.m_max_owner_time  * 60 * 60
	self.m_stage_id = UserDataManager:getCurStage()
end

function M:updateRewardStatus()
	for i = 1, 4 do
		local show_reward = self:getDropReward(i)
		if self.m_first_enter and next(show_reward) then
			self:setRewardStatus(i, true)
		end
	end
end

function M:setRewardStatus(index, status)
	self.m_reward_status[index] = status
end

function M:getBarProgress()
	local scale_cfg = self.m_mining_setting_config.scale or {}
	local need_time = scale_cfg[#scale_cfg] and scale_cfg[#scale_cfg] * 60 *60  or 999999
	return self.m_occupy_time / need_time
end


function M:initData(data, is_replace)
	if is_replace and data then
		self.m_data = data
	else
		if data then
			if self.m_data.my_mines and data.my_mines then
				table.merge(self.m_data.my_mines, data.my_mines)
				data.my_mines = nil
			end
			table.merge(self.m_data, data)
		end
	end
	self.mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("mining_defense"))
	for i = 1, 4 do
		if self.mult_main_teams[i] == nil then
			self.mult_main_teams[i] = {}
		end
	end
	self.m_scale = self.m_data.scale and self.m_data.scale or {} --已经领取的里程碑
	self.m_occupy_time = self.m_data.occupy_time and self.m_data.occupy_time or {} --里程碑的进度占领时长
end
function M:getRegionCfgValueById(region_id, cfg_key)
	local cfg_value = nil
	if self.m_mining_region_config and self.m_mining_region_config[tonumber(region_id)] then
		cfg_value = self.m_mining_region_config[tonumber(region_id)][cfg_key]
	end
	return cfg_value
end

function M:getAreaDropQualityByAreaIndex(mine_id)
	local drop_quality = 0
	local region_id =  math.modf(mine_id / 10000)
	local location_id = math.modf((mine_id - region_id * 10000) / 100)
	local area_id = mine_id - region_id * 10000 - location_id *100
	local location_qulity_cfg = self.m_mining_location_config[region_id][location_id].location_qulity
	drop_quality = location_qulity_cfg[area_id]
	local produce_add = self.m_mining_location_config[region_id][location_id] and self.m_mining_location_config[region_id][location_id].produce or 1
	return drop_quality, produce_add
end

function M:getCurRegionDrop(team_id, mine_id)
	local drop_quality, produce_add = self:getAreaDropQualityByAreaIndex(mine_id)
	local drop_cfg = self.m_mining_idle_drop_config[drop_quality]
	local temp_stage = 0
	local cur_stage =self:getStageId(team_id)
	for i, v in pairs(drop_cfg) do
		if tonumber(cur_stage) >= tonumber(i) then
			temp_stage = math.max(tonumber(i), temp_stage)
		end
	end
	local region_id =  math.modf(mine_id / 10000)
	local show_data = drop_cfg[temp_stage] and  drop_cfg[temp_stage]["produce"][region_id] or {}
	return show_data, produce_add
end

function M:getShowData()
	local show_data = {}
	local mining_defense = self.mult_main_teams
	for i = 1,4 do
		local team = mining_defense[i] or {}
		local team_heros_data = {}
		for index = 1,5 do
			local hero_id = team[index] or ""
			local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(hero_id)
			local data = nil
			if hero_data and hero_cfg then
				data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
				data.quality = hero_data.evo
				data.card_id = hero_id
				data.hero_data = hero_data
			end
			team_heros_data[index] = data or {}
		end
		show_data[i] = {team_heros_data = team_heros_data}
	end
	return show_data
end

function M:getOccupyTime(team_id)
	local occ_time = 0
	if self.m_data.my_mines and self.m_data.my_mines[tostring(team_id)] and self.m_data.my_mines[tostring(team_id)].occupy_time ~= 0  then
		occ_time = self.m_data.my_mines[tostring(team_id)].occupy_time
	end
	return occ_time
end

function M:getRewardReceiveTime(team_id)
	local occ_time = 0
	if self.m_data.my_mines and self.m_data.my_mines[tostring(team_id)] and self.m_data.my_mines[tostring(team_id)].receive_ts ~= 0  then
		occ_time = self.m_data.my_mines[tostring(team_id)].receive_ts
	end
	return occ_time
end

function M:getDropReward(team_id)
	local normal_gifts = {}
	local drop_gifts = {}
	if self.m_data.my_mines and self.m_data.my_mines[tostring(team_id)] and self.m_data.my_mines[tostring(team_id)].normal_gifts then
		normal_gifts = table.copy( self.m_data.my_mines[tostring(team_id)].normal_gifts)
	end
	if self.m_data.my_mines and self.m_data.my_mines[tostring(team_id)] and self.m_data.my_mines[tostring(team_id)].drop_gifts then
		drop_gifts = table.copy(self.m_data.my_mines[tostring(team_id)].drop_gifts) 
	end
	if next(drop_gifts) then
		for i = 1, #drop_gifts do
			table.insert(normal_gifts, 1, drop_gifts[i]) 
		end
	end
	return normal_gifts
end

function M:getStageId(team_id)
	local stage_id = 0
	if self.m_data.my_mines and self.m_data.my_mines[tostring(team_id)] and self.m_data.my_mines[tostring(team_id)].stage_id  then
		stage_id = self.m_data.my_mines[tostring(team_id)].stage_id
	end
	return stage_id
end

function M:getMineOid(team_id)
	local oid = 0
	if self.m_data.my_mines and self.m_data.my_mines[tostring(team_id)] then
		oid = self.m_data.my_mines[tostring(team_id)].oid
	end
	return oid
end

function M:getMineName(team_id)
	local oid = self:getMineOid(team_id)
	local name = ""
	if oid ~= 0 then
		local region_id =  math.modf(oid / 10000)
		local location_id = math.modf((oid - region_id * 10000) / 100)
		name = self.m_mining_location_config[region_id][location_id] and self.m_mining_location_config[region_id][location_id].name or ""
		local produce_add = self.m_mining_location_config[region_id][location_id] and self.m_mining_location_config[region_id][location_id].produce or 1
	else
		if self.m_mining_region_config and self.m_mining_region_config[tonumber(team_id)] then
			name = self.m_mining_region_config[tonumber(team_id)].name
		end
		return name
	end
	return name
end

function M:exchangeTeam(index, exchange_index)
	self.mult_main_teams[index], self.mult_main_teams[exchange_index] = self.mult_main_teams[exchange_index], self.mult_main_teams[index]
end

function M:getBoxShowData()
	local scale = self.m_mining_setting_config.scale or {}
	local scale_stage_reward = self.m_mining_setting_config.scale_stage_reward or {}
	local scale_reward_level = self.m_mining_setting_config.scale_reward_level or {}
	local stage_index = 1 
	for i = 1, #scale_reward_level do
		if self.m_stage_id >= scale_reward_level[i] then
			stage_index = i
		end
	end
	local scale_reward = scale_stage_reward[stage_index - 1] or {} --配置从0开始
	return scale, scale_reward
end

function M:getBoxStatusByIndex(index)
	local status = 0
	local scale_cfg = self.m_mining_setting_config.scale or {}
	local cur_scale = scale_cfg[index] or 0
	local need_time = scale_cfg[index] and scale_cfg[index] * 60 *60  or 999999
	if self.m_occupy_time >= need_time then
		status = 2
	end
	for i, v in pairs(self.m_scale) do
		if v == cur_scale then
			status = -1
		end
	end
	return status
end

return M
