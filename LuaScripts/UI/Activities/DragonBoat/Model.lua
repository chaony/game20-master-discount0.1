local M = class("DragonBoatModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_is_token = self.m_params.is_token
	self:getData("feast_main_index")
end
local LOCAL_TAB = { {open_id=353, btn_name = "btn_1",text = "btn1_text", name = "粽情好礼", red_point_img = "btn_red_point_img1"},
				{open_id=354, btn_name = "btn_2",text = "btn2_text", name = "粽意礼包", red_point_img = "btn_red_point_img2"},
				{open_id=355, btn_name = "btn_3",text = "btn3_text", name = "美味兑换", red_point_img = "btn_red_point_img3"},
				{open_id=356, btn_name = "btn_4",text = "btn4_text", name = "流觞曲水", red_point_img = "btn_red_point_img4"},
				{open_id=326, btn_name = "btn_5",text = "btn5_text", name = "厨神争霸", red_point_img = "btn_red_point_img5"},
				{open_id=323, btn_name = "btn_6",text = "btn6_text", name = "美味尝鲜", red_point_img = "btn_red_point_img6"},
}

function M:onEnter()
	self.m_act_data = UserDataManager:getActivesDataByOpenId(352)
end

function M:updateData(data)
	if data then
		self.m_data = data
	end
end

function M:getEndTs()
	if self.m_act_data and self.m_act_data.end_ts then
		return self.m_act_data.end_ts - UserDataManager:getServerTime(), self.m_act_data.open_status
	end
	return 0
end

function M:getActStatus(open_id)
	open_id = open_id or 352
	local active = UserDataManager:getActivesDataByOpenId(open_id)
	if active and active.open_status then
		return active.open_status
	end
	return 0
end

--做饭红点
function M:checkCookRed()
	self.m_cookRedPoint = false
	if not self:getActStatus() == 1 then
		return
	end
	if self.m_cookData == nil then
		local cfg = ConfigManager:getCfgByName("meituan_cook")
		if cfg then
			self.m_version_cfg = cfg[self.m_data.version]
		end
		self.m_cookData = {}
		for k, v in ipairs(self.m_version_cfg) do
			table.insert(self.m_cookData, { materials_data = v.material })
		end
	end

	local maxNum = 9999999
	for k, v in ipairs(self.m_cookData) do
		for i = 1, #v.materials_data do
			maxNum = 10
			if #v.materials_data[i] == 3 and v.materials_data[i][1] == RewardUtil.REWARD_TYPE_KEYS.ITEM then
				local item_data = UserDataManager.item_data:getItemDataById(v.materials_data[i][2]) or {}
				local num = math.floor(item_data.num / v.materials_data[i][3])
				if num == 0 then
					maxNum = 0
					break
				else
					maxNum = math.min(maxNum, num)
				end

			end
		end
		if maxNum > 0 then
			self.m_cookRedPoint = true
			break
		end
	end
	local milepost_red = self:isHasMilepostRed()
	self.m_cookRedPoint = self.m_cookRedPoint or milepost_red
	return self.m_cookRedPoint
end

--获取里程碑数据
function M:getMilepostData()
	local meituan_dumpling_stage = ConfigManager:getCfgByName("meituan_dumpling_stage")
	local server_tab = meituan_dumpling_stage[self.m_data.version]
	return server_tab
end

--是否有里程碑红点
function M:isHasMilepostRed()
	local milepost_data = self:getMilepostData()
	for i, v in pairs(milepost_data) do
		if self.m_data.total_cook_times >= v.amount then
			local isReceive = self:getMilepostRewardIsReceive(i)
			if not isReceive then
				return true
			end
		end
	end
	return false
end

--获取里程碑奖励是否已领取   true:已领取
function M:getMilepostRewardIsReceive(id)
	for i, v in pairs(self.m_data.got_milepost_reward) do
		if v == id then
			return true
		end
	end
	return false
end

--返回做饭红点状态
function M:getCookRedPoint()
	return self.m_cookRedPoint
end

--获取活动类型
function M:getCurrentActiveMode()
	local common = ConfigManager:getCfgByName("common")
	if common[819] then
		return common[819].value or 0
	end
	return 1
end

--获取活动数据
function M:getActiveData(open_id)
	local id = self.open_id
	if open_id then
		id = open_id
	end
	local flag = open_id == 354 and true or false
	local version = self:getActVsn(open_id,flag)
	local active_tab = ConfigManager:getCfgByName("active")
	for i, v in pairs(active_tab) do
		if v.open_id == id and v.version == version then
			return v
		end
	end
	local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
	for i,v in pairs(active_recharge_tab) do
		if v.open_id == open_id and v.version == version then
			return v
		end
	end
	return nil
end


--获取活动version
function M:getActVsn(open_id, is_recharge)
	open_id = open_id or 408
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
				if activity_info.open_id == 326 or activity_info.open_id == 355 then --明月兑换的展示期也正常开启
					return 1
				end
				return 2 --展示期
			end
		end
	end
	return 0 --未开启
end

function M:getItem(btn_name)
	for k, v in pairs(LOCAL_TAB) do
		if btn_name == v.btn_name then
			return v
		end
	end
	return nil
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

return M
