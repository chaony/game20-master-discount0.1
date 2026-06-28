local M = class("TotalChargePopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self:getData("cmlt_recharge_index")
end

function M:onEnter()
	local version = 0
	if self.m_data ~= nil and self.m_data.actives ~= nil and self.m_data.actives[1] ~= nil and self.m_data.actives[1].version ~= nil then
		version = self.m_data.actives[1].version
	end
	StatisticsUtil:doPointActive(130,version)
	self.m_select_index = 1 --默认选中
	self.max_price = 1000
	self:refreshData()
	local have_red_point = false
	--默认打开有红点的
	for i,v in ipairs(self.m_mult_mlt_recharge_data) do
		if self:checRedPoint(i) == true then
			self.m_select_index = i
			have_red_point = true
			return 
		end
	end
	--没有红点 默认显示时间短的那个   时间一样？》》默认第二个
	if have_red_point == false then
		self.m_select_index = self:getNearEndTsIndex()
	end
end

function M:initData(call_back)
	local function callFunc(data, tag)
		table.merge(self.m_data, data)
		self:refreshData()
		if self.m_cmlt_recharge_data == nil then
			self.m_select_index = 1
			self:refreshData()
		end
		call_back()
	end
    self:getNetData("cmlt_recharge_index", nil, callFunc)
end

function M:refreshData() 
	local recharge = self.m_data.recharge or {}
	self.m_mult_mlt_recharge_data = {}
	self.m_actives = self.m_data.actives or {}
	for k,v in pairs(recharge) do
		v.version = tonumber(k)
		table.insert(self.m_mult_mlt_recharge_data, v)
	end
	local function sortFunc(id_one, id_two)
		return id_one.version < id_two.version
	end
	table.sort(self.m_mult_mlt_recharge_data, sortFunc)
	self.m_mult = false --是否有多期
	if #self.m_mult_mlt_recharge_data > 1 then
		self.m_mult = true
	end
	self.m_cmlt_recharge_data = self.m_mult_mlt_recharge_data[self.m_select_index]
	self.max_price = self.m_cmlt_recharge_data.value or 1000
end

--切换页签数据切换
function M:switchTag()
	self.m_cmlt_recharge_data = self.m_mult_mlt_recharge_data[self.m_select_index]
	self.max_price = self.m_cmlt_recharge_data.value or 1000
end

--累计充值
function M:get_recharge_cfg()
	if self.m_cmlt_recharge_data == nil then
		return {}
	end
	local add_recharge_tab = ConfigManager:getCfgByName("add_recharge")
	local server_tab = add_recharge_tab[self.m_cmlt_recharge_data.version or 1]
	local new_tab = {}
	for k,v in pairs(server_tab) do
		local cfg = server_tab[tonumber(k)] 
		if self.max_price >= cfg.price_show then
			cfg.id = tonumber(k)
			table.insert(new_tab, cfg)
		end
	end
	local function sortFunc(id_one, id_two)
		--已领
		local data_one = self:getCmltReceived(id_one.id) == true and 1 or 0 
		local data_two = self:getCmltReceived(id_two.id) == true and 1 or 0
		if data_one == data_two then
			if id_one.price == id_two.price then 
				return id_one.id < id_two.id
			else
				return id_one.price < id_two.price
			end
		else
			return data_one < data_two
		end
	end
	table.sort(new_tab, sortFunc)
	return new_tab
end

function M:getCmltReceived(id)
	if self.m_cmlt_recharge_data and self.m_cmlt_recharge_data.received then
		for k,v in pairs(self.m_cmlt_recharge_data.received) do
			if id == v then
				return true
			end
		end
		return false
	end
	return false
end

function M:getActiveEndTime()
	local rechare_data = self:getRechareData(self.m_select_index)
	if rechare_data == nil then
		return -1
	end
	local active_data = self:getActiveData(rechare_data.version)
	if active_data == nil then
		return -1
	end
	return active_data.end_ts
end

function M:getActiveCfg(id)
	local add_recharge_tab = ConfigManager:getCfgByName("active_recharge")
	local server_tab = add_recharge_tab[id]
	return server_tab
end

function M:getRechareData(index)
	return self.m_mult_mlt_recharge_data[index]
end

function M:getActiveData(vsn)
	for k,v in pairs(self.m_actives) do
		if vsn == v.version then
			return v
		end
	end
	return nil
end

function M:checRedPoint(index)
	if self.m_mult_mlt_recharge_data[index] then
		local add_recharge_tab = ConfigManager:getCfgByName("add_recharge")
		local recharge_data = self.m_mult_mlt_recharge_data[index]
		local server_tab = add_recharge_tab[recharge_data.version or 1]
		if server_tab then
			for k,v in pairs(server_tab) do
				local get = self:checkReceived(recharge_data, tonumber(k))
				if get == false and recharge_data.value >= v.price then
					return true
				end
			end
		end
	end
	return false
end

function M:getNearEndTsIndex()
	local end_ts = 0
	local end_id = 1
	for k,v in ipairs(self.m_mult_mlt_recharge_data) do
		local rechare_data = self:getRechareData(k)
		local active_data = self:getActiveData(rechare_data.version)
		if end_ts == 0 then
			end_ts = active_data.end_ts
			end_id = k
		else
			if active_data.end_ts <= end_ts then
				end_ts = active_data.end_ts
				end_id = k
			end
		end
	end
	return end_id
end

--是否已领取
function M:checkReceived(recharge_data, id)
	for kk,vv in pairs(recharge_data.received) do
		if id == vv then
			return true
		end
	end
	return false
end

return M