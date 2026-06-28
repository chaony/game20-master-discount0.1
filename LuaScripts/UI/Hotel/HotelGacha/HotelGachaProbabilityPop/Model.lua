local M = class("HotelGachaProbabilityPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_cfg = self.m_params.cfg
	self.m_room_lv = self.m_params.room_lv
	self.m_attr = self.m_params.attr or 0
	self:getData()
end

function M:onEnter()

end

function M:getListData()
	local gacha_cfg = ConfigManager:getCfgByName("hotel_gacha")
	local gacha_id = self.m_cfg.gacha_pool_id
	local cfg = gacha_cfg[gacha_id]
	local allWeight = 0
	local data = {}
	for i,v in pairs(cfg or {}) do
		if v.room_level <= self.m_room_lv then --已解锁
			local weight = v.weight + self.m_attr * v.add_rate / 100
			allWeight = allWeight + weight
		end
		data[#data + 1] = v
	end
	--table.sort(data, function(data1, data2)
	--	return data1.sort < data2.sort
	--end)
	return data, allWeight
end

function M:getPercent(itemData, allWeight)
	local weight = itemData.weight + self.m_attr * itemData.add_rate / 100
	local percent = weight / allWeight
	return percent
end

--[[
function M:getItemShowWeight(itemData, allWeight, cardWeight)
	-- 概率算法：
	-- 自选卡 weight / 10000,   	--sort=1为自选卡
	-- 其他物品 weight / allWeight * ((10000 - 自选卡weight) / 10000)
	local curWeight = 0
	local basicsValue = 10000
	local minWeight = 0.01
	if itemData.sort == 1 then
		curWeight = itemData.weight / basicsValue
	else
		curWeight = itemData.weight / allWeight * ((basicsValue - cardWeight) / basicsValue)
	end
	curWeight = curWeight * 100
	curWeight = (curWeight > minWeight) and curWeight or minWeight
	return curWeight
end
]]--

return M