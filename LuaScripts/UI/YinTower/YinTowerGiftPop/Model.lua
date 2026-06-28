local M = class("YinTowerGiftPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	--self.m_transfer = "up_to_down"
	self:getData("dark_tower_index")
end

function M:onEnter()
	self:updateDownTimeData()
	self.m_free_gifts = self.m_data.received or {}
	self.m_version = self.m_data.vsn
	self.m_cur_day = self.m_data.day -- 当前是哪天
	self.m_max_layer = self.m_data.floor -- 当前打到的最大层数
	self.m_is_Tokens = self.m_params.is_token
end

function M:updateRewardData(free_gifts)
	self.m_free_gifts = free_gifts
end

function M:getDesByKey(get_key)
	local vsn = self.m_data.vsn or 1
	local yinyang_tower_version = ConfigManager:getCfgByName("yinyang_tower_version") or {}
	if yinyang_tower_version and yinyang_tower_version[vsn] and yinyang_tower_version[vsn][get_key] then
		return yinyang_tower_version[vsn][get_key]
	end
	return nil
end

function M:getEndTs()
	if self.m_activityData and self.m_activityData.end_ts then
		return self.m_activityData.end_ts - UserDataManager:getServerTime()
	end
	return 0
end

function M:updateDownTimeData()
	self.m_activityData = UserDataManager:getActivesDataByOpenId(244)
end

function M:getActStatus()
	if self.m_activityData and self.m_activityData.open_status then
		return self.m_activityData.open_status
	end
	return 0
end

function M:initChoiceToPush()-- 将choice_gits的数据转换成
	local temp_push_data = {}
	local choice_gifts = UserDataManager.m_choice_gifts or {}
	for i, v in pairs(choice_gifts) do
		local cfg_id = i
		local gift_tab = ConfigManager:getCfgByName("limit_gift")
		if open_id == 244 then
			temp_push_data[k] = v.ets
		end
	end
	return temp_push_data
end


function M:getGiftStatus()
	local cur_opencontidion_id = 244
	local temp_push_data = {}
	local choice_gifts = UserDataManager.m_choice_gifts or {}
	local status = false
	for i, v in pairs(choice_gifts) do
		local cfg_id = tonumber(i)
		local gift_tab = ConfigManager:getCfgByName("limit_gift")
		if gift_tab[cfg_id] then
			local limit_cfg = gift_tab[cfg_id]
			if limit_cfg["open_id"] and limit_cfg["open_id"][1] then
				local open_id = limit_cfg["open_id"][1]
				local vsn = limit_cfg["open_id"][2]
				local show_type = limit_cfg["show_type"]
				if open_id == cur_opencontidion_id and vsn == self.m_version and (show_type == 1 or show_type == 2) then
					temp_push_data[i] = v.ets
					status = true
				end
			end
		end
	end
	return status, temp_push_data
end

function M:checkFirstPop(id, end_ts)
	local first_login = UserDataManager.local_data:getUserDataByKey("choice_gift_"..id.."_"..end_ts, 0)
	return first_login == 0
end

function M:getGiftsData()
	local cur_season = UserDataManager:getCurSeason() -- 当前赛季
	local tower_reward_active_cfg = ConfigManager:getCfgByName("yinyang_tower_gift")
	local version_cfg = tower_reward_active_cfg[self.m_version]
	local tower_reward_cfg = {}
	if version_cfg then
		local season_cfg = version_cfg--[cur_season]
		--if season_cfg == nil then
		--	for i = cur_season, 0, -1 do
		--		season_cfg = version_cfg[i] -- 找不到当前赛季的配置就找之前赛季的直到找到为止
		--		if season_cfg ~= nil then
		--			break
		--		end
		--	end
		--end
		if season_cfg then
			for k, v in pairs(season_cfg) do
				v.id = k
				local state = self:getCanGetRewardDay(v)
				v.free_received = state
				table.insert(tower_reward_cfg,v)
			end
		else
			Logger.logError(string.format("tower_reward_active 表缺少season == %s 的配置文件", tostring(cur_season)))
		end
	else
		Logger.logError(string.format("tower_reward_active 表缺少version == %s 的配置文件", tostring(self.m_version)))
	end
	
	local function sortFun(data1, data2)
		if data1.free_received == data2.free_received then
			if data1.day == data2.day then
				return data1.id < data2.id
			else
				return data1.day < data2.day
			end
		else
			return data1.free_received < data2.free_received
		end
	end
	table.sort(tower_reward_cfg,sortFun)
	return tower_reward_cfg
end

--- 定位到能领到奖励的天数
function M:getCanGetRewardDay(reward_data)
	local state = 1 -- 0 可领取 1 不可领取 2 已领取
	local day = 1
	if self.m_cur_day >= reward_data.day and self.m_max_layer >= reward_data.num  then
		if table.indexof(self.m_free_gifts, reward_data.id) then
			state = 2
		else
			state = 0
			day = reward_data.day
		end
	end
	return state, day
end


return M
