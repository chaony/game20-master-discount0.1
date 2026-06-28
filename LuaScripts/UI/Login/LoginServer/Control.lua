local M = class("LoginServerControl",LikeOO.OOControlBase)

function M:onEnter()
	self:UpdateTime()
	self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		if self.m_model.on_cancel_call then
			self.m_model.on_cancel_call()
		end
		self:closeView()
	elseif msg == "select_server" then
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
			self:updateMsg("select_server", nil, "parent")
			self:closeView()
		else
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0943"), delay_close = 2})
		end
		]]--
		if is_open == 0 then --维护状态
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0941"), delay_close = 2})
		elseif is_open == 1 then
			UserDataManager.server_data:setServerData(server_Data)
			self:updateMsg("select_server", nil, "parent")
			self:closeView()
		end
	elseif msg == "menu_btn" then
		self.m_view:updateServer()
    end
end

function M:getServer()
	if SDKUtil.is_gmsdk then --设置服务器数据
		SDKUtil:getFetchZonesAndRolesList(
				function(params)
					if params.Zones == nil or #params.Zones == 0 then 
						return
					end
					UserDataManager.server_data:setAllServerData(params.Zones)
					UserDataManager.server_data:setAllRoleData(params.Roles)
					if params.Roles ~= nil then
						table.sort(
								params.Roles,
								function(data1, data2)
									return data1.login_time > data2.login_time
								end
						)
						local last_server_info = {}
						for i, v in ipairs(params.Zones) do
							if params.Roles[1] ~= nil and v.server == params.Roles[1].server_id then
								table.insert(last_server_info, {zone = v, role = params.Roles[1]})
							elseif params.Roles[2] ~= nil and v.server == params.Roles[2].server_id then
								table.insert(last_server_info, {zone = v, role = params.Roles[2]})
							end
						end
						table.sort(
								last_server_info,
								function(data1, data2)
									return data1.role.login_time > data2.role.login_time
								end
						)
						UserDataManager.server_data:setLastServer(last_server_info)
						if self.m_model then
							self.m_model:initMenuData()
						end
						if self.m_view then
							self.m_view:refreshUI(true)
						end
					end
				end,
				GameVersionConfig.BYTE_DANCE_SERVER_VERSION
		)
	end
end

--计时器
function M:UpdateTime()
	if SDKUtil.is_gmsdk then
		local times_value = UserDataManager:getServerTime() - self.m_model.refreshTime
		if times_value >= 10 then
			self.m_model.refreshTime = UserDataManager:getServerTime()
			self:getServer()
		end
	end
end

return M;