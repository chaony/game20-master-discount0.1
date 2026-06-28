local M = class("QiXiGiftMoonModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_is_token = self.m_params.is_token or false
	self:getData("valentine_festival_moon_index")
end

function M:onEnter()
	self.open_id = self.m_params.open_id or 376
	self:InitData()
end

function M:getVersion()
	return self.m_version
end

function M:getTokenFlag()
	return self.m_is_token
end

function M:netData(data, tag)
	table.merge(self.m_data, data or {})
	self:InitData()
end

function M:InitData()
	self.m_version = self.m_data.version or 0
	self.score = self.m_data.score or 0
	self:setIsReceive(self.m_data.received)
end


--获取活动数据
function M:getActiveData()
	local active_tab = ConfigManager:getCfgByName("active")
	for i, v in pairs(active_tab) do
		if v.open_id == self.open_id and v.version == self.m_version then
			return v
		end
	end
	return nil
end

--获取累计亲密度
function M:getIntegra()
	local hero_event = ConfigManager:getCfgByName("moon_reward")
	return hero_event[self.m_version].integra1 or 0
end

--获取个人亲密度
function M:getPeopleIntegra()
	local event = ConfigManager:getCfgByName("moon_reward")
	return event[self.m_version].integra2 or {}
end

--获取奖励
function M:getReward()
	local event = ConfigManager:getCfgByName("moon_reward")
	return event[self.m_version].reward or {}
end

--设置奖励领取状态
function M:setIsReceive(isReceive)
	self.isReceive = isReceive
end

--获取奖励领取状态
function M:getIsReceive()
	return self.isReceive or 0
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

return M
