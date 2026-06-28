local M = class("SmashEggBuyPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self.m_is_token = self.m_params.is_token or false
	self.m_openId = self.m_params.m_openId or 227
	self.m_version = self.m_params.m_version
	self.cur_page = "1"
	self.cur_place = "1"
	local param = {}
	param.open_id = self.m_openId
	param.vsn = self.m_version
	self:getData("active_common_gift_index", param)
end

function M:onEnter()
	self.m_data = self.m_params.data or self.m_data
	self.m_callback = self.m_params.callback
	self:initData(self.m_data)
end

function M:initData(data)
	table.merge(self.m_data, data or {})
	if data then
		self.m_gifts_data = data.gifts_data or {}
		self.m_day = data.config_day[self.cur_page] or 1
	end
	self:initGiftBagData()
end

function M:initGiftBagData()
	local tongyong_gift = ConfigManager:getCfgByName("tongyong_gift")
	local version_tab = tongyong_gift[self.m_openId][self.m_version][tonumber(self.cur_page)] or {}
	local dayXlsxData = version_tab[self.m_day] or {}
	self.m_gift_bag_data = {}
	
	local buyPagData = self.m_data.gifts_data[self.cur_page] or {}
	for k, v in pairs(dayXlsxData) do
		local buyItemData = buyPagData[tostring(k)] or {}
		local itemData = v[buyItemData.cid] or {}
		local buy_times = buyItemData.times or 0
		local status = 0
		local time_limit = itemData.time_limit or 0
		if time_limit > 0 and buy_times >= time_limit then -- 已售完
			status = -1
		end
		table.insert(self.m_gift_bag_data, {id = k, cfg = itemData, buy_times = buy_times, status = status})
	end
	table.sort(self.m_gift_bag_data, function(data1, data2)
		if data1.status == data2.status then
			return data1.id < data2.id
		else
			return data1.status > data2.status
		end
	end)
end

function M:getGiftBagData()
	return self.m_gift_bag_data or {}
end

return M
