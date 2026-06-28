local M = class("NewYearGiftModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.is_tokens = self.m_params.is_token or false
	self.m_version = self.m_params.version or 0
	self.m_gift_data = self.m_params.gift_data or {}
	self.m_current_day = self.m_params.day or 0
	self.m_end_ts = self.m_params.end_ts or 0
	self.m_actives = self.m_params.actives
	-- 获取到皮肤配置
	self.spring_festival_clothes = ConfigManager:getCfgByName("spring_festival_clothes");
	self.m_show_data = {}
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
	if data then
		self.m_gift_data = data.spring_gifts or {}
		self.m_version = data.version or self.m_version
		self.m_current_day = data.cur_day or self.m_current_day
		self:updateShowData()
	end
end

function M:getGiftCfgByPlaceIdAndGiftId(place_id, gift_id)
	local spring_festival_gift_tab = ConfigManager:getCfgByName("spring_festival_gift")[self.m_version] or {}
	local cur_spring_festival_gift = spring_festival_gift_tab[self.m_current_day] or {}
	if cur_spring_festival_gift[tonumber(place_id)] and cur_spring_festival_gift[tonumber(place_id)][tonumber(gift_id)] then
		return cur_spring_festival_gift[tonumber(place_id)][tonumber(gift_id)]
	end
	return nil
end


function M:updateShowData()
	self.m_show_data = {}
	for net_place_id, net_index_item in pairs(self.m_gift_data) do
		local cfg_data = self:getGiftCfgByPlaceIdAndGiftId(net_place_id, net_index_item.gift_id)
		if cfg_data then
			local temp_item = {}
			temp_item.place = tonumber(net_place_id) 
			table.merge(temp_item, net_index_item)
			table.merge(temp_item, cfg_data)
			table.insert(self.m_show_data, temp_item)
		end
	end
	table.sort(self.m_show_data, function(item1, item2) return item1.place < item2.place end)
end

function M:getShowData(index)
	if not index then
		return self.m_show_data
	end
	return self.m_show_data[index] or {}
end

function M:getSkins()
	--通过版本号来获取到皮肤配置
	local skins = self.spring_festival_clothes[self.m_version];
	if skins ~= nil then
		local m_skin_datas = {}
		for i, v in ipairs(skins) do
			return v
		end
	end
	return nil;
end

function M:getEndTs()
	local server_time = UserDataManager:getServerTime()
	local next_fresh_time = TimeUtil.getIntTimestamp(server_time)
	local end_times = next_fresh_time + 24 * 3600
	return end_times
	--if self.m_actives and self.m_actives.end_ts then
	--	return self.m_actives.end_ts
	--end
	--return 0
end

function M:getActiveCfgByOpenId(open_id)
	local active_tab = ConfigManager:getCfgByName("active")
	for i,v in pairs(active_tab) do
		if v.open_id == open_id then
			return v
		end
	end	
	local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
	for i,v in pairs(active_recharge_tab) do
		if v.open_id == open_id then
			return v
		end
	end	
	return nil
end

return M
