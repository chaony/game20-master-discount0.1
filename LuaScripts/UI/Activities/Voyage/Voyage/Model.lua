local M = class("VoyageModel", LikeOO.OODataBase)

local __SELECT_MAX_COUNT = 10

function M:onCreate()
	M.super.onCreate(self)
	self:getData("high_gacha_voyage_index")
end

function M:onEnter()
	self.m_gacha_id = 8
	self.m_can_start = true
	self:initData()
	self.m_chase_count_flag = UserDataManager.local_data:getUserDataByKey("voyage_chase_count_flag", false)
	self.m_skip_anim_flag = UserDataManager.local_data:getUserDataByKey("voyage_skip_anim_flag", false)
	self.m_chase_count = self.m_chase_count_flag and __SELECT_MAX_COUNT or 1
	self.m_show_ten_count = __SELECT_MAX_COUNT
	self:changeChaseCount(true)
end

--- 网络数据回调
function M:netData(data, tag)
	self:initData(data)
end

function M:initData(data)
	table.merge(self.m_data, data or {})
	self:initBoxRewardData()
end

function M:getChaseCount()
	return self.m_chase_count or 1
end

function M:changeChaseCount(refresh_flag)
	if not refresh_flag then
		self.m_chase_count_flag = not self.m_chase_count_flag
		UserDataManager.local_data:setUserDataByKey("voyage_chase_count_flag", self.m_chase_count_flag)
	end
	local cost = self:getChaseCostByTimes(1)
	if #cost > 0 then
		local data = RewardUtil:getProcessRewardData(cost[1])
		if data.data_num > 0 then
			self.m_show_ten_count = math.min(math.floor(data.user_num/data.data_num), __SELECT_MAX_COUNT)
		end
	end
	self.m_show_ten_count = self.m_show_ten_count > 0 and self.m_show_ten_count or __SELECT_MAX_COUNT
	if self.m_chase_count_flag then
		self.m_chase_count = self.m_show_ten_count
	else
		self.m_chase_count = 1
	end
end

function M:changeSkipAnimFlag()
	self.m_skip_anim_flag = not self.m_skip_anim_flag
	UserDataManager.local_data:setUserDataByKey("voyage_skip_anim_flag", self.m_skip_anim_flag)
end

function M:getShowTenCount()
	return self.m_show_ten_count or __SELECT_MAX_COUNT
end

function M:isMaxTime()
	local max_times = self:getMaxTimes()
	local cur_times = self.m_data.today_times or 0
	local is_max_time = false
	if max_times == 0 then
	elseif cur_times >= max_times then
		is_max_time = true
	end
	return is_max_time
end

function M:getMaxTimes()
	local max_times = ConfigManager:getCommonValueById(449,0)
	return max_times
end

function M:getChaseCostByTimes(times)
	local gacha_cfg = ConfigManager:getCfgByName("gacha")
	local gacha_cfg_item = gacha_cfg[self.m_gacha_id] or {}
	local cost = times == 10 and gacha_cfg_item.ten_cost or gacha_cfg_item.cost
	return cost or {}
end

function M:getGachaShipRewards(reward_type)
	reward_type = reward_type or 0
	local show_data = {}
	local gacha_ship_cfg = ConfigManager:getCfgByName("gacha_ship")
	local voyage_version = self.m_data.voyage_version or 0
	local gacha_ship_cfg_v = gacha_ship_cfg[voyage_version] or {}
	for k, v in pairs(gacha_ship_cfg_v) do
		for k1,v1 in pairs(v) do
			if v1.hero == reward_type or reward_type == 0 then
				table.insert(show_data, {reward = v1.reward, id = k1, hero = v1.hero, weight = v1.weight, cfg = v1 })
			end
		end
	end
	table.sort(show_data, function(data1,data2)  
		return data1.cfg.id < data2.cfg.id
	end)
	return show_data
end

function M:getBoxRewards()
	return {ConfigManager:getCommonValueById(359, {})}
end

function M:getBoxRewardsProgress()
	local voyage_progress = self.m_data.voyage_progress or 0
	local max_reward_times = ConfigManager:getCommonValueById(358,999)
	return voyage_progress%max_reward_times, max_reward_times
end

function M:initBoxRewardData()
	local gacha_ship_point_reward = ConfigManager:getCfgByName("gacha_ship_point_reward") or {}
	local gacha_ship_point_reward_items = gacha_ship_point_reward[self.m_data.voyage_version] or {}
	local show_data = {}
	local voyage_progress = self.m_data.voyage_progress or 0
	local voyage_box = self.m_data.voyage_box or {} -- 领取过的宝箱id 从0开始
	for k,v in pairs(gacha_ship_point_reward_items) do
		local num = v.point or 0
		local status = 0
		if table.keyof(voyage_box, k) then
			status = -1-- 已领取
		else
			if voyage_progress >= num then
				status = 2 -- 可领取
			else
				status = 0 -- 未完成
			end
		end
		table.insert(show_data, {id = k, cfg = v, status = status})
	end
	table.sort(show_data, function(data1, data2)
		return data1.cfg.point < data2.cfg.point
	end)
	self.m_box_reward_data = show_data
	self.m_voyage_progress = voyage_progress
end

function M:getBoxRewardData()
	return self.m_box_reward_data, self.m_voyage_progress
end

return M
