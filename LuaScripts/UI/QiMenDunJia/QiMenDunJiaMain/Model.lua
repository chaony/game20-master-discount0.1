local M = class("QiMenDunJiaMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("gve_index") 
end

function M:onEnter()
	self.m_all_buff_value = 0
	self:initAllBuffValue()
end

--主页
function M:updateMainData(data)
	table.merge(self.m_data, data)
	self:initAllBuffValue()
end

--- 网络数据回调，用这个model请求网络数据，在自定义callback调用之前，这个函数会被调用
function M:netData(data, tag)
	table.merge(self.m_data.cells or {}, data.cells or {})
	data.cells = nil
	table.merge(self.m_data.passed or {}, data.passed or {})
	data.passed = nil
	table.merge(self.m_data, data)
	self:initAllBuffValue()
end

function M:getMainData()
	return self.m_data or {}
end

function M:getVersion()
	return self.m_data.ver or 0
end

function M:getExploreProgress()
	return self.m_data.explore_value or 0
end

function M:hasRelics()
	if next(self.m_data.guild_relics or {}) then
		return true
	end
	return false
end

function M:updateCustomMassifID(cell_ID)
	local cell_data = self.m_data.cells[tostring(cell_ID)] or {}
	self.m_data.custom_massif_id = cell_data.massif_id or 0
end

-- 正在打扫战场的英雄配置id
function M:getLockHids()
	return self.m_data.lock_hids or {}
end

-- >0:需要设置打扫战场的英雄
function M:updateLockOne(lock_value)
	self.m_data.lock_one = lock_value
end

function M:getLockOne()
	return self.m_data.lock_one or 0
end

function M:updateBuyTimes(value)
	self.m_data.buy_times = self.m_data.buy_times - value
end

function M:getBuyTimes()
	return self.m_data.buy_times
end

function M:updateStrength(value)
	self.m_data.health = self.m_data.health + value
end

function M:setStrength(value)
	self.m_data.health = value
end

function M:getStrength()
	return self.m_data.health
end

function M:initAllBuffValue()
	self.m_all_buff_value = 0
	local buff_data
	for k, v in pairs(self.m_data.effect_buff or {}) do
		buff_data = self:getMassifBuffCfg(k)
		if buff_data then
			self.m_all_buff_value = self.m_all_buff_value + buff_data.buffid_show * v
		end
	end
end

function M:getMassifBuffCfg(buff_ID)
	buff_ID = tonumber(buff_ID) or 0
	local massif_tab = ConfigManager:getCfgByName("gve_massif")
	for k, v in pairs(massif_tab) do
		if v.buffid == buff_ID then
			return v
		end
	end
end

function M:getAllBuffValue()
	return self.m_all_buff_value
end

function M:getRemainBuyTimes()
	local vip = UserDataManager.user_data:getUserStatusDataByKey("vip")
	local vip_config = ConfigManager:getCfgByName("vip")[vip]
	local remain_times =  vip_config.gve_time - self.m_data.buy_times
	return math.max(remain_times, 0)
end

function M:getCostType()
	local cost_type = {107, 0, 1000}
	local renovate_config = ConfigManager:getCfgByName("renovate");
	local cost_config = renovate_config[20]
	if cost_config then
		local cost_index = 1
		for i, v in ipairs(cost_config.count_list) do
			if self.m_data.buy_times < v then
				cost_index = i;
				break;
			end
		end
		cost_type = cost_config.cost[cost_index]
	end
	return cost_type
end

function M:getCost(num)
	local cost = 0
	local renovate_config = ConfigManager:getCfgByName("renovate");
	local cost_config = renovate_config[20]
	if cost_config then
		local buy_times = self.m_data.buy_times or 0
		local real_num = num + buy_times

		local count_length = #cost_config.count_list
		for i = buy_times + 1, real_num do
			local index = 1
			for j = count_length, 1, -1 do
				if i <= cost_config.count_list[j] then
					index = j
				else
					break
				end
			end
			cost = cost + cost_config.cost[index][3]
		end
	end
	return cost
end

function M:getVip()
	return UserDataManager.user_data:getUserStatusDataByKey("vip")
end

function M:hasGuildReward()
	local gve_guild_reward = UserDataManager:getRedDotByKey("gve_guild_reward")
	return gve_guild_reward == 1
end

function M:hasTaskReward()
	local gve_quest = UserDataManager:getRedDotByKey("gve_quest")
	return gve_quest == 1
end

return M
