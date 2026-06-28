local M = class("HuntTreasuresGuildAreaInfoPop", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self.m_mine_oid =  self.m_params.mines_data.oid
	self:getData("active_mining_mine_detail",{mine_oid = self.m_mine_oid, ver = self.m_params.version})
end

M.m_status_code = 
{
	CAN_OWNER = 0,--可占领
	CAN_ROB = 1, --可掠夺
	IS_SELF = 2, --已占领
	NEED_BUY = 3, --需购买次数
	NO_TIMES = 4, --没次数了
}
function M:onEnter()
	self.m_status = 0
	self.m_mining_region_config = ConfigManager:getCfgByName("active_mining_region") or {}
	self.m_mining_location_config = ConfigManager:getCfgByName("active_mining_location") or {}
	self.m_mining_setting_config = ConfigManager:getCfgByName("active_mining_setting")
	self.m_mining_idle_drop_config = ConfigManager:getCfgByName("active_mining_idle_drop") or {}
	self.m_renovate_config = ConfigManager:getCfgByName("renovate");
	self.m_mines_data = self.m_params.mines_data
	self.m_version = self.m_params.version or 1
	self.m_oid =self.m_mines_data.oid
	self.m_user = self.m_mines_data.user
	self.m_old_user = self.m_mines_data.user
	self.m_desc = self.m_mines_data.desc
	self.m_robot_id = self.m_data.robot_id
	self.m_plunder_times = self.m_params.plunder_times and self.m_params.plunder_times or 0
	self.m_buy_plunder = self.m_params.buy_plunder and self.m_params.buy_plunder or 0
	self.m_area_index = self.m_params.area_index and self.m_params.area_index or 1
	self.m_stage_id = self.m_data.stage_id
	if self.m_stage_id == 0 and self.m_robot_id > 0 then
		self.m_stage_id = UserDataManager:getCurStage()
	end
	self.m_region_id = math.modf(self.m_oid / 10000)
	self.m_location_id = math.modf((self.m_oid - self.m_region_id * 10000) / 100)
	self.m_mine_img_name = self.m_params.mine_img_name and self.m_params.mine_img_name or ""
	_, self.m_produce_add = self:getMineName()
	self:getMineStatus()
end

function M:updateNetData(response)
	self.m_data = response
end

function M:isNeedRefreshMain()
	return  self.m_user.uid ~= self.m_old_user.uid 
end

function M:getDataByKey(key)
	if self.m_data and self.m_data[key] then
		return self.m_data[key]
	end
	return nil
end

function M:isMaxOwner()
	local max_num = 1
	return self.m_data.occupy_num >= max_num
end

--获取消耗
function M:getBuyCost(num)
	local num = num or 1
	local cost = 0;
	--真正购买次数
	--local end_num = self.m_buy_plunder + num;
	--local index = 0;
	--local start_num = self.m_buy_plunder + 1;
	local m_renovate_config = ConfigManager:getCfgByName("renovate");
	for i = 1, num, 1 do
		cost = cost + m_renovate_config[18].cost[1][3];
	end
	local buy_data =  table.copy(m_renovate_config[18].cost[1]) 
	buy_data[3] = cost
	return buy_data
end

function M:getRemainBuyTimes()
	local temp = self.m_renovate_config[18].cost
	local frequency_more = self.m_mining_setting_config.frequency_more or 0
	local buy_times = math.max(frequency_more - self.m_buy_plunder, 0) 
	return buy_times
end

function M:isMaxPlunder()
	local max_plunder = self.m_mining_setting_config.frequency or 0
	max_plunder = max_plunder + self.m_buy_plunder
	return self.m_plunder_times >= max_plunder
end

function M:canRobTimes()
	local max_plunder = self.m_mining_setting_config.frequency or 0
	max_plunder = max_plunder + self.m_buy_plunder
	return math.max(0, max_plunder - self.m_plunder_times) 
end

function M:isCanBuyPlunder()
	local frequency_more = self.m_mining_setting_config.frequency_more or 0
	return  self.m_buy_plunder < frequency_more
end

function M:isSelfMine()
	local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	local owner_id = 0
	if self:getDataByKey("def_uid") then
		owner_id = self:getDataByKey("def_uid")
	end
	return self_uid == owner_id
end

function M:getMineName()
	local name = self.m_mining_location_config[self.m_region_id][self.m_location_id] and self.m_mining_location_config[self.m_region_id][self.m_location_id].name or ""
	local produce_add = self.m_mining_location_config[self.m_region_id][self.m_location_id] and self.m_mining_location_config[self.m_region_id][self.m_location_id].produce or 1
	return name, produce_add
end

function M:getAreaDropQualityByAreaIndex()
	local drop_quality = 0
	local location_qulity_cfg = self.m_mining_location_config[self.m_region_id][self.m_location_id].location_qulity
	drop_quality = location_qulity_cfg[self.m_area_index]
	return drop_quality
end

function M:getAreaDropQualityDes()
	local drop_quality = self:getAreaDropQualityByAreaIndex()
	local des_id = ""
	if drop_quality == 2 or drop_quality == 3 then
		des_id = self.m_mining_setting_config.location2_des
	elseif drop_quality >= 4 and drop_quality <= 6 then
		des_id = self.m_mining_setting_config.location3_des
	end
	return des_id
end

function M:getCurRegionDrop(is_idle_show)
	local drop_quality = self:getAreaDropQualityByAreaIndex()
	local drop_cfg = self.m_mining_idle_drop_config[self.m_version][drop_quality]
	local temp_stage = 0
	for i, v in pairs(drop_cfg) do
		if tonumber(self.m_stage_id) >= tonumber(i) then
			temp_stage = math.max(tonumber(i), temp_stage)
		end
	end
	local show_data = drop_cfg[temp_stage] and drop_cfg[temp_stage]["produce"][self.m_region_id] or {}
	if is_idle_show then
		show_data = drop_cfg[temp_stage] and drop_cfg[temp_stage]["idle_show"][self.m_region_id] or {}
	end
	return show_data
end

function M:getRegionName()
	local name = self.m_mining_region_config[self.m_version][self.m_region_id]["name"]
	return name
end

function M:getRobprofit()
	local profit = self.m_mining_setting_config.profit or 1
	return profit
end

function M:getRobotProduce()
	local produce_tab = self.m_mining_location_config[self.m_region_id][self.m_location_id]["ai_res"]
	return produce_tab
end

--新占地块保护时间
function M:isProtectedTime()
	local protect_str = ""
	local protect_time = self.m_mining_location_config[self.m_region_id][self.m_location_id]["protect"] or 0
	if self:getRewardReceiveTime() > 0 and self:getRewardReceiveTime() < protect_time * 60 then
		local time_str = GameUtil:formatTimeBySecond(protect_time * 60 - self:getRewardReceiveTime(), 999)
		protect_str = Language:getTextByKey("hunt_treasure_str_060", time_str)
	end
	return protect_str
end

function M:getOccupyTime()
	local total_time = 0
	if self:getDataByKey("occupy_time") and self:getDataByKey("occupy_time") ~= 0 then
		total_time = UserDataManager:getServerTime() - self:getDataByKey("occupy_time")
	end
	local max_time = self.m_mining_setting_config.time
	local vip = UserDataManager.user_data:getUserStatusDataByKey("vip")
	local vip_cfg = ConfigManager:getCfgByName("vip")
	local vip_time = 0
	if vip_cfg[tonumber(vip)].mining_time and vip_cfg[tonumber(vip)].mining_time then
		vip_time = vip_cfg[tonumber(vip)].mining_time
	end
	max_time = max_time + vip_time
	total_time = math.min(max_time  * 60 * 60, total_time)
	return total_time
end

function M:getRewardReceiveTime()
	local total_time = 0
	if self:getDataByKey("receive_ts") and self:getDataByKey("receive_ts") ~= 0 then
		total_time = UserDataManager:getServerTime() - self:getDataByKey("receive_ts")
	end
	local max_time = self.m_mining_setting_config.time
	local vip = UserDataManager.user_data:getUserStatusDataByKey("vip")
	local vip_cfg = ConfigManager:getCfgByName("vip")
	local vip_time = 0
	if vip_cfg[tonumber(vip)].mining_time and vip_cfg[tonumber(vip)].mining_time then
		vip_time = vip_cfg[tonumber(vip)].mining_time
	end
	max_time = max_time + vip_time
	total_time = math.min(max_time  * 60 * 60, total_time)
	return total_time
end

--  新占地块保护结束时间
function M:getOccupyOverTimeTips()
	local total_time = 0
	if self:getDataByKey("occupy_time") and self:getDataByKey("occupy_time") ~= 0 then
		total_time = UserDataManager:getServerTime() - self:getDataByKey("occupy_time")
	end
	local protect_str = ""
	local protect_time = self.m_mining_location_config[self.m_region_id][self.m_location_id]["protect"] or 0
	if total_time > 0 and total_time < protect_time * 60 then
		local time_str = GameUtil:formatTimeBySecond(protect_time * 60 - total_time, 999)
		protect_str = Language:getTextByKey("hunt_treasure_str_060", time_str)
	end
	return protect_str
end

function M:isInAtkCd()--撤离时间过短不让打
	local recall_ts = 0
	if self.m_data and self.m_data.recall_ts then
		recall_ts = self.m_data.recall_ts
	end
	local cd_time = UserDataManager:getServerTime() - recall_ts
	local atk_cd = ConfigManager:getCommonValueById(626,60)--进攻惩罚时间
	if cd_time < atk_cd * 60 then
		return true, atk_cd * 60 - cd_time
	end
	return false
end

function M:getHeroShowData()
	local show_data = {}
	local team = self:getDataByKey("team")
	local team_heros_data = {}
	if team and _G.next(team) then
		for index = 1,5 do
			local hero_id = team[index] or ""
			local hero_data, hero_cfg = nil, nil
			if self:isSelfMine() then
				hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(hero_id)
			else
				hero_data = self.m_data.heros[hero_id]
				hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data and hero_data.id or "")
			end
			local data = nil
			if hero_data and hero_cfg then
				data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
				data.quality = hero_data.evo
				data.card_id = hero_id
				data.hero_data = hero_data
			end
			show_data[index] = data or {}
		end
	end
	return show_data
