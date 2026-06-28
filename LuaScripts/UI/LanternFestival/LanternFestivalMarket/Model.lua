local M = class("LanternFestivalMarketModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_help_id = self.m_params.help_id or ""
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params
	--self:initData(self.m_params)
end

function M:initData(response)
	if response then
		table.merge(self.m_data,response)
	end
end

--神飨兑换
function M:get_eat_exchange_cfg(version)
	local exchange_tab = ConfigManager:getCfgByName("active_exchange")
	if exchange_tab[version] then
		return exchange_tab[version or 1]
	end
	return exchange_tab[1]
end

function M:canExchange(cell_data)
	local can_exchange = false
	local satisfy_bl = false --满足要求
	for k,v in pairs(cell_data.need_reward) do
		local need_data = RewardUtil:getProcessRewardData(v)
		if need_data.data_num > need_data.user_num then--道具不足 
			satisfy_bl = true --不满足要求
		end
	end

	local need_data = RewardUtil:getProcessRewardData(cell_data.need_reward[1])
	local data = self:getEatExchangeData(self.m_version, cell_data.id)
	local num = cell_data.times - data --剩余兑换次数
	if cell_data.times > 0 and num <= 0 then --无剩余兑换次数
		return 0
	end
	if satisfy_bl == true then--道具不足
		return 0
	end
	return 1
end

--神飨兑换奖励列表
function M:get_eat_exchange_limit_cfg(version)
	local exchange_limit_tab = ConfigManager:getCfgByName("lantern_exchange")
	local version_tab = exchange_limit_tab[version]
	local new_tab = {}
	local cur_season = UserDataManager:getCurSeason()
	local self_vip = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
	local season_condition_flag = false
	for i = 1, #version_tab do
		local cur_cfg = table.copy(version_tab[i]) 
		cur_cfg.id = i
		season_condition_flag = false
		if cur_cfg.season1 and cur_cfg.season and cur_cfg.vip then
			if cur_cfg.season1 == -1 then
				if cur_cfg.season <= cur_season and cur_cfg.vip <= self_vip then
					season_condition_flag = true
				end
			elseif cur_cfg.season1 == cur_season and cur_cfg.vip <= self_vip then
				season_condition_flag = true
			end
		end
		local can_exchange = self:canExchange(cur_cfg)
		cur_cfg.can_exchange = can_exchange
		if season_condition_flag == true then
			table.insert(new_tab, cur_cfg)
		end
	end
	local function sortFunc(id_one, id_two)
		local data_1 = self:getEatExchangeData(version, id_one.id)
		local data_2 = self:getEatExchangeData(version, id_two.id)
		local time1 = 1
		local time2 = 1
		if id_one.times > 0 and data_1 >= id_one.times then
			time1 = 0
		end
		if id_two.times > 0 and data_2 >= id_two.times then
			time2 = 0
		end
		if id_two.can_exchange == id_one.can_exchange then
			if time1 == time2 then
				return id_one.id < id_two.id
			else
				return time1 > time2
			end
		else
			return id_one.can_exchange > id_two.can_exchange
		end
	end
	table.sort(new_tab, sortFunc)
	return new_tab
end

function M:getEatExchangeData(ver, id)
	if self.m_data.exchange ~= nil then
		for k, v in pairs(self.m_data.exchange) do
			if k == tostring(id) then
				return v
			end
		end
	end
	return 0
end

return M
