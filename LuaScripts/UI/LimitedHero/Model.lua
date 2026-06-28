local M = class("LimitedHeroModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self:getData("limit_hero_index")
end

function M:onEnter()
	self.m_open_id = 384
	self.m_activity_info = UserDataManager:getActivesRechargeDataByOpenId(self.m_open_id) or {}
	self.m_version = self.m_activity_info.version or 1
	self.m_is_token = self.m_params.is_token or false
	self.m_select_tag_index = 1 --页签
	self.m_select_day_index = 1 --天数
	self.m_main_data = {}
	self:updateMainData()
end

function M:getVersion()
	return self.m_version
end

function M:getTokenFlag()
	return self.m_is_token
end

function M:updateMainData(data)
	table.merge(self.m_data, data)
	self.m_main_data = {}

	local limit_hero_cfg = ConfigManager:getCfgByName("limit_hero")
	local limit_hero_cfg_version =  limit_hero_cfg[self.m_version] or {}
	for k, v in pairs(limit_hero_cfg_version) do
		for kk, vv in pairs(self.m_data.limit_hero or {}) do
			if kk == tostring(v.charge_id) then
				table.insert(self.m_main_data, {cfg = v, status_data = vv})
			end
		end
	end
	
	table.sort(self.m_main_data, function(a, b) return a.cfg.price < b.cfg.price end)
end

function M:getMainData(tag_index, day_index)
	if tag_index then
		if day_index then
			if self.m_main_data[tag_index] then
				return self.m_main_data[tag_index][day_index]
			end
		end
		return self.m_main_data[tag_index]
	end
	return self.m_main_data
end

function M:setSelectedTagIndex(tag_index)
	self.m_select_tag_index = tag_index
end

function M:getSelectedTagIndex()
	return self.m_select_tag_index
end

function M:setSelectedDayIndex(day_index)
	self.m_select_day_index = day_index
end

function M:getSelectedDayIndex()
	return self.m_select_day_index
end

--是否处于展示期
function M:isInShowTime()
	local activity_info = self.m_activity_info
	if activity_info and activity_info.show_start_ts then
		local server_time = UserDataManager:getServerTime()
		if server_time >= activity_info.show_start_ts and server_time <= activity_info.end_ts then
			return true
		end
	end
	return false
end

function M:getEndTs()
	local active_data = self.m_activity_info
	if active_data and active_data.end_ts then
		return active_data.end_ts - UserDataManager:getServerTime()
	end
	return 0
end

return M