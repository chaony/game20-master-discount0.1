local M = class("YinTowerRewardPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_cur_element = self.m_params or 1
	--付费开启次数
	self.m_open_times = self.m_params.open_times;
	--剩余免费激活次数
	self.m_remain_times = self.m_params.remain_times;
	--是否完成
	self.finish = self.m_params.finish;
	--首通奖励
	self.first_reward = self.m_params.first_reward;
	--通过vip获取,额外购买次数
	self.m_ex_buy_time = ConfigManager:getVipValueByKey("four_tower_challenge_times",1)

	local renovate = ConfigManager:getCfgByName("renovate")
	self.m_buy_data = renovate[14];
	--奖励
	self.m_reward = self.m_params.reward;
	if self.first_reward ~= nil then
		for i, v in ipairs(self.first_reward) do
			table.insert(self.m_reward,1, v)
		end
	end
	Logger.logError(" vip数据 ~~~~~~~~~~~~ "..self.m_ex_buy_time)
	Logger.logError(self.m_params," 传入数据 ~~~~~~~~~~~~ ")
	Logger.logError(self.m_buy_data," 购买数据 ~~~~~~~~~~~~ ")
end

--是否是首通奖励
function M:isFristReward( data )
	if self.first_reward ~= nil then
		for i, v in ipairs(self.first_reward) do
			if data[1] == v[1] and data[2] == v[2] and data[3] == v[3] then
				return true;
			end
		end
	end
	return false;
end


--获取奖励列表
function M:getAllGifts()
	return self.m_reward;
end


function M:updateModelData( data )
	--扫荡次数
	self.m_open_times = data.open_times;
	--剩余次数
	self.m_remain_times = data.remain_times;
end


--获取免费次数
function M:getFreeTime()
	local free = self.m_remain_times;
	if free <= 0 then
		free = 0;
	end
	return free;
end

--获取额外开启次数
--扫荡次数
function M:getBuyTime()
	local buy_time = self.m_ex_buy_time - self.m_open_times;
	if buy_time <= 0 then
		buy_time = 0;
	end
	return buy_time;
end

--获取消耗数据
--额外购买次数 buyTime
function M:getCostData( buyTime )
	if buyTime <= 0 then
		return self.m_buy_data.cost[1]
	else
		local num = self.m_buy_data.count_list[buyTime]
		if num == nil then
			buyTime = self.m_buy_data.count_list[#self.m_buy_data.count_list]
		end
		return self.m_buy_data.cost[buyTime]
	end
end


return M
