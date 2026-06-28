local M = class("QiXiShoppingModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_open_id = 375
	self.m_is_token = self.m_params.is_token or false
	self.m_version = self.m_params.version or 1
	local param = {}
	param.open_id = self.m_open_id
	param.vsn = self.m_version
	self:getData("active_common_gift_index", param)
end

function M:onEnter()
	self.m_gift_data = {}
	self.m_paper_id = 1
	self.m_day = 1
	self:initGiftData()
end

function M:getOpenID()
	return self.m_open_id
end

function M:getVersion()
	return self.m_version
end

function M:getPaperID()
	return self.m_paper_id
end

function M:getTokenFlag()
	return self.m_is_token
end

function M:updateGiftData(data)
	table.merge(self.m_data, data)
	self:initGiftData()
end

function M:updateParamsData(data)
	table.merge(self.m_params, data)
end

function M:getTimeLimit()
	local state = 1
		local activity_info = UserDataManager:getActivesDataByOpenId(self.m_open_id)
		if not activity_info then
			activity_info = UserDataManager:getActivesRechargeDataByOpenId(self.m_open_id)
		end
		if activity_info then
			local server_time = UserDataManager:getServerTime()
			if server_time >= activity_info.start_ts and server_time < activity_info.show_start_ts then
				state = 2
			end
		end
	return state
end

function M:initGiftData()
	self.m_gift_data = {}
	local gift_tab = ConfigManager:getCfgByName("tongyong_gift")[self.m_open_id] or {}
	local gift_version_tab = gift_tab[self.m_version] or {}
	local gift_data = self.m_data.gifts_data or {}
	local status
	local day_config = self.m_data.config_day or {}
	local day_index = 0
	for paper_index, v in pairs(gift_data) do
		paper_index = tonumber(paper_index)
		day_index = day_config[tostring(paper_index)]
		for place_index, vv in pairs(v) do
			place_index = tonumber(place_index)
			local cfg
			if gift_version_tab and gift_version_tab[paper_index] and gift_version_tab[paper_index][day_index] and gift_version_tab[paper_index][day_index][place_index] then
				cfg = gift_version_tab[paper_index][day_index][place_index][vv.cid]
			end
			if cfg then
				status = 1 --可购买
				if vv.times >= cfg.time_limit and cfg.time_limit ~= 0 then
					status = 2 --已超过限购，不可购买
				end
				if self.m_gift_data[paper_index] == nil then
					self.m_gift_data[paper_index] = {}
				end
				table.insert(self.m_gift_data[paper_index], {cfg = cfg, paper_index = paper_index, place_index = place_index, status = status, times = vv.times})
			end
		end
	end
end

function M:getInfo()
	return self.m_params
end

function M:getGiftData(place_index)
	local gift_data_item = {}
	for k, v in pairs(self.m_gift_data[self.m_paper_id]) do
		if place_index == v.place_index then
			gift_data_item = v
			if v.status == 1 then
				break
			end
		end
	end
	return gift_data_item
end

function M:getReward(btn_name)
	local index = tonumber(string.sub(btn_name, -1))
	local collection_tab = ConfigManager:getCfgByName("collection")
	local collection_version_tab = collection_tab[self.m_version] or {}
	local item = collection_version_tab[index] or {}
	return item.card_id or {}
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


return M
