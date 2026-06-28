local M = class("FamilyDinnerPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	--self.m_transfer = "scale"
	self.m_is_token = self.m_params.is_token or false
	--self.m_openId = self.m_params.m_openId or 227
	self.version = self.m_params.version
	self.day = self.m_params.day
	self.dinner_gifts = self.m_params.m_data
	self:getData()
end

function M:onEnter()
	self:initData(self.m_data)
end

function M:initData()
	self:InitTimes()
	self:initGiftBagData()
end
--初始次数
function M:InitTimes()
	local history = self.dinner_gifts[tostring(3)].history or {}
	self.gifts_data = {}
	for k,v in pairs(history) do
		self.gifts_data[tonumber(k)] = v
	end
end
--更新次数
function M:UpdateData(data)
	self.dinner_gifts = data or {}
	self:initData()
end

function M:initGiftBagData()
	self.m_gift_bag_data = {}
	local dinner_gift = ConfigManager:getCfgByName("dinner_gift")
	local version_gift = dinner_gift[self.version];
	if version_gift == nil then
		return nil
	end
	local day_gift = version_gift[self.day];
	if day_gift == nil then
		return nil
	end
	local dayXlsxData = day_gift[3]
	--local buyPagData = self.m_data.gifts_data[self.cur_page] or {}
	for k, v in pairs(dayXlsxData) do
		--local buyItemData = buyPagData[tostring(k)] or {}
		local season = UserDataManager:getCurSeason()
		if v.season1 == -1 and v.season ==0 then
			local itemData = v
			local buy_times =self.gifts_data[v.id] or 0
			local status = 0
			local time_limit = itemData.time_limit or 0
			if time_limit > 0 and buy_times >= time_limit then -- 已售完
				status = -1
			end
			table.insert(self.m_gift_bag_data, {id = k, cfg = itemData, buy_times = buy_times, status = status})
		elseif v.season1 ~= -1 and v.season1 == season then
			local itemData = v
			local buy_times = self.gifts_data[v.id] or 0
			local status = 0
			local time_limit = itemData.time_limit or 0
			if time_limit > 0 and buy_times >= time_limit then -- 已售完
				status = -1
			end
			table.insert(self.m_gift_bag_data, {id = k, cfg = itemData, buy_times = buy_times, status = status})
		elseif v.season1 == -1 and v.season ~=0 and season >= v.season then
			local itemData = v
			local buy_times = self.gifts_data[v.id] or 0
			local status = 0
			local time_limit = itemData.time_limit or 0
			if time_limit > 0 and buy_times >= time_limit then -- 已售完
				status = -1
			end
			table.insert(self.m_gift_bag_data, {id = v.id, cfg = itemData, buy_times = buy_times, status = status})
		end
		--if not v.version and

	end
	table.sort(self.m_gift_bag_data, function(data1, data2)
		if data1.status == data2.status then
			return data1.id < data2.id
		else
			return data1.status > data2.status
		end
	end)

--[[	local dinner_gift = ConfigManager:getCfgByName("dinner_gift")
	local version_gift = dinner_gift[self.version];
	if version_gift == nil then
		return nil
	end
	local day_gift = version_gift[self.day];
	if day_gift == nil then
		return nil
	end
	self.m_gift_bag_data = day_gift[3];
	self.gift_data = self.AllData.dinner_gifts[tostring(3)]
	for k,v in ipairs(day_gift[3]) do 
		
	end
	table.sort(self.m_gift_bag_data, function(data1, data2)
		if data1.status == data2.status then
			return data1.id < data2.id
		else
			return data1.status > data2.status
		end
	end)]]
end

function M:getGiftBagData()
	return self.m_gift_bag_data or {}
end

return M
