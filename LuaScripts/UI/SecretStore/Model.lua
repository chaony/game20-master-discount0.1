local M = class("SecretStoreModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_data = self.m_params
	self:getData()
	--self:getData("mystery_shop_index")
end

function M:onEnter()
	self:initData()
	self:updateTime()
	local cur_season = UserDataManager:getCurSeason()
	self.giftbag_data = {}
	local cfg_data = ConfigManager:getCfgByName("mystery_shop")
	local cfg_item = next(cfg_data)
	if not cfg_item then
		Logger.log("检查mystery_shop的配置")
	else
		self.current_weak = cfg_data[self.timetable.wday]
		for i=1,#self.current_weak do
			local giftbag = self.current_weak[i]
			if giftbag.type == 1 then   -- 充值类型
				if giftbag.season1 == -1 and cur_season >= giftbag.season then   -->赛季限制
					table.insert(self.giftbag_data,giftbag)
				elseif cur_season == giftbag.season1 then --符合当前赛季
					table.insert(self.giftbag_data,giftbag)
				end
			else
				self.m_pack_data = giftbag
			end
		end
	end
end

function M:initData()
	self.m_discount = self.m_data.mystery_shop_gift.discount
	self.m_rebate = self.m_data.mystery_shop_gift.rebate
	self.m_record_total_days = self.m_data.mystery_shop_gift.record_total_days and self.m_data.mystery_shop_gift.record_total_days or 0
	self.m_gift2_status = self.m_data.mystery_shop_gift.gift2_status
	self.m_once_pay = self.m_data.mystery_shop_gift.once_pay == 0 and true or false
end

function M:updateData(response)
	table.merge(self.m_data,response)
	self:initData()
end

--判断是否已经购买
function M:getGiftBagState(charge_id)
	local get = false
	local gift_id_list = self.m_data.mystery_shop_gift.gift_id_list
	if gift_id_list then
		for k ,v in ipairs(gift_id_list) do
			if self.current_weak[v].charge_id == charge_id then
				get = true
				break
			end
		end			
	end
	return get
end

function M:getRewardState()
	local get = false
	self.m_record_total_days = self.m_data.mystery_shop_gift.record_total_days and self.m_data.mystery_shop_gift.record_total_days or 0
	self.m_record_days_list = self.m_data.mystery_shop_gift.record_days_list and self.m_data.mystery_shop_gift.record_days_list or {}
	local result = self.m_record_total_days % 7
	local nums = table.nums(self.m_record_days_list)
	get = result > nums
	return get
end

function M:getEndTs()
	local server_time = UserDataManager:getServerTime()
	local next_fresh_time = TimeUtil.getIntTimestamp(server_time)
	
	local end_times = next_fresh_time + 24 * 3600
	return end_times
end

function M:getState()
	local is_red = false
	local cfg = ConfigManager:getCfgByName("mystery_reward")
	local current_month = cfg[self.timetable.month]
	self.m_record_total_days = self.m_data.mystery_shop_gift.record_total_days and self.m_data.mystery_shop_gift.record_total_days or 0
	self.m_record_days_list = self.m_data.mystery_shop_gift.record_days_list and self.m_data.mystery_shop_gift.record_days_list or {}
	for k,v in pairs(current_month) do
		if self.m_record_total_days >= k then
			local is_cur_day_get = self:isCurDayGet(k)
			if not is_cur_day_get then
				return true
			end
		end
		--get =  self.m_record_total_days >= level	
	end
	
	return false
end

function M:isCurDayGet(day)
	for k1,v1 in ipairs(self.m_record_days_list) do
		if v1 == day then--已经领取
			return true
		end
	end
	return false
end

function M:updateTime()
	local times = UserDataManager:getServerTime()
	self.timetable = TimeUtil.gmTime(times)
	if self.timetable.wday == 0 then
		self.timetable.wday = 7
	end
end

return M
