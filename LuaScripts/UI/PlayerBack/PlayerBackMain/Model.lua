local M = class("PlayerBackMainModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_callback = self.m_params.callback
	self.m_callback_new = self.m_params.callback_new
	self.m_comeback_log_data = {}
	self:updateServerData()
end

function M:updateServerData()
	--设置回归记录数据
	local account = UserDataManager.client_data.user_account
	local server = UserDataManager.server_data:getServerId()
	local params = {account = tostring(account), server = tostring(server)}
	local function netCallback(response)
		if response then
			self.m_comeback_log_data = response.comeback_log or {}
		end
	end
	StatisticsUtil:doPoint("clickEnterGameButton")
	self:getNetData("login_server", params, netCallback, nil, true)

	--设置服务器数据
	if SDKUtil.is_gmsdk then 
		SDKUtil:getFetchZonesAndRolesList(
				function(params)
					if params.Zones == nil or #params.Zones == 0 then --提示重登
						GameUtil:lookInfoTips(self, {msg = "new_str_0935", delay_close = 2})
						return
					end
					UserDataManager.server_data:setAllServerData(params.Zones)
				end,
				GameVersionConfig.BYTE_DANCE_SERVER_VERSION
		)
	else
		if account then
			local params = {account = tostring(account)}
			local netCallback = function(response)
				UserDataManager.server_data:setAllServerData(response.servers)
			end
			self:getNetData("server_list", params, netCallback)
		end
	end
end

function M:getServerData()
	local server_data = {}
	local keep_out_flag = false
	local server_data_all = UserDataManager.server_data:getAllServerData()
	local server_data_self = UserDataManager.server_data:getServerData()
	for _, server_item in ipairs(server_data_all) do
		keep_out_flag = false
		if server_data_self.server == server_item.server then --过滤掉当前所在的服
			keep_out_flag = true
		end
		if SDKUtil.is_gmsdk and keep_out_flag == false then --只选择推荐服务器
			keep_out_flag = true
			local tags = server_item.tags
			for i, tag in ipairs(tags) do
				if tag.tag_value == 1001 or tag.tag_value == 1101 then
					keep_out_flag = false
					break
				end
			end
		end
		if keep_out_flag == false then --本账号已经通过这种方式进入过的服务器，不再让选择
			for _, log_item in pairs(self.m_comeback_log_data) do
				if server_item.server == log_item then
					keep_out_flag = true
					break
				end
			end
		end
		if keep_out_flag == false then
			table.insert(server_data, server_item)
		end
	end
	table.sort(server_data, function(server1, server2) return server1.open_time > server2.open_time end)
	return server_data
end

function M:getYuanBaoCount()
	local count = 0
	local turn_back_tab = ConfigManager:getCfgByName("turnback") or {}
	local vip_level_tab = ConfigManager:getCfgByName("vip") or {}
	local vip_exp = UserDataManager.comeback_vip or 0
	local vip_lev = 0
	for level, item in ipairs(vip_level_tab) do
		if vip_exp < item.exp then
			break
		end
		vip_lev = level
	end
	local new_day_money_data = {}
	if turn_back_tab[vip_lev] then
		new_day_money_data = turn_back_tab[vip_lev].new_days
	end
	for _, money_item in ipairs(new_day_money_data) do
		count = count + money_item[1][3]
	end
	return count
end

function M:getHaoGanDu()
	local haogan = 0
	local common_tab = ConfigManager:getCfgByName("common")
	if common_tab[589] and common_tab[589].value then
		haogan = math.floor(common_tab[589].value * 100)
	end
	return haogan
end


return M
