local M = class("HuntTreasuresModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	local guide_info = UserDataManager.guide_data:getCurGuideInfo()
	local params = {}
	if UserDataManager.guide_data:isGuiding() and guide_info.key == "HuntTreasures" then
		params.is_guide = 1
	end
	self:getData("mining_index", params)
end
function M:onEnter()
	self.m_mining_location_config = ConfigManager:getCfgByName("mining_location") or {}
	self.m_mining_region_config = ConfigManager:getCfgByName("mining_region") or {}
	self.m_mining_setting_config = ConfigManager:getSeasonCfgData("mining_setting")
	self.m_mining_idle_drop_config = ConfigManager:getCfgByName("mining_idle_drop") or {}
	self.m_renovate_config = ConfigManager:getCfgByName("renovate");
	self.m_bg_name = "a_mjmb_bigmap_kongdong"
	self.m_area_page_tab = {}--key: area_id area_id规则是 region_id *10000  + location_id *100, v:  page_index
	self.m_page_tab = {}--按页签存放的区域
	self.m_total_page = 0
	self:initData()
	self:getGuildAdd()
end

function M:initData(net_data)
	if net_data then
		table.merge(self.m_data, net_data)
	end
	local new_data = net_data and net_data or self.m_data
	self.m_mines = new_data.mines or {}
	self.m_region_id = new_data.region_id or 1
	self.m_location_id = new_data.location_id or 1
	self:refreshPageData()
end

--function M:initPageData()
--	self.m_page_tab = self.m_mining_location_config
--	self.m_total_page = #self.m_page_tab[self.m_region_id]
--	self.m_cur_page = self:getCurPage()
--end

function M:refreshPageData()
	local temp = {}
	for i = 1, #self.m_mining_location_config[self.m_region_id] do
		local region_second = self.m_mining_location_config[self.m_region_id][i].region_second
		if not(temp[region_second]) then
			temp[region_second] = {}
		end
		table.insert(temp[region_second], self.m_mining_location_config[self.m_region_id][i])
		if region_second == self.m_sel_tab_index and i ==  tonumber(self.m_location_id) then
			self.m_defautl_index = #temp[region_second]
		end
	end
	self.m_sub_id = self:getSubIdByLocationId(self.m_location_id)
	self.m_page_tab = temp[self.m_sub_id]
	self.m_total_page = #self.m_page_tab
	self.m_cur_page = self:getCurPage()
end

function M:getSubIdByLocationId(location_id)
	local sub_id = self.m_mining_location_config[self.m_region_id][location_id]["region_second"]
	return sub_id
end

function M:getGuildNum()
	local guild_num = 0
	local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	for i = 1, #self.m_mines do
		if self.m_mines[i].is_guild == 1 and self_uid ~= self.m_mines[i].uid then
			guild_num = guild_num + 1
		end
	end
end

local __effect_name = { "Gold","Fire", "Wood", "Water"}
function M:getMineEffectName(mine_index)
	local drop_quality = self:getAreaDropQualityByAreaIndex(mine_index)
	local race_tab = self.m_mining_region_config[self.m_region_id].race
	local race_id = race_tab[1]
	local effect_name = ""
	if drop_quality > 2 then
		local effect_id = math.min(3, (drop_quality - 1))
		effect_name = "Fx_Kuangdong0" .. effect_id .. "_" .. __effect_name[race_id] .. "01"
	end
	return effect_name
end

function M:canRobTimes()
	local max_plunder = self.m_mining_setting_config.frequency or 0
	max_plunder = max_plunder + self.m_data.buy_plunder
	return math.max(0, max_plunder - self.m_data.plunder_times)
end

function M:getRemainBuyTimes()
	local temp = self.m_renovate_config[18].cost
	local frequency_more = self.m_mining_setting_config.frequency_more or 0
	local buy_times = math.max(frequency_more - self.m_data.buy_plunder, 0)
	return buy_times
end

function M:getAreaDropQualityByFirst()
	local drop_quality = 0
	local location_qulity_cfg = self.m_mining_location_config[self.m_region_id][self.m_location_id].location_qulity
	drop_quality = location_qulity_cfg[1]
	return drop_quality
end

function M:getCurRegionDrop(is_show)
	local cur_stage = UserDataManager:getCurStage()
	local drop_quality = self:getAreaDropQualityByFirst()
	local drop_cfg = self.m_mining_idle_drop_config[drop_quality]
	local temp_stage = 0
	for i, v in pairs(drop_cfg) do
		if tonumber(cur_stage) >= tonumber(i) then
			temp_stage = math.max(tonumber(i), temp_stage)
		end
	end
	local show_data = drop_cfg[temp_stage] and  drop_cfg[temp_stage]["produce"][self.m_region_id] or {}
	if is_show then
		show_data = drop_cfg[temp_stage] and  drop_cfg[temp_stage]["idle_show"][self.m_region_id] or {}
	end
	return show_data
end

--获取消耗
function M:getBuyCost(num)
	local num = num or 1
	local cost = 0;
	--真正购买次数
	--local end_num = self.m_buy_plunder + num;
	--local index = 0;
	--local start_num = self.m_buy_plunder + 1;
	local renovate_config = ConfigManager:getCfgByName("renovate");
	for i = 1, num, 1 do
		cost = cost + renovate_config[18].cost[1][3];
	end
	local buy_data =  table.copy(renovate_config[18].cost[1])
	buy_data[3] = cost
	return buy_data
end

function M:getGuildAdd()
	local add_value =0
	if self.m_mining_setting_config then
		local cfg_num = self.m_mining_setting_config.number or {}
		local cur_num = self.m_data.ally_num or 0
		local add_index = 0
		for i = 1, #cfg_num do
			if cur_num >= cfg_num[i] then
				add_index = i
			end
		end
		if  self.m_mining_setting_config.percent_dec and self.m_mining_setting_config.percent_dec[add_index] then
			add_value = self.m_mining_setting_config.percent_dec[add_index]
		end
	end
	return add_value
end

function M:getLocationIdByPage(page)
	return self.m_page_tab[page].id
end

function M:getCurPage()
	for i = 1, #self.m_page_tab do
		if self.m_page_tab[i].id == self.m_location_id then
			return i
		end
	end
end

function M:getLocationName()
	local name = self.m_mining_location_config[self.m_region_id][self.m_location_id].tie_name
	return name
end

function M:getCurSubId()
	local sub_id = self.m_mining_location_config[self.m_region_id][self.m_location_id].region_second
	return sub_id
end

function M:getNextPage(direction)
	local next_page = self.m_cur_page
	if direction == "left_btn" then
		next_page = math.max(self.m_cur_page - 1, 1)
	elseif direction == "right_btn" then
		next_page = math.min(self.m_cur_page + 1, self.m_total_page)
	end
	return next_page
end

function M:getAreaDropQualityByAreaIndex(mine_index)
	local drop_quality = 0
	local location_qulity_cfg = self.m_mining_location_config[self.m_region_id][self.m_location_id].location_qulity
	drop_quality = location_qulity_cfg[mine_index]
	return drop_quality
end

function M:getMineImg(mine_index)
	local mine_quality = 3
	if mine_index then
		mine_quality = self:getAreaDropQualityByAreaIndex(mine_index)
	else
		mine_quality = self:getAreaDropQualityByFirst()
	end
	local region_cfg = self.m_mining_region_config[self.m_region_id]
	local img_name = ""
	if region_cfg and region_cfg.resource_lct and region_cfg.resource_lct[mine_quality] then
		local resource_lct = region_cfg.resource_lct
		img_name = resource_lct[mine_quality]
	end
	return img_name
end

function M:getRegionImg()
	local region_cfg = self.m_mining_region_config[self.m_region_id]
	local img_name = ""
	if region_cfg and region_cfg.resource_bg then
		local resource_bg = region_cfg.resource_bg
		img_name = resource_bg 
	end
	return img_name
end

return M
