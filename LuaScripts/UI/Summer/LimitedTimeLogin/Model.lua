local M = class("LimitedTimeLoginModel",LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_day_reward = self.m_params.m_login_rcvd
	self.m_verson = self.m_params.m_verson or 1
	self.m_active_time = self.m_params.m_active_time
end

--更新服务器数据
function M:updateServerData(data)

	if data and data["end"] then
		UserDataManager.active_121_end = true
		static_rootControl:updateMsg("end_summer", nil, "Summer.SummerMain")
		
		
	end

	self.m_day_reward = data.login_rcvd

	-- redPoint_update

end

--判断奖励是否被领取
function M:hasDay( day )
	for k,v in pairs(self.m_day_reward) do
		if v == day then
			return true
		end
	end
	return false
end

--配置文件读取数据
function M:getDayData()
	local days_data = {}
	local big_reward = {}
	local chest_login = ConfigManager:getCfgByName("chest_login")
	for k,v in pairs(chest_login[self.m_verson]["days_data"]) do
		local data = v
		table.insert(days_data,data)
	end
	local big_reward_data = chest_login[self.m_verson].big_reward
	table.insert(big_reward,big_reward_data)
	return days_data,big_reward
end

return M
