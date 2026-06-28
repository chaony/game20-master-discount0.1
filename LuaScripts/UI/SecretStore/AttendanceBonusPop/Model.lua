local M = class("AttendanceBonusModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("mystery_shop_index")
end

function M:onEnter()
	self:initData()
	local cfg = ConfigManager:getCfgByName("mystery_reward")
	local timetable = TimeUtil.gmTime(UserDataManager:getServerTime())
	local cfg_item = next(cfg[timetable.month])
	if cfg_item then
		self.reward_data = cfg[timetable.month] 
	else
		Logger.log("检查mystery_reward的配置")
	end
end

function M:initData(response)
	if response then
		self.m_data = response
	end
	self.m_record_total_days = self.m_data.mystery_shop_gift.record_total_days and self.m_data.mystery_shop_gift.record_total_days or 0
	self.m_record_days_list = self.m_data.mystery_shop_gift.record_days_list and self.m_data.mystery_shop_gift.record_days_list or {}
end

function M:getRewardState(day)
	local get = false
	local gift_id_list = self.m_record_days_list
	if gift_id_list then
		for k ,v in ipairs(gift_id_list) do
			if v == day then
				get = true
				break
			end
		end
	end
	return get
end

function M:sortState(index)
	local get = false
	local gift_id_list = self.m_record_days_list
	if gift_id_list then
		for k ,v in ipairs(gift_id_list) do
			if v == index then
				get = true
				break
			end
		end
	end
	return get
end

function M:getState(day)
	local get = false
	local level = day
	self.m_record_total_days = self.m_data.mystery_shop_gift.record_total_days and self.m_data.mystery_shop_gift.record_total_days or 0
	get =  self.m_record_total_days >= level
	return get
end

return M
