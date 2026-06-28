local M = class("ActiveCurrentGiftModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_version = self.m_params.version or 0
	self.m_gift_data = self.m_params.gift_data or {}
	self.m_current_day = self.m_params.current_day or 0
	self.m_end_ts = self.m_params.end_ts or 0
	self.m_active_data = self.m_params.active_data or {}
	self.m_background = self.m_params.background
	self.m_hero_skin_data = self.m_params.hero_skin_data or {}
	self.is_tokens = self.m_params.is_token
	self.m_hero_gift_times = self.m_params.hero_gift_times or 0 --是否购买英雄
	self.m_show_data = {}
	if self.m_params.is_token == true then --代金券进入
		self.is_tokens = true
	else
		self.is_tokens = false
	end
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
	self:getGiftShowData()
end

function M:updateGiftData(callback)
	local function netCallback(response)
		self.m_gift_data = response.gift_data
		self:getGiftShowData()
		if callback then
			callback()
		end
	end
	self:getNetData("hero_event_index", {version = self.m_version }, netCallback)
end

--获取礼包展示数据
function M:getGiftShowData()
	local data_table = {}
	for i, v in pairs(self.m_gift_data) do
		local gift_data = self:getGiftData(v.gift_id)
		table.insert(data_table,{id = v.gift_id,cfg = gift_data,times = v.times })
	end
	table.sort(data_table,function(data1,data2)
		return data1.cfg.place < data2.cfg.place
	end)
	return data_table
end

--获取展示数据
function M:getGiftData(gift_id)
	local evil_shadow_gift_tab = ConfigManager:getCfgByName("hero_event_gift")[self.m_version] or {}
	for i, v in pairs(evil_shadow_gift_tab) do
		if i == gift_id then
			return v
		end
	end
	return {}
end

function M:getShowData()
	return self.m_show_data or {}
end

--获取基本显示信息
function M:BasicInfo()
	local event = ConfigManager:getCfgByName("hero_event")
	return event[self.m_version] or {}
end

function M:getHeroPriceCfg(key)
	local hero_event_hero_cfg = ConfigManager:getCfgByName("hero_event_hero") or {}
	local cur_cfg = hero_event_hero_cfg[self.m_version] or {}
	if cur_cfg[key] then
		return cur_cfg[key]
	end
	return nil
end

return M
