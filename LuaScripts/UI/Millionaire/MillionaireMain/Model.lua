local M = class("MillionaireMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_is_token = self.m_params.is_token or false
	self.open_id = 440
	self:getData("user_payment_mult_step_rebate_index")
end

function M:onEnter()
	--Logger.logError(self.m_data,"self.m_data~~~~~~~~~~~~~~")
	self.m_items = {
		{id = 1, title_name = "streetfood_title", title_text = "millionaire_text_001",goto_name = "streetfood_goto_text",progress_name_des = "streetfood_progress_des",progress_name = "streetfood_progress",red_name = "streetfood_btn_red_point_img",red_key = "MillionaireRedDot"}, 	--小食摊
		{id = 2, title_name = "Inn_title", title_text = "millionaire_text_002",goto_name = "Inn_goto_text",progress_name_des = "Inn_progress_des",progress_name = "Inn_progress",red_name = "Inn_btn_red_point_img",red_key = "MillionaireRedDot"}, 	--客栈
		{id = 3, title_name = "tavern_title", title_text = "millionaire_text_003",goto_name = "tavern_goto_text",progress_name_des = "tavern_progress_des",progress_name = "tavern_progress",red_name = "tavern_btn_red_point_img",red_key = "MillionaireRedDot"}, 	--酒楼
	}
	self.active_data = self:getActiveData()
	self.open_active_data = UserDataManager:getActivesDataByOpenId(self.open_id)
	self:isShowTime()
end

--更新数据
function M:updateServerData(serverdata)
	table.merge(self.m_data,serverdata)
end

function M:getTokenFlag()
	return self.m_is_token
end

function M:getItem(btn_name)
	for k, v in pairs(self.m_items) do
		if btn_name == v.btn_name then
			return v
		end
	end
	return nil
end

function M:getAllItem()
	return self.m_items
end

function M:getItemTimeLimit(btn_name)
	local item = self:getItem(btn_name)
	if item then
		local activity_info = self:getOpenActive(item.open_id)
		if not activity_info then
			activity_info = UserDataManager:getActivesRechargeDataByOpenId(item.open_id)
		end
		if activity_info then
			local server_time = UserDataManager:getServerTime()
			if server_time >= activity_info.start_ts and server_time < activity_info.show_start_ts then
				return 1 --活动期
			elseif server_time >= activity_info.show_start_ts then
				if activity_info.open_id == 377 then --明月兑换的展示期也正常开启
					return 1
				end
				return 2 --展示期
			end
		end
	end
	return 0 --未开启
end

--获取活动数据
function M:getActiveData(open_id)
	local id = self.open_id
	if open_id then
		id = open_id
	end
	local version = self:getActVsn(open_id)
	local active_tab = ConfigManager:getCfgByName("active")
	for i, v in pairs(active_tab) do
		if v.open_id == id and v.version == version then
			return v
		end
	end
	local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
	for i,v in pairs(active_recharge_tab) do
		if v.open_id == id and v.version == self.m_data.actives[1].version then
			return v
		end
	end
	return nil
end

--获取活动version
function M:getActVsn(open_id, is_recharge)
	open_id = open_id or 440
	local active = nil
	if is_recharge then
		active = UserDataManager:getActivesRechargeDataByOpenId(open_id)
	else
		active = UserDataManager:getActivesDataByOpenId(open_id)
	end
	if active and active.version then
		return active.version
	end
	if is_recharge then
		local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
		for i,v in pairs(active_recharge_tab) do
			if v.open_id == open_id then
				local cur_tim =  UserDataManager:getServerTime()
				local start_ts = GameUtil:stringToTimesTamp(v.start_time)
				local end_ts = GameUtil:stringToTimesTamp(v.end_time)
				local show_ts = 0
				if v.show_time ~= "" then
					show_ts = cur_tim < GameUtil:stringToTimesTamp(v.show_time) and 1 or 0
				end
				local is_end = cur_tim < end_ts or show_ts == 1
				if cur_tim > start_ts and is_end then
					return v.version
				end
			end
		end
	else
		local active = ConfigManager:getCfgByName("active")
		for i,v in pairs(active) do
			if v.open_id == open_id then
				local cur_tim =  UserDataManager:getServerTime()
				local start_ts = GameUtil:stringToTimesTamp(v.start_time)
				local end_ts = GameUtil:stringToTimesTamp(v.end_time)
				local show_ts = 0
				if v.show_time ~= "" then
					show_ts = cur_tim < GameUtil:stringToTimesTamp(v.show_time) and 1 or 0
				end
				local is_end = cur_tim < end_ts or show_ts == 1
				if cur_tim > start_ts and is_end then
					return v.version
				end
			end
		end
	end
	return 1
end

--获取开启活动
function M:getOpenActive(open_id)
	local active_data = {}
	for i, v in ipairs(UserDataManager.m_actives) do
		if v.open_id == open_id then
			table.insert(active_data,v)
		end
	end
	if #active_data == 1 then
		return active_data[1]
	else
		for i, v in ipairs(active_data) do
			if v.open_status == 1 then
				return v
			end
		end
	end
end

--获取当前返还
function M:getCurrentReturnMoney(id)
	if self.m_data.data[tostring(self.m_data.actives[1].version)] and 
			self.m_data.data[tostring(self.m_data.actives[1].version)][tostring(id)] and 
			self.m_data.data[tostring(self.m_data.actives[1].version)][tostring(id)].rebate then
		return self.m_data.data[tostring(self.m_data.actives[1].version)][tostring(id)].rebate
	end
	return 0
end

--获取最高返还
function M:getMaxReturnMoney(id)
	local recv = self:getBuyDay(id)
	local mult_step_gift_rebate = ConfigManager:getCfgByName("mult_step_gift_rebate")
	local day_percentage = mult_step_gift_rebate[self.m_data.actives[1].version][id].rebate_percent
	local percentage = mult_step_gift_rebate[self.m_data.actives[1].version][id].return_per
	local money_sum = self:getBuyMoneySum(id)
	local return_money = money_sum * (percentage + day_percentage * recv)
	return return_money or 0
end

--计算购买价格和
function M:getBuyMoneySum(id)
	local mult_step_gift = ConfigManager:getCfgByName("mult_step_gift")
	local money_data = mult_step_gift[self.m_data.actives[1].version][id]
	local sum = 0
	for i, v in pairs(money_data) do
		sum = sum + v.price
	end
	return sum
end

--获取购买总天数
function M:getBuyDay(id)
	local mult_step_gift = ConfigManager:getCfgByName("mult_step_gift")
	local money_data = mult_step_gift[self.m_data.actives[1].version][id]
	return #money_data
end

--获取红点key
function M:getRedPointKey(id)
	for i, v in pairs(self.m_items) do
		if i == id then
			return v.red_key
		end
	end
	return nil
end

--获取展示信息
function M:getGiftData(id)
	local mult_step_gift = ConfigManager:getCfgByName("mult_step_gift")
	if mult_step_gift[self.m_data.actives[1].version] then
		return mult_step_gift[self.m_data.actives[1].version][id]
	end
end

--计算时间
function M:setCurrentDay()
	local cur_tim = UserDataManager:getServerTime() --当前时间
	local surplus_time = cur_tim - self.m_data.actives[1].start_ts --从活动开始到当前时间的差值
	local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算活动开启时间
	remain_day = remain_day + 1
	if remain_day < 1 then
		remain_day = 1
	end
	return remain_day
end

--是否已经购买商品 1:已购买，0：未购买
function M:isBuy(id,day)
	local buy_data = self.m_data.data[tostring(self.m_data.actives[1].version)][tostring(day)].days
	for i, v in pairs(buy_data) do
		if v == id then
			return 1
		end
	end
	return 0
end

--是否有可购买的礼包
function M:isBuyGift(id)
	local gift_data = self:getGiftData(id)
	for i, v in ipairs(gift_data) do
		if self:isBuy(i,id) == 0 and self:setCurrentDay() > i then
			return i
		end
	end
	return 0
end

--是否是展示期
function M:isShowTime()
	if self.m_data.actives[1].open_status == 2 then
		self.is_show_time = true
	end 
end

return M
