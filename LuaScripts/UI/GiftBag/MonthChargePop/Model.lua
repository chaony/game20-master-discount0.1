local M = class("MonthChargePopModel", LikeOO.OODataBase)

function M:onCreate() 
	M.super.onCreate(self)
	self:getData("wl_relics_index")
end

function M:onEnter()
	self.m_version = self.m_data.version or 1
	self.m_is_token = self.m_params.is_token or false
	self.m_open_id = self.m_data.actives.open_id or 364
	self.m_activity_cfg = ConfigManager:getCfgByName("wl_relics")[1]
	self.m_gift_bag_cfg = ConfigManager:getCfgByName("wl_relics_gift")
	self.m_hero_skin_id = self.m_gift_bag_cfg[self.m_version][1]["show_hero"]
	self:refreshGiftBagData()
end

-- 刷新礼包数据
function M:refreshGiftBagData(data)
	table.merge(self.m_data, data or {})

	self.m_gift_bag_data = {}
	local bought_count = self.m_data.day
	local cur_gift_bag_cfg = self.m_gift_bag_cfg[self.m_version] or {}
	for k, v in ipairs(cur_gift_bag_cfg) do
		local status = k > bought_count and 0 or -1  -- status: 0 未被购买，-1 已被购买
		table.insert(self.m_gift_bag_data, {id = k, cfg = v, status = status })
	end
	
	local sort_func = function(data1, data2)
		if data1.status == data2.status then
			return data1.id < data2.id
		else
			return data1.status > data2.status
		end
	end
	table.sort(self.m_gift_bag_data, sort_func)

	if self.m_data.today_pay == 0 and self.m_gift_bag_data[1].status == 0 then
		self.m_gift_bag_data[1].status = 1  -- status: 1 今天可被购买
	end
end

-- 数据获取
function M:isToken()
	return self.m_is_token
end

function M:getHeroSkinID()
	return self.m_hero_skin_id
end

function M:getHelpDes()
	return self.m_activity_cfg.des
end

function M:getGiftBagData()
	return self.m_gift_bag_data or {}
end

function M:getEndTs()
	return self.m_data.actives[1].end_ts
end

return M
