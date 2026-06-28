local M = class("QiXiCoupleModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_open_id = 374
	local activityInfo = UserDataManager:getActivesRechargeDataByOpenId(self.m_open_id) or {}
	self.m_version = activityInfo.version or 1
	local params = {}
	params.open_id = self.m_open_id
	params.vsn = self.m_version
	self:getData("war_order_common_war_order_index", params)
end

function M:onEnter()
	self.m_gift_data = {}
	self.m_day = 0
	self.is_tokens = self.m_params.is_token
	if self.m_params.is_token == true then --代金券进入
		self.is_tokens = true
	else
		self.is_tokens = false
	end
	self:initData()
end

--数据初始化
function M:initData()
	self:initCurrentDay()
	self:initGiftData()
	self:initWarOrderData()
end

----数据初始化
function M:initGiftData()
	self.m_gift_data = {}
	local gift_data_temp = {}
	local tongyong_warrior_reward = ConfigManager:getCfgByName("tongyong_warrior_reward")
	if tongyong_warrior_reward[self.m_open_id] then
		if self.m_data.war_order and self.m_data.war_order.cur_version then
			gift_data_temp = tongyong_warrior_reward[self.m_open_id][self.m_data.war_order.cur_version] or {}
		end
	end
	for k, v in pairs(gift_data_temp) do
		table.insert(self.m_gift_data, {id = v.condition, cfg = v})
	end
	for k, v in pairs(self.m_gift_data) do
		v.status_free, v.status_fee = self:getWrriorRewardStatus(v.id)
	end
	table.sort(self.m_gift_data, function(data1, data2)
		return data1.id < data2.id
	end)
end

function M:initWarOrderData()
	local war_order = ConfigManager:getCfgByName("war_order")
	self.m_war_order_data = war_order[self.m_open_id]
end

function M:initCurrentDay()
	local day_time = 0
	local activity_info = UserDataManager:getActivesRechargeDataByOpenId(self.m_open_id)
	if activity_info then
		local server_time = UserDataManager:getServerTime()
		local start_time = activity_info.start_ts
		day_time = server_time - start_time
	end
	self.m_day = math.floor(day_time / (60 * 60 * 24)) + 1
end

--数据更新
function M:updateData(data)
	table.merge(self.m_data, data)
	self:initData()
end

function M:updateGiftData(data)
	table.merge(self.m_data.gifts_data, data.gifts_data)
	self:initGiftData()
end

--数据获取
function M:getOpenID()
	return self.m_open_id
end

function M:getTokenFlag()
	return self.is_tokens
end

function M:getVersion()
	return self.m_version
end

function M:getMainData()
	return self.m_data
end

function M:getGiftData()
	return self.m_gift_data
end

function M:getWarOrderData()
	return self.m_war_order_data
end

function M:getWrriorRewardStatus(id)
	local status_free = 0
	local status_fee = 0
	if self.m_data.war_order then
		if table.keyof(self.m_data.war_order.free_received, tonumber(id)) then
			status_free = 2
		end
		if table.keyof(self.m_data.war_order.pay_received, tonumber(id)) then
			status_fee = 2
		end
		if status_free == 0 or status_fee == 0 then
			if self.m_gift_data then
				local gift_data_item = self.m_gift_data[id] or {}
				local cfg = gift_data_item.cfg
				if cfg then
					if status_free == 0 and self.m_day >= cfg.condition then
						status_free = 1
					end
					if status_fee == 0 then
						local pay_status = self:getwrriorPayStatus()
						if pay_status > 0 and self.m_day >= cfg.condition then
							status_fee = 1
						end
					end
				end
			end
		end
	end
	return status_free, status_fee
end

function M:getwrriorPayStatus()
	if self.m_data.war_order then
		return self.m_data.war_order.pay_status or 0
	else
		return 0
	end
end

function M:getLoginDayCount()
	return self.m_day
end

function M:getActiveData()
	local activity_info = UserDataManager:getActivesDataByOpenId(self.m_open_id)
	if activity_info then
		local active_tab = ConfigManager:getCfgByName("active")
		return active_tab[activity_info.id]
	else
		activity_info = UserDataManager:getActivesRechargeDataByOpenId(self.m_open_id)
		if activity_info then
			local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
			return active_recharge_tab[activity_info.id]
		end
	end
end

----活动剩余时间
function M:getTimeLeft()
	local left_time = 0
	local activity_info = UserDataManager:getActivesRechargeDataByOpenId(self.m_open_id)
	if activity_info then
		local server_time = UserDataManager:getServerTime()
		local end_time = activity_info.end_ts
		left_time = end_time - server_time
	end
	return left_time
end

return M
