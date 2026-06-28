local M = class("ServiceJiangHuPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.current_data = self.m_params.current_data --配置数据信息
	self.server_level = self.m_params.server_level --排名信息数据
	self.tip_word = self.m_params.tip_word --提示语
	self.serverOpenTime = self:getOpenTimeDays() --开服天数
	self.lastUnlock = self.m_params.lastUnlock -- 上一id
	--Logger.logError(self.current_data,"配置数据")
	--Logger.logError(self.server_level,"服务器数据")
	--Logger.logError(self.tip_word,"标识")
	--Logger.logError(self.lastUnlock,"上一id")
end

--更新数据
function M:updateServerData(serverData)
	self.server_level.server_level_rcvd = serverData.server_level_rcvd
	self.server_level.max_stage_id = serverData.max_stage_id
end

function M:getOpenTimeDays()
	--开服的天数
	local open_server_date = UserDataManager.server_data:getServerOpenTime();
	--当前服务器天数
	local cur_server_date = TimeUtil.gmTime(UserDataManager:getServerTime())
	--开服天数
	local open_server_yearOfDay = open_server_date.yday
	--开服年
	local open_server_year = open_server_date.year
	--当前服务器天数
	local cur_server_yearOfDay = cur_server_date.yday
	--当前服务器年
	local cur_server_year = cur_server_date.year
	--如果当前服务器和开服是同一年
	if open_server_year == cur_server_year then
		return cur_server_yearOfDay - open_server_yearOfDay + 1;
	else
		local year_cha = cur_server_year - open_server_year;
		return year_cha * 365 - open_server_yearOfDay + cur_server_yearOfDay + 1
	end
end

--获取上一个关卡数据
function M:getLastLevel(stage_id)
	local level = 10000000
	local lastUnlock = 0
	local server_level = ConfigManager:getCfgByName("server_level")
	for i, v in pairs(server_level) do
		if stage_id - i > 0 and stage_id - i < level then
			level = stage_id - i
			lastUnlock = i
		end
	end
	return lastUnlock
end

--判断宝箱是否领取
function M:hasReward(stage_id)
	local current_server_level = self.server_level.server_level_rcvd
	if self.server_level.server_level_rcvd == nil then
		current_server_level = self.m_params.server_level_rcvd
	end
	for i, v in pairs(current_server_level) do
		if v == stage_id then
			return true
		end
	end
	return false
end

--设置排行榜数据
function M:setServerData()
	local serverData = {}
	for i = 1, 10 do
		if self.server_level.ranks[i] ~= nil then
			table.insert(serverData,self.server_level.ranks[i])
		else
			if i <= 3 then
				local user = {}
				user["rank"] = i
				table.insert(serverData,user)
			end
		end
	end
	return serverData
end

return M
