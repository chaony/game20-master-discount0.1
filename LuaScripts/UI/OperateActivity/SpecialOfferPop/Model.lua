local M = class("SpecialOfferPopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self:getData("gift_off_index")
end

function M:onEnter()
	self.m_gift_off_data = self.m_data.gift_off
	self.m_actives= self.m_data.actives
end

--领取特惠礼包数据
function M:getGiftOffData(id)
	for k,v in pairs(self.m_gift_off_data.gifts) do
		if id == v then
			return true
		end
	end
	return false
end

--购买特惠礼包数据
function M:getBuyGiftOffData(id)
	for k,v in pairs(self.m_gift_off_data.pays) do
		if id == v then
			return true
		end
	end
	return false
end

--每日特惠配置数据
function M:get_gift_off_cfg(version)
	local gift_off_tab = ConfigManager:getCfgByName("gift_off")
	return gift_off_tab[version or 1]
end

function M:getListData()
	local cfg = self:get_gift_off_cfg(self.m_gift_off_data.version)
	local data = {}
	self.pack_cfg = nil
	self.original_price = 0
	for k,v in pairs(cfg) do
		if v.type == 1 then
			data[k] = table.copy(v)
			data[k].id = k
			self.original_price = v.price + self.original_price
		elseif v.type == 2 then
			self.pack_cfg = v
		end
	end
	return data
end

function M:getPackCanBuy()
	if self.pack_cfg then
		if self.m_gift_off_data.once_pay == 0 and next(self.m_gift_off_data.pays) == nil then
			return true
		end
	end
	return false
end

return M