end

local __effect_name = { "Gold","Fire", "Wood", "Water"}
function M:getMineEffectName()
	local drop_quality = self:getAreaDropQualityByAreaIndex()
	local race_tab = self.m_mining_region_config[self.m_version][self.m_region_id].race
	local race_id = race_tab[1]
	local effect_name = ""
	if drop_quality > 1 then
		effect_name = "Fx_Kuangdong0" .. drop_quality .. "_" .. __effect_name[race_id] .. "01"
	end
	return effect_name
end

function M:getMineStatus()
	if self:isSelfMine() then
		self.m_status = self.m_status_code.IS_SELF
	elseif not(self:isMaxOwner()) and self:canRobTimes()>0 then
		self.m_status = self.m_status_code.CAN_OWNER
	elseif self:isMaxPlunder() and self:isCanBuyPlunder() then
		self.m_status = self.m_status_code.NEED_BUY
	elseif  self:canRobTimes()<=0 then
		self.m_status = self.m_status_code.NO_TIMES
	else
		self.m_status = self.m_status_code.CAN_ROB
	end
end

function M:getDropReward()
	local normal_gifts = {}
	local drop_gifts = {}
	if self.m_data.normal_gifts  then
		normal_gifts = self.m_data.normal_gifts
	end
	if self.m_data.drop_gifts then
		drop_gifts = self.m_data.drop_gifts
	end
	if next(drop_gifts) then
		for i = 1, #drop_gifts do
			table.insert(normal_gifts, 1, drop_gifts[i])
		end
	end
	return normal_gifts
end

return M
