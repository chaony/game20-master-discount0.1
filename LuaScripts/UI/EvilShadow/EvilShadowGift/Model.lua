local M = class("EvilShadowGiftModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_version = self.m_params.version or 0
	self.m_gift_data = self.m_params.gift_data or {}
	self.m_current_day = self.m_params.current_day or 0
	self.m_end_ts = self.m_params.end_ts or 0
	self.m_show_data = {}
	if self.m_params.is_token == true then --代金券进入
		self.is_tokens = true
	else
		self.is_tokens = false
	end
	self:updateShowData()
end

function M:getCurrentDay()
	return self.m_current_day
end

function M:getVersion()
	return self.m_version
end

function M:canGiftBagBeBuy(gift_id)
	for _, gift_item in pairs(self.m_gift_data) do
		if gift_item.gift_id == gift_id then
			if gift_item.history then
				return gift_item.time_limit < #gift_item.history
			end
		end
	end
	return true
end

function M:updateGiftDataFree(data)
	self.m_gift_data = data or {}
	self:updateShowData()
end

function M:updateGiftData(callback)
	local function netCallback(response)
		self.m_gift_data = response.gift_data
		self:updateShowData()
		if callback then
			callback()
		end
	end
	self:getNetData("evil_shadow_index", nil, netCallback)
end

function M:updateShowData()
	self.m_show_data = {}
	local evil_shadow_gift_tab = ConfigManager:getCfgByName("evil_shadow_gift")[self.m_version] or {}
	for _, index_item in pairs(self.m_gift_data) do
		for data_index, data_item in pairs(evil_shadow_gift_tab) do
			if index_item.gift_id == data_index then
				local temp_item = {}
				temp_item = table.copy(data_item)
				table.merge(temp_item, index_item)
				--table.merge(temp_item, data_item)
				table.insert(self.m_show_data, temp_item)
			end
		end
	end
	table.sort(self.m_show_data, function(item1, item2) return item1.place < item2.place end)
end

function M:getShowData(index)
	return self.m_show_data[index] or {}
end

return M
