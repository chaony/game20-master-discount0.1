local M = class("HuntTreasuresBigMapPop", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("mining_map_index")
end
M.open_id = {182, 183, 184, 185}

function M:onEnter()
	self.m_mining_region_config = ConfigManager:getCfgByName("mining_region") or {}
	self.m_mining_setting_config = ConfigManager:getSeasonCfgData("mining_setting")
	self:initData(self.m_data)
end

function M:initData(response)
	table.merge(self.m_data, response)
	--self.m_data = response or self.m_data
	self.m_regions = self.m_data and self.m_data.regions or {}
	self.m_scale = self.m_data.scale and self.m_data.scale or {} --已经领取的里程碑
	self.m_occupy_time = self.m_data.occupy_time and self.m_data.occupy_time or {} --里程碑的进度占领时长
	self.m_remainder_time_tab = {0,0,0,0} --各区域剩余时间
	self.m_remainder_type_tab = {0,0,0,0} --各区域加成类型
	self.m_remainder_des_tab = {0,0,0,0} --各区域加成描述
	self:refreshRemianderData()
end

function M:refreshRemianderData()
	for i = 1, 4 do
		local occupy_time = self:getOccupyTime(i)
		self.m_remainder_type_tab[i], self.m_remainder_time_tab[i],self.m_remainder_des_tab[i] = self:getCfgTime(occupy_time)
	end
end

function M:getRegionCfgValueById(region_id, cfg_key)
	local cfg_value = nil
	if self.m_mining_region_config and self.m_mining_region_config[tonumber(region_id)] then
		cfg_value = self.m_mining_region_config[tonumber(region_id)][cfg_key]
	end
	return cfg_value
end

function M:getBoxShowData()
	local scale = self.m_mining_setting_config.scale or {}
	local scale_reward = self.m_mining_setting_config.scale_reward or {}
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


function M:getBarProgress()
	local scale_cfg = self.m_mining_setting_config.scale or {}
	local need_time = scale_cfg[#scale_cfg] and scale_cfg[#scale_cfg] * 60 *60  or 999999
	return self.m_occupy_time / need_time 
end


--各个地块占领的总时长
function M:getOccupyTime(index)
	local occupy_time = 0
	if self.m_regions[tostring(index)].occupy_time then
		occupy_time = self.m_regions[tostring(index)].occupy_time
	end
	return occupy_time
end

--根据占领时长获取占领倍率
function M:getCfgTime(occupy_time)
	local double_time = self.m_mining_setting_config.double_time or {} --{0, 50, 2} 时间区间 0-50小时 倍率 2
	local haploid_time = self.m_mining_setting_config.haploid_time or {}
	local half_time = self.m_mining_setting_config.half_time or {}
	local add_percent = 0
	local remainder_time = 0 --当前区间剩余时间
	local tips_id = "hunt_treasure_str_055"
	if double_time and next(double_time) then
		local double_max = double_time[2] --每个区间的上限
		local haploid_max = haploid_time[2]
		local half_max = half_time[2]
		if occupy_time == 0 then
			add_percent = double_time[3]
			remainder_time = double_max * 60 * 60 - occupy_time
			tips_id = "hunt_treasure_str_053"
		elseif occupy_time > 0 and occupy_time < double_max * 60 * 60 then
			add_percent = double_time[3]
			remainder_time = double_max * 60 * 60 - occupy_time
			tips_id = "hunt_treasure_str_053"
		elseif occupy_time > 0 and occupy_time < haploid_max * 60 * 60 then
			add_percent = haploid_time[3]
			remainder_time = haploid_max * 60 * 60 - occupy_time
			tips_id = "hunt_treasure_str_054"
		else
			add_percent = half_time[3]
			remainder_time = 0
			tips_id = "hunt_treasure_str_055"
		end
	end
	return add_percent, remainder_time, tips_id
end

return M
