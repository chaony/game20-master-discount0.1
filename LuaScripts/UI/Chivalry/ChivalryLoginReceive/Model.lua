local M = class("ChivalryLoginReceiveModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.open_id = self.m_params.open_id or 386
	self.version = self.m_params.version or 1
	local params = {}
	params.open_id = self.open_id
	params.vsn = self.version
	self:getData("war_order_common_war_order_index",params)
end

function M:onEnter()
	self.is_tokens = self.m_params.is_token or false
	self.current_tab = 1
	self.m_recv_chivalrous = self.m_params.recv_chivalrous or {}
	self.m_current_day = self:setCurrentDay()
end

function M:getVersion()
	return self.version
end

function M:updateData(data)
	if data then
		table.merge(self.m_data, data)
	end
	local tongyong_warrior_reward = ConfigManager:getCfgByName("tongyong_warrior_reward")
	if tongyong_warrior_reward[self.open_id] then
		if self.m_data.war_order and self.m_data.war_order.cur_version then
			self.tongyong_warrior_reward = tongyong_warrior_reward[self.open_id][self.m_data.war_order.cur_version]
		end
	end
end


--获取奖励
function M:getRewardBoxData()
	local tongyong_warrior_reward = ConfigManager:getCfgByName("tongyong_warrior_reward")
	
	local reward_node = {}
	for i, v in pairs(tongyong_warrior_reward[self.open_id][self.version]) do
		local status_reward_1 = -1 -- 免费奖励 -1：未开启  1：可领取  2：已领取
		local status_reward_2 = -1 -- 付费奖励 -1：未开启  1：可领取  2：已领取
		if i <= self.m_current_day  then
			status_reward_1 = self:getFreeReceiveStaue(i) == 2 and 2 or 1
			status_reward_2 = self:getPayReceiveStaue(i) == 2 and 2 or 1
		end
		table.insert(reward_node,{id = i,cfg = v,status_reward_1 = status_reward_1,status_reward_2 = status_reward_2})
	end
	return reward_node
end

--获取购买战力价格
function M:getBuyWarPrice()
	local war_order = ConfigManager:getCfgByName("war_order")
	if war_order[self.open_id] then
		return war_order[self.open_id].price
	else
		Logger.logError("war_order 表没有"..self.open_id.."对应的数据")
	end
	return 0
end

--获取购买战力购买项
function M:getBuyWarChargeId()
	local war_order = ConfigManager:getCfgByName("war_order")
	if war_order[self.open_id] then
		return war_order[self.open_id].charge_id
	else
		Logger.logError("war_order 表没有"..self.open_id.."对应的数据")
	end
	return 0
end


--获取活动数据
function M:getActiveData(open_id)
	local id = self.open_id
	if open_id then
		id = open_id
	end
	local active_tab = ConfigManager:getCfgByName("active")
	for i, v in pairs(active_tab) do
		if v.open_id == id and v.version == self.version then
			return v
		end
	end
	return nil
end

--获取免费奖励领取状态
function M:getFreeReceiveStaue(id)
	for i, v in ipairs(self.m_data.war_order.free_received) do
		if v == id then
			return 2
		end
	end
	return false
end

--获取战令奖励领取状态
function M:getPayReceiveStaue(id)
	for i, v in ipairs(self.m_data.war_order.pay_received) do
		if v == id then
			return 2
		end
	end
	return false
end

--计算时间
function M:setCurrentDay()
	local cur_tim = UserDataManager:getServerTime() --当前时间
	local surplus_time = cur_tim - self.m_data.war_order.start_ts --从活动开始到当前时间的差值
	local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算活动开启时间
	remain_day = remain_day + 1
	if remain_day < 1 then
		remain_day = 1
	elseif remain_day > 10 then
		remain_day = 10
	end
	return remain_day
end



return M
