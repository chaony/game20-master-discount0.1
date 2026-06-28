local M = class("MillionairePopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_is_token = self.m_params.is_token or false
	self.open_id = 440
	self:getData()
end

function M:onEnter()
	self.m_items = {
		{id = 1, title_name = "tab_btn_text_1", title_text = "millionaire_text_001",red_name = "tab_1_btn_red_point_img",red_key = "MillionaireRedDot"}, 	--小食摊
		{id = 2, title_name = "tab_btn_text_2", title_text = "millionaire_text_002",red_name = "tab_2_btn_red_point_img",red_key = "MillionaireRedDot"}, 	--客栈
		{id = 3, title_name = "tab_btn_text_3", title_text = "millionaire_text_003",red_name = "tab_3_btn_red_point_img",red_key = "MillionaireRedDot"}, 	--酒楼
	}
	self.show_id = self.m_params.id
	self.m_data = self.m_params.data
	self.current_time = self:setCurrentDay()
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

--更新数据
function M:updateServerData(serverdata)
	table.merge(self.m_data,serverdata)
end

--获取展示信息
function M:getGiftData(id)
	local pos_id = self.show_id
	if id then
		pos_id = id
	end
	local mult_step_gift = ConfigManager:getCfgByName("mult_step_gift")
	if mult_step_gift[self.m_data.actives[1].version] then
		return mult_step_gift[self.m_data.actives[1].version][pos_id]
	end
end

--是否已经购买商品 1:已购买，0：未购买
function M:isBuy(id,day)
	if self.m_data.data[tostring(self.m_data.actives[1].version)] == nil then
		return 1
	end
	local buy_data = self.m_data.data[tostring(self.m_data.actives[1].version)][tostring(day)].days
	if buy_data then
		for i, v in pairs(buy_data) do
			if v == id then
				return 1
			end
		end
	end
	return 0
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

--获取红点key
function M:getRedPointKey(id)
	for i, v in pairs(self.m_items) do
		if i == id then
			return v.red_key
		end
	end
	return nil
end

--当前可购买的最小id
function M:isBuyMinId(id)
	local gift_data = self:getGiftData(id)
	for i, v in ipairs(gift_data) do
		if self:isBuy(i,id) == 0 and self.current_time > i then
			return i
		end
	end
	return 0
end

return M
