local M = class("GuJianQiTanDateModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_calendar_id = self.m_params.main_data.calendar_id or 0
	self.m_version = self.m_params.main_data.version or 0
	
	local unit_min = 60
	local unit_hour = unit_min * 60
	local unit_day = unit_hour * 24
	
	local activity_data = UserDataManager:getActivesDataByOpenId(280)
	local start_time_activity = activity_data.start_ts
	local server_time_cur = UserDataManager:getServerTime()
	
	local sword_double_tab = ConfigManager:getCfgByName("sword_double")
	local sword_double_version_tab = sword_double_tab[self.m_version] or {}
	local tab_key = table.keys(sword_double_version_tab)
	table.sort(tab_key)
	local day_total = 0
	local list_count = 0
	for i, v in ipairs(tab_key) do
		local cfg_id = tonumber(v)
		local cur_cfg = sword_double_version_tab[cfg_id] or {}
		
		list_count = list_count + cur_cfg.hold_time
		if cfg_id <= self.m_calendar_id then
			day_total = day_total + cur_cfg.hold_time
		end
	end
	
	local server_day = (server_time_cur - start_time_activity) / unit_day
	local server_day_left = server_day - math.floor(server_day / list_count) * list_count
	
	local remain_time = (day_total - server_day_left) * unit_day
	self.m_day_left = 0
	self.m_hour_left = 0
	self.m_min_left = 0
	self.m_sec_left = 0
	self.m_day_left = math.floor(remain_time / unit_day)
	if self.m_day_left <= 0 then
		self.m_hour_left = math.floor(remain_time / unit_hour)
		if self.m_hour_left <= 0 then
			self.m_hour_left = 1
			--self.m_min_left = math.floor(remain_time / unit_min)
			--if self.m_min_left <= 0 then
			--	self.m_sec_left = remain_time
			--end
		end
	end
end

function M:getDateData()
	local data = {}
	local sword_double_tab = ConfigManager:getCfgByName("sword_double") or {}
	local sword_double_version_tab = sword_double_tab[self.m_version] or {}
	local sword_double_item = sword_double_version_tab[self.m_calendar_id] or {}
	data.title = sword_double_item.double_des1
	data.content = sword_double_item.double_des2
	data.reward = string.format(sword_double_item.name, tostring(sword_double_item.times))
	if self.m_day_left > 0 then
		data.time_left = Language:getTextByKey("gu_jian_qi_tan_str_010", self.m_day_left)
	elseif self.m_hour_left > 0 then
		data.time_left = Language:getTextByKey("gu_jian_qi_tan_str_035", self.m_hour_left)
	elseif self.m_min_left > 0 then
		data.time_left = Language:getTextByKey("gu_jian_qi_tan_str_036", self.m_min_left)
	else
		data.time_left = Language:getTextByKey("gu_jian_qi_tan_str_037", self.m_sec_left)
	end
	
	return data
end

return M
