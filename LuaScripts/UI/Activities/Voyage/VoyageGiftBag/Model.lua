local M = class("VoyageGiftBagModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	if self.m_params.data == nil then
		self:getData("high_gacha_voyage_index")
	else
		self:getData()
	end
end

function M:onEnter()
	self.m_data = self.m_params.data or self.m_data
	self.m_is_token = self.m_params.is_token or false
	self:initData()
end

function M:initData(data)
	table.merge(self.m_data, data or {})
	self:initGiftBagData()
end

function M:initGiftBagData()
	local ship_gift_cfg = ConfigManager:getCfgByName("ship_gift")
	local voyage_version = self.m_data.voyage_version or 0
	local voyage_buy_times = self.m_data.voyage_buy_times or {}
	self.m_gift_bag_data = {}
	local ship_gift_cfg_v = ship_gift_cfg[voyage_version] or {}
	for k, v in pairs(ship_gift_cfg_v) do
		local buy_times = voyage_buy_times[tostring(k)] or 0
		local status = 0
		local time_limit = v.time_limit or 0
		if time_limit > 0 and buy_times >= time_limit then -- 已售完
			status = -1
		end
		table.insert(self.m_gift_bag_data, {id = k, cfg = v, buy_times = buy_times, status = status})
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
