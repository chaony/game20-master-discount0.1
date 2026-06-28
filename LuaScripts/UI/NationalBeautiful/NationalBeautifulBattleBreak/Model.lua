local M = class("NationalBeautifulBattleBreakModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_is_token = self.m_params.is_token or false
	self.m_open_id = self.m_params.open_id or 411
	self.active_data = self.m_params.active_data or {}
	self.m_version = self.m_params.version or 1
	self.m_data = {}
	self.m_data.self_attack_times = self.m_params.data.self_attack_times or 0 --个人击破次数
	self.m_data.all_attack_times = self.m_params.data.all_attack_times or 0 --总击破次数
	self.m_data.received_attack_reward = self.m_params.data.received_attack_reward or {} --领取的击破奖励
	self:getData()
end

function M:onEnter()
	
end

function M:getVersion()
	return self.m_version
end

function M:getTokenFlag()
	return self.m_is_token
end

function M:netData(data, tag)
	table.merge(self.m_data, data or {})
end

--读取数据
function M:readMilepost()
	local diamond_milepost = ConfigManager:getCfgByName("active_train_attack_quest")
	return diamond_milepost[self.m_open_id][self.m_version]
end


--获取里程碑数据
function M:getMilepostData()
	local diamond_milepost = self:readMilepost()
	local show_data = {}
	local current_data = diamond_milepost[1] or {}
	for i, v in ipairs(current_data) do
		local status = 0
		if self.m_data.all_attack_times >= v.times then --是否符合条件
			local reward_is_receive = self:getRewardStatus(i)
			if reward_is_receive then
				status = 2
			else
				status = 1
			end
		end
		table.insert(show_data,{id = i,cfg = v,status = status})
	end
	return show_data
end

--获取奖励领取状态
function M:getRewardStatus(id)
	for i, v in ipairs(self.m_data.received_attack_reward) do
		if v == id then
			return true
		end
	end
	return false
end

--获取当前里程位置
function M:getCurrentMilepost()
	local diamond_milepost = self:readMilepost()
	local current_milepost_id = 0
	for i, v in ipairs(diamond_milepost[self.m_version]) do
		if v.score < self.m_data.score then
			current_milepost_id = i
		elseif v.score == self.m_data.score then
			return i
		end
	end
	return current_milepost_id
end

----活动剩余时间
function M:getTimeLeft()
	local left_time = 0
	local activity_info = UserDataManager:getActivesDataByOpenId(self.open_id)
	if activity_info then
		local server_time = UserDataManager:getServerTime()
		local end_time = activity_info.end_ts
		left_time = end_time - server_time
	end
	return left_time
end

--获取spine信息
function M:getSkinData()
	local diamond_milepost = self:readMilepost()
	local skin_id = 60501
	if diamond_milepost then
		skin_id = diamond_milepost[1][1].hero_spine
	end
	local hero_skin = ConfigManager:getCfgByName("hero_skin")
	return hero_skin[skin_id] or {}
end

return M
