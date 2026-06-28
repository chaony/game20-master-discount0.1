local M = class("JuBaoShanGiftBagModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self.m_is_Tokens = false
	if self.m_params.data == nil then
		self:getData("richman_index")
		self.m_is_Tokens = self.m_params.is_token
	else
		self:getData()
	end
end

function M:onEnter()
	if self.m_params.data then
		self.m_data = self.m_params.data;
	end
	self:initData()
end

function M:initData(data)
	if data ~= nil then
		self.m_data = data;
	end
	self:initGiftBagData()
end

function M:initGiftBagData()
	local ship_gift_cfg = ConfigManager:getCfgByName("dice_gift")
	local gift_buy_times = self.m_data.gift_buy_times or {}
	self.m_gift_bag_data = {}
	for k, v in pairs(ship_gift_cfg) do
		local buy_times = gift_buy_times[tostring(k)] or 0
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
