local M = class("QiXiMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_is_token = self.m_params.is_token or false
	self:getData()
end

function M:onEnter()
	self.m_open_id = 373
	self.m_items = {
		{open_id = 377, btn_name = "qi_xi_item_1_btn", prefab_name = "QiXiExchange"}, 	--明月兑换
		{open_id = 376, btn_name = "qi_xi_item_2_btn", prefab_name = "QiXiGiftMoon"}, 	--明月献礼
		{open_id = 375, btn_name = "qi_xi_item_3_btn", prefab_name = "QiXiShopping"}, 	--团购狂欢
		{open_id = 374, btn_name = "qi_xi_item_4_btn", prefab_name = "QiXiCouple"}, 	--佳偶天成
		{open_id = 378, btn_name = "qi_xi_item_5_btn", prefab_name = "QiXiGiftBridge"}, --鹊桥礼包
		{open_id = 291, btn_name = "qi_xi_item_6_btn", prefab_name = "QiXiLove"}, 		--情比金坚
	}
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
		local activity_info = UserDataManager:getActivesDataByOpenId(item.open_id)
		if not activity_info then
			activity_info = UserDataManager:getActivesRechargeDataByOpenId(item.open_id)
		end
		if activity_info then
			local server_time = UserDataManager:getServerTime()
			if server_time >= activity_info.start_ts and server_time < activity_info.show_start_ts then
				return 1 --活动期
			elseif server_time >= activity_info.show_start_ts and server_time <= activity_info.end_ts then
				if activity_info.open_id == 377 or activity_info.open_id == 291 or activity_info.open_id == 375 then 
					return 1
				end
				return 2 --展示期
			end
		end
	end
	return 0 --未开启
end

function M:getActiveData()
	local activity_info = UserDataManager:getActivesDataByOpenId(self.m_open_id)
	if activity_info then
		local active_tab = ConfigManager:getCfgByName("active")
		return active_tab[activity_info.id]
	else
		activity_info = UserDataManager:getActivesRechargeDataByOpenId(self.m_open_id)
		if activity_info then
			local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
			return active_recharge_tab[activity_info.id]
		end
	end
end

function M:getItemData(btn_name)
	local activity_info
	local item = self:getItem(btn_name)
	if item then
		activity_info = UserDataManager:getActivesDataByOpenId(item.open_id)
		if activity_info then
			local active_tab = ConfigManager:getCfgByName("active")
			return active_tab[activity_info.id]
		else
			activity_info = UserDataManager:getActivesRechargeDataByOpenId(item.open_id)
			if activity_info then
				local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
				return active_recharge_tab[activity_info.id]
			end
		end
	end
end

return M
