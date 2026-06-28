local M = class("PlayerBackToNewControl",LikeOO.OOControlBase)

function M:onEnter()
	
end

function M:onHandle(msg , data)
	if msg == 99999 or msg == "close_btn" then    -- 返回
		self:closeView()
	elseif msg == "go_btn" then
		if self:eightHoursCheck() == false then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_1077"), delay_close = 2})
			return
		end
		local params = {
			on_ok_call = function()
				if self:eightHoursCheck() == false then
					GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_1077"), delay_close = 2})
					return
				end
				self:selectServer(data)
			end,
			tow_close_btn = true,
			text = Language:getTextByKey("new_str_1070")
		}
		self:openView("Pops.CommonPop", params)
	end
end

function M:eightHoursCheck()
	if UserDataManager.comeback_status == 1 then
		local min_unit = 60
		local hour_unit = min_unit * 60
		local day_unit = hour_unit * 24
		local time_left = hour_unit * 8 - (UserDataManager:getServerTime() - UserDataManager.comeback_ts or 0)
		local day_left = math.floor(time_left / day_unit)
		local hour_left = math.floor((time_left - day_unit * day_left) / (hour_unit))
		local min_left = math.floor((time_left - day_unit * day_left - hour_unit * hour_left) / min_unit)
		local sec_left = math.floor(time_left - day_unit * day_left - hour_unit * hour_left - min_unit * min_left)
		if hour_left > 0 or min_left > 0 or sec_left > 0 then
			return true
		end
	end
	return false
end

function M:selectServer(data)
	local is_open = data.is_open
	--[[
	if not SDKUtil.is_gmsdk then
		if is_open == 1 then
			is_open = "Online"
		end
	end
	]]--
	local server_Data = data
	if data.role ~= nil then
		is_open = data.zone.is_open
		server_Data = data.zone
	end
	--[[
	if is_open == "InMaintenance" then --维护状态
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0941"), delay_close = 2})
	elseif is_open == "Offline" then --离线
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0942"), delay_close = 2})
	elseif is_open == "Online" then --正常状态
		UserDataManager.server_data:setServerData(server_Data)
		self:choosePlayerBackType(server_Data)
	else
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0943"), delay_close = 2})
	end
	]]--
	if is_open == 0 then --维护状态
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0941"), delay_close = 2})
	elseif is_open == 1 then
		UserDataManager.server_data:setServerData(server_Data)
		self:choosePlayerBackType(server_Data)
	end
end

function M:choosePlayerBackType(server_data)
	local params_choose = {choose_type = 3, new_server = server_data.server}
	local netCallback_chose = function(response)
		if response and response.comeback_status == 3 then
			UserDataManager.comeback_status = 3
			UserDataManager.local_data:setLocalDataByKey("player_back_server_chose_flag", true)
			UserDataManager.local_data:setLocalDataByKey("player_back_server_chose_server_data", server_data)
			self:loginAgain()
		end
	end
	self.m_model:getNetData("user_comeback_choose", params_choose, netCallback_chose)
end

function M:loginAgain()
	GameMain.reStart()
end

return M