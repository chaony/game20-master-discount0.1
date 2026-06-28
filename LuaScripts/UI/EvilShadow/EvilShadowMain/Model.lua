local M = class("EvilShadowMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("evil_shadow_index")
end

function M:onEnter()
	self.m_activity_data = self.m_data.actives or {}
	self.m_activity_charge_data = self.m_data.charge_actives or {}
	self.m_exchange_done_data = self.m_data.exchange_done or {}
	self.m_current_day = 0
	self.m_activity_openID_EvilShadow = 247
	self.m_activity_openID_Date = 249
	self.m_activity_openID_Gift = 248
	self.m_activity_openID_Battle = 250
	self.m_activity_openID_name_cache = {
		[self.m_activity_openID_EvilShadow] = Language:getTextByKey("evil_shadow_str_001"),
		[self.m_activity_openID_Date] = Language:getTextByKey("evil_shadow_str_002"),
		[self.m_activity_openID_Gift] = Language:getTextByKey("evil_shadow_str_003"),
		[self.m_activity_openID_Battle] = Language:getTextByKey("evil_shadow_str_004"),
	}
	self:setCurrentDay()
end

--通用
function M:updateData(data)
	self.m_data = data
	self.m_activity_data = self.m_data.actives or {}
	self.m_activity_charge_data = self.m_data.charge_actives or {}
end

function M:setCurrentDay()
	local server_time = UserDataManager:getServerTime()
	local start_time = server_time
	local activity_evil_shadow_data = self:getActivityData(self.m_activity_openID_EvilShadow)
	if activity_evil_shadow_data.start_ts then
		start_time = activity_evil_shadow_data.start_ts
	end
	local current_day = math.floor((server_time - start_time) / (60 * 60 * 24)) + 1
	if current_day < 1 then
		current_day = 1
	elseif current_day > 7 then
		current_day = 7
	end
	self.m_current_day = current_day
end

function M:getCurrentDay()
	return self.m_current_day
end

function M:getVersion(open_id)
	open_id = open_id or self.m_activity_openID_EvilShadow
	if open_id == self.m_activity_openID_EvilShadow then
		return self.m_data.version or 0
	end
	local activity_data_item = self:getActivityData(open_id)
	if activity_data_item then
		return activity_data_item.version
	end
	return 0
end

function M:getScore()
	if self.m_data then
		return self.m_data.score or 0
	end
	return 0
end

function M:getScoreDone()
	if self.m_data then
		return self.m_data.score_done
	end
	return 0
end

function M:getActivityData(open_id)
	local activity_data = table.shallow_copy(self.m_activity_data)
	for _, item in ipairs(self.m_activity_charge_data) do
		table.insert(activity_data, item)	
	end
	for _, item in ipairs(activity_data) do
		if item.open_id == open_id then
			return item
		end
	end
	return {}
end

function M:getActivityName(open_id)
	return self.activity_openID_name_cache[open_id]
end

--月影传说
function M:getActivityOpenStatus(open_id)
	local activity_item = self:getActivityData(open_id)
	if activity_item then
		return activity_item.open_status, self:getLockTip(activity_item)
	end
	return 0, "Activity ID false"
end

function M:getLockTip(activity_data)
	local start_date = TimeUtil.gmTime(activity_data.start_ts or 0)
	local end_date = TimeUtil.gmTime(activity_data.end_ts or 0)
	--local star_date_str = start_date.year .. "年" .. start_date.month .. "月" .. start_date.day .. "日"
	--local end_date_str = end_date.year .. "年" .. end_date.month .. "月" .. end_date.day .. "日"
	local star_date_str = start_date.month .. "月" .. start_date.day .. "日"
	local end_date_str = end_date.month .. "月" .. end_date.day .. "日"
	return Language:getTextByKey("evil_shadow_str_005", star_date_str, end_date_str)
end

--月影之约
function M:getTaskDetailData()
	if self.m_data then
		return self.m_data.quests or {}
	end
end

--月影礼包
function M:getGiftData()
	if self.m_data then
		return self.m_data.gift_data or {}
	end
	return {}
end

--月影试炼
function M:getHeirloom()
	if self.m_data then
		return self.m_data.heirlooms or {}
	end
	return {}
end

function M:getEnemy()
	if self.m_data then
		return self.m_data.enemys or {}
	end
	return {}
end

function M:getMaxDamage()
	if self.m_data then
		return self.m_data.max_damage or 0
	end
	return 0
end

function M:hasEvilShadowDateRedPoint()
	--是否有没领取的任务奖励
	local task_detail_tab = ConfigManager:getCfgByName("evil_shadow_quest") or {}
	local task_detail_data = task_detail_tab[self:getVersion(self.m_activity_openID_Date)] or {}
	for key_cfg, item_cfg in pairs(self.m_data.quests) do
		for key_detail, item_detail in pairs(task_detail_data) do
			if tonumber(key_cfg) == key_detail and  item_detail.day <= self.m_current_day and item_cfg.status == 1 then
				return true
			end
		end
	end
	--是否有没领取的宝箱
	local evil_shadow_reward = ConfigManager:getCfgByName("evil_shadow_reward")[self:getVersion(self.m_activity_openID_Date)] or {}
	local score_current = self.m_data.score or 0
	for k,v in pairs(evil_shadow_reward) do
		local score = v.score or 0
		if table.keyof(self.m_data.score_done, k) == nil and score_current >= score then
			return true
		end
	end
	return false
end

function M:hasEvilShadowGiftRedPoint()
	local evil_shadow_gift_tab = ConfigManager:getCfgByName("evil_shadow_gift")[self:getVersion(self.m_activity_openID_Gift)] or {}
	for _, index_item in pairs(self.m_data.gift_data or {}) do
		for data_index, data_item in pairs(evil_shadow_gift_tab) do
			if index_item.gift_id == data_index then
				if index_item.times < data_item.time_limit then
					return true
				end
			end
		end
	end
	return false
end

--兑换
function M:getExchangeDoneData()
	return self.m_data.exchange_done or {}
end

return M
