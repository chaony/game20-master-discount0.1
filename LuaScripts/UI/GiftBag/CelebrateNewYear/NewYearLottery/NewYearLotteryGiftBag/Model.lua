local M = class("NewYearLotteryGiftBagModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_version = self.m_params.data.version
	self.m_draw_gifts = self.m_params.data.draw_gifts
	self.m_is_token = self.m_params.data.is_token or false
	self:initGiftBagData()
end

function M:initData(data)
	table.merge(self.m_draw_gifts, data.draw_gifts)
	self.m_version = data.version
	self:initGiftBagData()
end

function M:initGiftBagData()
	local ship_gift_cfg = ConfigManager:getCfgByName("gacha_gift")
	local version = self.m_version or 0
	local buy_times = self.m_draw_gifts or {}
	self.m_gift_bag_data = {}
	local ship_gift_cfg_v = ship_gift_cfg[version] or {}
	for k, v in pairs(ship_gift_cfg_v) do
		local buy_times = buy_times[tostring(k)] or 0
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
