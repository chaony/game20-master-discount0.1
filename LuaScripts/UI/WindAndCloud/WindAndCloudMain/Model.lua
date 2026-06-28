local M = class("WindAndCloudMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_is_token = self.m_params.is_token or false
	self.open_id = 403
	self:getData()
end

function M:onEnter()
	self.m_items = {
		{open_id = 404, btn_name = "item_1_btn", prefab_name = "WindAndCloudCouple",show_start_open = false}, 	--斗转星移
		{open_id = 405, btn_name = "item_2_btn", prefab_name = "WindAndCloudProgressReward",show_start_open = false}, 	--壮志凌云
		{open_id = 406, btn_name = "item_3_btn", prefab_name = "WindAndCloudMoon",show_start_open = true}, 	--九天揽月
		{open_id = 407, btn_name = "item_4_btn", prefab_name = "WindAndCloudRedEnvelope",show_start_open = false}, 	--名扬四海
	}
	self.active_data = self:getActiveData()
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
		if v.open_id == open_id and v.version == self.m_data.version then
			return v
		end
	end
	return nil
end

--获取活动version
function M:getActVsn(open_id, is_recharge)
	open_id = open_id or 403
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

return M
