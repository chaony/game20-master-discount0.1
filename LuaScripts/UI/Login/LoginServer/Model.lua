local M = class("LoginServerModel", LikeOO.OODataBase)

M.testTable = {}

local __server_step = 10

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.server_data = self.m_params
	self.m_server = UserDataManager.server_data:getServerId()
	self.m_sel_menu_index = 1
	self.refreshTime = UserDataManager:getServerTime() --初始服务器时间
	self:initMenuData()
end

function M:getLastLoginServerData()
	local server_data = self:getServerData()
	local login_server_data = nil
	for k,v in pairs(server_data) do
		if self.m_server == v.server then
			login_server_data = v
			break
		end
	end
	return login_server_data
end


function M:getServerData()
	return self.server_data
end

function M:getShowServerData()
	--local server_data = self:getServerData()
	--local menu_index = self.m_sel_menu_index
	--local data = nil
	--if menu_index > 1 then
	--	local menu_data = self:getMenuData()
	--	local menu_data_item = menu_data[menu_index]
	--	local start_server = menu_data_item.start_server
	--	local end_server = menu_data_item.end_server
	--	data = {}
	--	--for k,v in pairs(server_data) do
	--	--	if v.server >= start_server and v.server <= end_server then
	--	--		table.insert(data, v)
	--	--	end
	--	--end
	--	for i, v in pairs(server_data[menu_index-1].server) do
	--		if v.is_open == "Online" then
	--			table.insert(data, v)
	--		end
	--	end
	--else
	--	data = server_data
	--end
	--table.sort(data, function(data1, data2) 
	--	return data1.server > data2.server
	--end)
	
	--字节sdk服务器新逻辑
	local server_info = {}
	if self.menu_list[self.m_sel_menu_index].zone_id == -2 then --我的角色
		server_info = self:getRoleData()
		--table.sort(server_info, function(data1, data2)
		--	return data1.role.login_time > data2.role.login_time
		--end)
	elseif self.menu_list[self.m_sel_menu_index].zone_id == -1 then --推荐区服
		if self.menu_list ~= nil and #self.menu_list > 0  then
			server_info = self:getRecommend()
			--table.sort(server_info,function(data1,data2)
			--	return data1.server > data2.server
			--end)
		end
	else --区服列表信息
		if self.menu_list ~= nil and #self.menu_list > 0  then
			local zone_id = self.menu_list[self.m_sel_menu_index].zone_id
			server_info = self.zone_map_ids[zone_id]
			--table.sort(server_info,function(data1,data2)
			--	return data1.server > data2.server
			--end)
		end
	end
	return server_info
end

--获取角色信息
function M:getRoleData()
	local role_data = UserDataManager.server_data:getAllRoleData()
	local role_list = {}
	for i, v in pairs(role_data) do
		local server_id = v.server_id
		local server_data = self:getServerData(server_id)
		local params = {
			role = v,
			zone = server_data
		}
		table.insert(role_list,params)
	end
	return role_list
end

--获取服务器数据
function M:getServerData(server_id)
	local server_data = UserDataManager.server_data:getAllServerData()
	for i, v in pairs(server_data) do
		if server_id == v.server then
			return v
		end
	end
	return {}
end

function M:initMenuData()
	--local data = {{name = Language:getTextByKey("new_str_0670")}}
	--local server_data = self:getServerData()
	local server_data = UserDataManager.server_data:getAllServerData()
	--local server_len = #server_data
	--local last_count = server_len%__server_step
	--local len = math.floor(server_len/__server_step) + (last_count == 0 and 0 or 1)
	--for i=len,1,-1 do
	--	local start_server = (i-1)*__server_step+1
	--	local end_server = i*__server_step
	--	if last_count > 0 and i == len then
	--		end_server = end_server - __server_step + last_count
	--	end
	--	local name = Language:getTextByKey("new_str_0671", start_server, end_server)
	--	table.insert(data, {name = name, start_server = start_server, end_server = end_server })
	--end
	self.zone_map_ids = {}
	if SDKUtil.is_gmsdk then
		--接入字节sdk区服新逻辑
		for i, v in ipairs(server_data) do
			if self.zone_map_ids[v.ZoneID] == nil then
				self.zone_map_ids[v.ZoneID] = {}
			end
			table.insert(self.zone_map_ids[v.ZoneID], v)
		end
	else
		for i, v in ipairs(server_data) do
			v.ZoneID = v.ZoneID or 1
			v.ZoneName = ""
			if self.zone_map_ids[v.ZoneID] == nil then
				self.zone_map_ids[v.ZoneID] = {}
			end
			table.insert(self.zone_map_ids[v.ZoneID], v)
		end
	end
	local zone_ids = {}
	for i, v in pairs(self.zone_map_ids) do 
		local zone_name = v[1].ZoneName
		table.insert(zone_ids, {zone_id = i, zone_name = zone_name})
	end
	--for i, v in ipairs(self.zone_map_ids) do
	--	table.sort(v,function(data1,data2)
	--		return data1.server > data2.server
	--	end)
	--end
	table.sort(zone_ids,function(data1,data2)
		return data1.zone_id > data2.zone_id
	end)
	self.m_menu_data = zone_ids
end



--获取上次登录区服信息
function M:getLastServerInfo()
	local last_server_info = UserDataManager.server_data:getLastServer()
	return last_server_info
end

--区服列表菜单
function M:getMenuData()
	self.menu_list = {}
	local role_list = UserDataManager.server_data:getAllRoleData()
	if #role_list > 0 then
		local my_role =
		{
			zone_id = -2,
			zone_name = Language:getTextByKey("new_str_0946")
		}
		table.insert(self.menu_list,my_role)
	end
	if SDKUtil.is_gmsdk then
		local recommend_server = {
			zone_id = -1,
			zone_name = Language:getTextByKey("new_str_0947")
		}
		table.insert(self.menu_list,recommend_server)
		if self.m_menu_data ~= nil and #self.m_menu_data > 0 then
			for i, v in pairs(self.m_menu_data) do
				if self:getServerIsOnline(v.zone_id) then
					table.insert(self.menu_list,v)
				end
			end
		end
	else
		if self.m_menu_data ~= nil and #self.m_menu_data > 0 then
			for i, v in pairs(self.m_menu_data) do
				if self:getServerIsOnlineOnDEV(v.zone_id) then
					table.insert(self.menu_list,v)
				end
			end
		end
	end
	return self.menu_list
end

--判断服务器是否有在线和维护状态的区服
function M:getServerIsOnline(zone_id)
	local server_list = self.zone_map_ids[zone_id]
	for i, v in pairs(server_list) do
		if v.is_open == 1 or v.is_open == 0 then
		--if v.is_open == "Online" or v.is_open == "InMaintenance" then
			return true
		end
	end
	return false
end

function M:getServerIsOnlineOnDEV(zone_id)
	local server_list = self.zone_map_ids[zone_id]
	for i, v in pairs(server_list) do
		if v.is_open == 1  then
			return true
		end
	end
	return false
end

--推荐区服
function M:getRecommend()
	local server_data = UserDataManager.server_data:getAllServerData()
	local recommend_server = {}
	for i, v in ipairs(server_data) do
		local tags = v.tags
		for i, tag in ipairs(tags) do
			if tag.tag_value == 1001 then
				table.insert(recommend_server,v)
			elseif tag.tag_value == 1101 then
				table.insert(recommend_server,v)
			end
		end
	end
	return recommend_server
end

return M