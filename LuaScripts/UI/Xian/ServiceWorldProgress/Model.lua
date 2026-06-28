local M = class("ServiceWorldProgressModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("stage_server_level_index")
end

function M:onEnter()
	self.m_max_stage_id = self.m_data.max_stage_id --区服最大关卡id
	self.m_pass_count = self.m_data.pass_data --通关人数
	self.serverOpenTime = self:getOpenTimeDays(); --开服时间
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


--获取活动数据
function M:getListData()
	local server_level = ConfigManager:getCfgByName("server_level")
	local level = {}
	for i, v in pairs(server_level) do
		local serverList = {  }
		serverList.cfg = v
		serverList.stage_id = i
		table.insert(level,serverList)
	end
	table.sort(level,function(data1,data2)
		return data1.stage_id < data2.stage_id
	end)
	return level
end

--获取关卡通关人数
function M:getPassCount(state_id)
	for i, v in pairs(self.m_pass_count) do
		if i == tostring(state_id) then
			return v
		end
	end
end

--获取当前通关的关卡数
function M:getCurrentPostion()
	local current_state = UserDataManager:getCurStage()
	local listData = self:getListData()
	local state_num = nil
	for i, v in ipairs(listData) do
		if state_num == nil then
			state_num = current_state-v.stage_id
		else
			local Difference = current_state - v.stage_id
			if Difference < state_num and Difference > 0 then
				state_num = v.stage_id
			end
		end
	end
	return state_num
end

--更新数据
function M:updateServerData(serverData)
	table.merge(self.m_data,serverData)
end

--判断宝箱是否领取
function M:hasReward(stage_id)
	for i, v in pairs(self.m_data.server_level_rcvd) do
		if v == stage_id then
			return true
		end
	end
	return false
end

--计算上一档时间
function M:lastUnlock(stage_id)
	local listData = self:getListData()
	for i, v in ipairs(listData) do
		if stage_id == self:getFirstId() then
			return 0
		elseif stage_id == v.stage_id then
			return listData[i-1].cfg.unlock
		end
	end
end

--计算第一个关卡的id
function M:getFirstId()
	local listData = self:getListData()
	for i, v in ipairs(listData) do
		if i == 1 then
			return v.stage_id
		end
	end
end

--获取正在进行中的id
function M:setCompletIndex()
	local datalist = self:getListData()
	local index = 0
	for i, v in ipairs(datalist) do
		if v.cfg.unlock <= self:getOpenTimeDays() then
			if i > index then
				index = i
			end
		else
			self.lastCompletIndex = index
			return index+1
		end
		--local pass_count = self:getPassCount(v.stage_id)
		--if pass_count ~= nil and pass_count >= v.cfg.unlock_player then --判断通关人数是否符合
		--	if i > index then
		--		index = i
		--	end
		--elseif self:hasReward(v.stage_id) then
		--	if i > index then
		--		index = i
		--	end
		--else
		--	self.lastCompletIndex = index
		--	return index+1
		--end
	end
	self.lastCompletIndex = index
	return index+1
end

--获取当前通关展示id
function M:setCurrentIndex()
	local datalist = self:getListData()
	local curStage = UserDataManager:getCurStage()
	local current_Index = 1
	for i, v in ipairs(datalist) do
		if v.stage_id <= curStage then
			current_Index = i
		end
	end
	return current_Index
end

--获取展示数据
function M:getDataListData()
	local data = {}
	local end_id = self:setCompletIndex()+1
	local current_id = self:setCurrentIndex()+1
	local level_id = end_id
	if current_id > end_id then
		level_id = current_id
	end
	local serverList = self:getListData()
	for i, v in ipairs(serverList) do
		if i <= level_id then
			table.insert(data,v)
		end
	end
	return data
end

return M
