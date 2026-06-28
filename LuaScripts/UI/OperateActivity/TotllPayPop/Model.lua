local M = class("TotllPayPopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self:getData("continuous_index")
end

function M:onEnter()
	self.m_continuous_data = self.m_data.continuous_payment
	StatisticsUtil:doPointActive(79,self.m_continuous_data.version)
	self.max_day = self:getMaxRecharge()
	self.m_cmlt_actives= self.m_data.actives
end

function M:get_gontinuous_cfg()
	local recharge_tab = ConfigManager:getCfgByName("last_recharge")
	if self.m_continuous_data == nil then
		return
	end
	local new_tab = {}
	local server_tab = table.copy(recharge_tab[self.m_continuous_data.version])
	for k,v in pairs(server_tab) do
		if k <= self.max_day then
			local version_tab = recharge_tab[self.m_continuous_data.version]
			local cfg = version_tab[tonumber(k)]
			cfg.id = tonumber(k)
			cfg.server_reward = v.reward
			table.insert(new_tab,cfg)
		end
	end
	local function sortFunc(id_one, id_two)
		local data_one = self:getReceived(id_one.id) == 2 and 1 or 0
		local data_two = self:getReceived(id_two.id) == 2 and 1 or 0
		if data_one == data_two then
			return id_one.id < id_two.id
		else
			return data_one < data_two
		end
	end
	table.sort(new_tab, sortFunc)
	return new_tab
end

function M:getReceived(id)
	if self.m_continuous_data then
		for k,v in pairs(self.m_continuous_data.days) do
			if id == tonumber(k) then
				return v.status
			end
		end
		return 0
	end
	return 0
end

function M:getRechargeById(day_id)
	if next(self.m_continuous_data) ~= nil then
		local days = self.m_continuous_data.days
		if next(days) then
			local data = days[tostring(day_id)] or {}
			return data
		end
	end
	return {}
end

function M:getRechargeDays()
	local day = 0
	if self.m_continuous_data then
		for k,v in pairs(self.m_continuous_data.days) do
			if day < tonumber(k) then
				day = tonumber(k)
			end
		end
	end
	return day
end

function M:getActiveEndTime()
	if self.m_cmlt_actives == nil then
		return -1
	end
	for k,v in pairs(self.m_cmlt_actives) do
		if v.open_status > 0 then
			return v.end_ts
		end
	end
	return -1
end

function M:getMaxRecharge()
	local recharge_tab = ConfigManager:getCfgByName("last_recharge")
	if self.m_continuous_data == nil then
		return 7
	end

	local new_tab = {}
	local server_tab = recharge_tab[self.m_continuous_data.version]
	local c_day = table.nums(self.m_continuous_data.days) + 1 or 1
	local last_day = #server_tab
	if c_day > 14 then
		c_day = 14
	end
	local rech_cfg = server_tab[c_day] or {}
	if next(rech_cfg) ~= nil then
		return rech_cfg.show_day or 7
	end 
	return 7
end

function M:getHeroBigAnimCfg()
	local recharge_tab = ConfigManager:getCfgByName("last_recharge")
	local version_tab = recharge_tab[self.m_continuous_data.version]
	local curDayCfg = {}
	if version_tab and version_tab[tonumber(self.m_continuous_data.day)] then
		curDayCfg = version_tab[tonumber(self.m_continuous_data.day)]
	end
	local cid = curDayCfg.show_hero or 501
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(cid)
	return cfg, curDayCfg
end

return M