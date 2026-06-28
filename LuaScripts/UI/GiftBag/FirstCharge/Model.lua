---@class FirstChargeModel:OODataBase
local M = class("FirstChargeModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self:getData("first_payment_index")
end

function M:onEnter()
	self.m_callback = self.m_params.callback
    self.m_callback_new = self.m_params.callback_new
	self.m_tag_list = self:getTagList()
	self.m_select_tag_index = self:getDefTagIndex() --页签
	self.m_select_day_index = self:getDefDayIndex() --天数
	self:getDayList()
end

function M:getDefTagIndex()
	for i = 1, #self.m_tag_list do
		local bl = self:checkIsGet(i)
		if bl == true then
			return i
		end
	end
	return 1
end

function M:getDefDayIndex()
	if self.m_data.first_payment.detail == nil then
		return 1
	end
	local detal_data = self.m_data.first_payment.detail[tostring(self.m_select_tag_index)] or {}
	if detal_data and next(detal_data) ~= nil then
		for i = 1,3 do
			if self:checkGet(detal_data.done, i) == true then
				return i
			end
		end
	end
	return 1
end

function M:checkIsGet(tag_index)
	if self.m_data.first_payment.detail == nil then
		return false
	end
	local detal_data = self.m_data.first_payment.detail[tostring(tag_index)] or {}
	if detal_data and next(detal_data) ~= nil then
		local day = self:checkTime(detal_data.reach_ts)
		local day_index = day < 3 and day or 3
		for i = 1,day_index do
			if self:checkGet(detal_data.done, i) == true then
				return true
			end
		end
	end
	return false
end

function M:updateData(data)
	if data then
		self.m_data = data
	end
end

function M:getTagList()
	local recharge_cfg = ConfigManager:getCfgByName("first_recharge")
	return recharge_cfg
end

function M:getSelectReward()
	local recharge_cfg = self:getTagList()
	local day_list = self:getDayList()
	local day_recharge_cfg = recharge_cfg[self.m_select_tag_index]
	local index = day_list[self.m_select_day_index]
	if day_recharge_cfg.gifts[index] then
		return day_recharge_cfg.gifts[index]
	end
	return {}
end

function M:getNeedPayNum()
	local recharge_cfg = self:getTagList()
	local day_recharge_cfg = recharge_cfg[self.m_select_tag_index]
	return day_recharge_cfg.price
end

function M:getSecectRechargeCfg()
	local recharge_cfg = self:getTagList()
	return recharge_cfg[self.m_select_tag_index] or nil
end

function M:getPayData()
	if self.m_data.first_payment.detail == nil then
		return false
	end
	local detal_data = self.m_data.first_payment.detail[tostring(self.m_select_tag_index)] or {}
	local day_list = self:getDayList()
	local index = day_list[self.m_select_day_index]
	if next(detal_data) ~= nil then
		for k,v in pairs(detal_data.done) do
			if v == index then
				return true
			end
		end
	end
	return false
end

function M:getPayNum()
	return GameUtil:formatNum(self.m_data.first_payment.pay) or 0
end

function M:getRechargeCfg()
	local recharge_cfg = ConfigManager:getCfgByName("first_recharge")
	return recharge_cfg[self.m_data.id] or nil
end

function M:checkCanGet()
	if self.m_data.first_payment.detail == nil then
		return false
	end
	local detal_data = self.m_data.first_payment.detail[tostring(self.m_select_tag_index)] or {}
	if detal_data and next(detal_data) ~= nil then
		local day = self:checkTime(detal_data.reach_ts)
		local day_list = self:getDayList()
		local day_index = day_list[self.m_select_day_index]
		if day >= day_index and self:checkGet(detal_data.done, day_index) == true then
			return true
		end
	end
	return false
end

function M:checkGetDay()
	local detal_data = self.m_data.first_payment.detail[tostring(self.m_select_tag_index)] or {}
	if detal_data and next(detal_data) ~= nil then
		local day = self:checkTime(detal_data.reach_ts)
		local day_list = self:getDayList()
		local day_index = day_list[self.m_select_day_index]
		return day_index - day
	end
	return 1
end

function M:checkDayReach()
	local detal_data = self.m_data.first_payment.detail[tostring(self.m_select_tag_index)] or {}
	if detal_data and next(detal_data) ~= nil then
		local day = self:checkTime(detal_data.reach_ts)
		local day_list = self:getDayList()
		local day_index = day_list[self.m_select_day_index]
		if day >= day_index then
			return true
		end
	end
	return false
end

function M:checkGet(tab, day)
	for k,v in pairs(tab) do
		if day == v then
			return false
		end
	end
	return true
end

function M:checkTime(time_ts)
	local server_ts = UserDataManager:getServerTime()
    local day = GameUtil:NumberOfDaysInterval(server_ts, time_ts, 0)
    return GameUtil:formatNum(day + 1) 
end

--首充页签红点
function M:checkRedPointByTag(index)
	if self.m_data.first_payment.pay == 0 then
		 return false
	end		 
	local detail_data = self.m_data.first_payment.detail[tostring(index)]
	if detail_data then
		local day = self:checkTime(detail_data.reach_ts)
		local day_list = self:getDayListByTagIndex(index)
		for k,v in pairs(day_list) do
			if day >= day_list[k] and self:checkCanGetBuDay(detail_data, day_list[k]) == true then
				return true
			end
		end
	end
	return false
end

function M:checkCanGetBuDay(data, day)
	for k,v in pairs(data.done) do
		if v == day then
			return false
		end
	end
	return true
end

--首充日期红点
function M:checkRedPointByDay(index)
	if self.m_data.first_payment.pay == 0 then
		return false
   	end
   	local detail_data = self.m_data.first_payment.detail[tostring(self.m_select_tag_index)]
   	if detail_data then
		local day = self:checkTime(detail_data.reach_ts)
		local day_list = self:getDayList()
		local day_index = day_list[index]
		if day >= day_index then
			return self:checkCanGetBuDay(detail_data, day_index)
		else
			return false	
		end
	end
	return false
end

function M:getLockNum(index)
	local recharge_cfg = self:getTagList()
	return recharge_cfg[index].sort
end

--获取天数并排序
function M:getDayList()
	local recharge_cfg = self:getTagList()
	local day_recharge_cfg = recharge_cfg[self.m_select_tag_index]
	local new_table = {}
	if day_recharge_cfg.gifts then
		for k,v in pairs(day_recharge_cfg.gifts) do
			table.insert(new_table, k)
		end
	end
	table.sort(new_table, function(data1, data2)
		return data1 < data2
	end)
	return new_table
end

--获取天数列表
function M:getDayListByTagIndex(index)
	local recharge_cfg = self:getTagList()
	local day_recharge_cfg = recharge_cfg[index]
	local new_table = {}
	if day_recharge_cfg.gifts then
		for k,v in pairs(day_recharge_cfg.gifts) do
			table.insert(new_table, k)
		end
	end
	return new_table
end

--检查前一天的有没有领
function M:checkLastGet()
	local day_list = self:getDayList()
	local new_table = {}
	local detail_data = self.m_data.first_payment.detail[tostring(self.m_select_tag_index)]
	for i = 1, #day_list do
		local bl = self:checkCanGetBuDay(detail_data, day_list[i])
		if bl == true then
			return i
		end
	end
	return 1
end

return M