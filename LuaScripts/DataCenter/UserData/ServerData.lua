------------ ServerData
local M = {
	server_data = nil,
	sid = nil,
	portal_server_address_data = nil,
	select_server_info = nil,
	server_list_index = 1,
	all_server_data = {},
	last_server_data = {},
	all_role_data = {},
	domain_list = {},
	select_domain_index = 1,
	audit_vsn = nil, -- 提审版本号
	review_vsn = nil, -- 新的提审版本号
	is_new = false, --是否是新服务器数据
	no_server_info = "No server!!",
}

--是否是新服务器数据
function M:getIsNewServerData()
	return self.is_new
end

-- 设置服务器数据
function M:setServerData(serverdata)
	if type(serverdata) ~= "table" then return end
	self.server_data = serverdata
	--local domain_str = "https://wl-dev-2.dailygn.com/wl/s1002;https://wl-dev-2.dailygn.com/wl/s1002"
	local domain_str = self.server_data.domain or ""
	if domain_str ~= "" then
		self.domain_list = string.split(domain_str, ";")
	else
		self.domain_list = {}
	end
	if self.is_new and #self.domain_list == 0 then
		local cur_domain_list = self:getDomainListByServerId(serverdata.server)
		local temp_domain_list = {}
		for i, v in pairs(cur_domain_list) do
			temp_domain_list[i] = self:checkUrlLastWord(v) .. "s" .. serverdata.server
		end
		self.domain_list = temp_domain_list
	end
	if #self.domain_list > 0 then
		self.select_domain_index = math.random(1, #self.domain_list)
		--self.select_domain_index = 1
		GameVersionConfig.SERVICE_URL = self.domain_list[self.select_domain_index]
	else
		Logger.logErrorAlways(self.server_data, "domain is error : ")
	end
end
--检查url最后一个字母是不是/ 如果不是 拼上一个/
function M:checkUrlLastWord(str_url)
	local str_url = str_url or ""
	if string.sub(str_url, -1) ~= "/" then
		str_url = str_url .. "/"
	end
	return str_url
end

--根据服务器id获取当前服务器区间的servers_hosts，对应原来的domain_list
function M:getDomainListByServerId(server_id)
	local domain_list = {}
	local server_id = tonumber(server_id)
	if self.select_server_info and self.select_server_info.servers_hosts then
		for i, v in pairs(self.select_server_info.servers_hosts) do
			local server_range = string.split(i, "-")
			if server_range and server_range[1] and type(tonumber(server_range[1])) == "number" then
				if server_id >= tonumber(server_range[1]) and server_id <= tonumber(server_range[2]) then
					return v
				end
			end
		end
		return self.select_server_info.servers_hosts.default or domain_list
	end
	return domain_list
end

-- 切换业务服务器地址
function M:switchDomainUrl()
	if #self.domain_list > 0 then
		self.select_domain_index = self.select_domain_index + 1
		if self.select_domain_index > #self.domain_list then
			self.select_domain_index = 1
		end
		GameVersionConfig.SERVICE_URL = self.domain_list[self.select_domain_index]
	end
end

-- 获取服务器数据
function M:getServerData()
	return self.server_data
end


--获取开服时间(时间戳)
function M:getServerOpenTimeStamp()
	return self.server_data.open_time or 0;
end


--获取开服时间
function M:getServerOpenTime()
	local time = self.server_data.open_time or 0;
	return TimeUtil.gmTime(time)
end


function M:setUserSid(sid)
	self.sid = sid
end

-- 获取玩家sid
function M:getUserSid()
	if self.sid then
		return self.sid
	else
		return ""
	end
end

-- 获取当前服务器id
function M:getServerId()
	if self.server_data then
		return self.server_data.server
	else
		return ""
	end
end

--获取当前服务器名称
function M:getServerName()
	if self.server_data then
		return self.server_data.server_name
	else
		return ""
	end
end


-- 所有服务器数据
function M:setPortalServerAddressData(data)
	if data == nil then return end
	self.portal_server_address_data = data
	self.audit_vsn = data.audit_vsn
	self.review_vsn = data.review_vsn  -- 新的提审版本号
	local spVersion = nil
	if data[SDKUtil.sdk_params.applicationId .."_".. GameVersionConfig.CLIENT_VERSION] ~= nil then
		spVersion = data[SDKUtil.sdk_params.applicationId .."_".. GameVersionConfig.CLIENT_VERSION]
	elseif data[SDKUtil.sdk_params.applicationId .."_all"] ~= nil  then
		spVersion = data[SDKUtil.sdk_params.applicationId .."_all"]
	end
	local is_new = false
	local server_info = {}
	local error_msg = "server_info is empty"
	--版本号等于提审版本号 且 有新提审数据的字段
	if spVersion ~= nil and data[spVersion] ~= nil then
		server_info = data[spVersion]
		is_new = true
	elseif GameVersionConfig.CLIENT_VERSION == self.review_vsn then
		local review_vsn_server_key = "review_vsn-" .. tostring(self.review_vsn)
		server_info = data[review_vsn_server_key] or data.default_review_vsn
		--提审服新字段可能有两种格式，一种带有resource_hosts字段的最新格式，一种是旧数据
		if server_info and server_info.resource_hosts then--提审服新数据中有新的数据字段走新逻辑
			is_new = true
		elseif server_info and #server_info > 0 then--否则走旧数据
			is_new = false
		else
			error_msg = "review_vsn audit_server_info is empty"
		end
	elseif  GameVersionConfig.CLIENT_VERSION == self.audit_vsn  then --需要进提审服 版本号等于提审版本号但只有旧的audit_server_info字段，走旧逻辑
		if data.audit_server_info and #(data.audit_server_info) > 0 then
			is_new = false
			server_info = data.audit_server_info
		else
			error_msg = "audit_server_info is empty"
		end
	else --不进提审服
		if data.default_normal and next(data.default_normal) then
			is_new = true
			server_info = data.default_normal
		elseif data.server_info and #(data.server_info) > 0 then
			is_new = false
			server_info = data.server_info
		end
	end
	self.is_new = is_new
	if next(server_info) and is_new then
	self:setSelectServerInfoNew(server_info)
	elseif #(server_info) > 0 and not(is_new) then
		self:setSelectServerInfo(server_info[1])
		else
		Logger.logErrorAlways(data,error_msg)
		end
end

function M:getPortalServerAddressData()
	return self.portal_server_address_data
end

-- 公告地址
function M:getNoticeUrl()
	if self.portal_server_address_data then
		return self.portal_server_address_data.noticeurl
	end
end

-- 所有服务器的列表
function M:getServerInfo()
	if self.portal_server_address_data then
		return self.portal_server_address_data.server_info
	end
end

--  设置选择的服务器信息
function M:setSelectServerInfo(data)
	if data == nil then return end
	self.select_server_info = data
	local server_list = data.server_list or {}
	if #server_list > 0 then
		self.server_list_index = 1
		GameVersionConfig.MASTER_URL = server_list[self.server_list_index]
	else
		Logger.logErrorAlways(data,"setSelectServerInfo server list not found")
	end
end


--新的服务器数据格式，重新组装成和旧数据同一结构，不同的是新增了servers_hosts config_url resource_url 三个字段
function M:setSelectServerInfoNew(data)
	if data == nil then return end
	local server_list = data.server_host_list or {} --对应原来的server_list
	local configurl = {} --配置对应的ip list 和资源一样都是resource_hosts
	local resourceurl = {} --资源对应的ip list
	local servers_hosts = data.servers_hosts or {} --API 功能接口的头， 按服务器id取
	local resource_url = data.resource_url or "" --新数据格式中 下载资源的url需要拼接的字段
	local config_url = data.config_url or ""--新数据格式中 下载配置的url需要拼接的字段
	self.no_server_info = data.maintain_notices and data.maintain_notices or "no server!!"
	if data.maintain_flag ~= nil and data.maintain_flag == 1 then
		if data.maintain_openid ~= nil and #data.maintain_openid > 0 and SDKUtil.sdk_params.uid ~= nil then
			server_list = {}
			for i, v in pairs(data.maintain_openid) do
				if v == SDKUtil.sdk_params.uid then
					server_list = data.server_host_list or {}
					break
				end
			end
		else
			server_list = {}
		end
	end
	for i, v in pairs(data.resource_hosts) do
		resourceurl[#resourceurl + 1] = v .. resource_url
		configurl[#configurl + 1] = v .. config_url
	end
	self.select_server_info = { server_list = server_list, configurl = configurl, resourceurl = resourceurl, servers_hosts = servers_hosts }
	if #server_list > 0 then
		self.server_list_index = math.random(1, #server_list)
		GameVersionConfig.MASTER_URL = server_list[self.server_list_index]
	else
		Logger.logErrorAlways(data,"setSelectServerInfo server list not found")
	end
end

--  切换主地址
function M:switchMasterUrl()
	if self.select_server_info then
		local server_list = self.select_server_info.server_list or {}
		local len = #server_list
		if len > 1 then
			self.server_list_index = self.server_list_index + 1
			if self.server_list_index > len then
				self.server_list_index = 1
			end
			GameVersionConfig.MASTER_URL = server_list[self.server_list_index]
		else
			Logger.logErrorAlways(self.select_server_info,"switchMasterUrl server list not found")
		end
	end
end

--  选择的服务器信息
function M:getSelectServerInfo()
	return self.select_server_info
end

--  获取下载配置的url
function M:getConfigUrl()
	if self.select_server_info then
		return self.select_server_info.configurl or {}
	end
	return {}
end

--  获取下载配置的url
function M:getResourceUrl()
	if self.select_server_info then
		return self.select_server_info.resourceurl or {}
	end
	return {}
end

--设置全部服务器数据
function M:setAllServerData(data)
	self.all_server_data = data or {}
end

--获取全部服务器数据  
function M:getAllServerData()
	return self.all_server_data
end

--通过服务器id获取服务器数据 
function M:getServerDataById(server_id)
	for i, v in ipairs(self.all_server_data) do
		if v.server == server_id then
			return v
		end
	end
	return nil
end

--设置上次登录服务器
function M:setLastServer(data)
	self.last_server_data = data or {}
end

--获取上次登录服务器
function M:getLastServer()
	return self.last_server_data
end

function M:getFirstServer()
	local first_server = nil
	local role = nil
	if #self.last_server_data > 0 then
		first_server = self.last_server_data[1].zone
		role = self.last_server_data[1].role or {}
	else
		table.sort(self.all_server_data,function(data1,data2)
			return data1.open_time > data2.open_time
		end)
		for i, v in ipairs(self.all_server_data) do
			if v.is_open == "Online" then
				first_server = v
				return first_server,{}
			end
		end
		role = {}
	end
	return first_server, role
end

--设置全部角色信息
function M:setAllRoleData(data)
	self.all_role_data = data or {}
end

--获取全部角色信息
function M:getAllRoleData()
	return self.all_role_data
end

function M:getServerNameById(server_id)
	for i, v in pairs(self.all_server_data) do
		if tostring(v.server) == tostring(server_id) then
			return v.server_name
		end
	end
	return ""
end

return M