local M = class("TaoistMainModel",LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("raid_index")
end

function M:onEnter()
	self.current_playing = 1
	self.m_is_jump = self.m_params.is_jump or false --是否是通过跳转打开的页面
	--Logger.logError(self.m_data,"服务端数据")
	self.toDay_active = true
	--self.current_level_sweep = self:currentBattle() --最大可扫荡层数
	--self.current_level_battle = self:getNextBattleOrder(self.current_level_sweep) --当前可挑战层
	--self.current_level_battle_data = self:getCurrentLevelData(self.current_level_battle) --当前可挑战层数据
	--self.current_level_sweep_data = self:getCurrentLevelData(self.current_level_sweep) --当前可扫荡层数据
end


--更新数据
function M:updateServerData(serverdata)
	table.merge(self.m_data,serverdata)
end

--获取玩法关卡数据
function M:getPlayingNameData(raid_data)
	local raid_open = ConfigManager:getCfgByName("raid_open")
	local display_lecel ={}
	local server_unlock_season = 0
	local season_data = UserDataManager.m_season_data or {}
	if season_data and next(season_data) and season_data.season then
		server_unlock_season = season_data.season
	end
	for i, v in ipairs(raid_open) do
		local open_id = self:getOpenId(v.type,raid_data)
		local unlock_season = self:getSeasonUnlock(open_id)
		if unlock_season ~= nil and server_unlock_season >= unlock_season then
			table.insert(display_lecel,v)
		end
	end
	return display_lecel
end

--获取open_id
function M:getOpenId(type_key,raid_data)
	for i, v in ipairs(raid_data) do
		if type_key == v.type_key then
			return v.open_id
		end
	end
end

--获取全部关卡数据
function M:getLevelData(playing_id)
	local current_level_list = {}
	local raid = ConfigManager:getCfgByName("raid")
	local level_list = raid[playing_id]
    local server_unlock_season = 0
    local season_data = UserDataManager.m_season_data or {}
    if season_data and next(season_data) and season_data.season then
        server_unlock_season = season_data.season
    end
	for i, v in pairs(level_list) do
		local index = v.order
		if v.season ~= nil and server_unlock_season >= v.season  then
			table.insert(current_level_list,{index = index,cfg = v,id = i})
		end
	end
	table.sort(current_level_list,function(data1,data2)
		return data1.index < data2.index
	end)
	return current_level_list
end

--获取某一个关卡数据
function M:getCurrentLevelData(id)
	local current_level_data = self:getLevelData(self.current_playing)
	for i, v in ipairs(current_level_data) do
		if v.id == id then
			return v
		end
	end
end

--获取common数据(免费挑战次数)
function M:getCommonData()
	local commmon = ConfigManager:getCfgByName("common")
	--Logger.logError(commmon[390],"common数据资源")
	return commmon[390].value or 0
end

--获取付费挑战次数
function M:getVipPayNum(playing_id)
	local vip = ConfigManager:getCfgByName("vip")
	local userdata = UserDataManager.user_data
	local current_vip = userdata["user_status"]["vip"]
	local raid_buytimes = vip[current_vip].raid_buytimes
	return raid_buytimes[playing_id]
end

--是否挑战过
function M:ishasBattle(battle_id)
	local current_battle_id = self.m_data.raids[tostring(self.current_playing)]
	if current_battle_id ~= nil then
		if battle_id <= current_battle_id then
			return true
		end
	end
	return false
end

--当前已挑战关卡
function M:currentBattle()
	local current_battle_id = self.m_data.raids[tostring(self.current_playing)]
	local level_list = self:getLevelData(self.current_playing)
	if current_battle_id ~= nil and current_battle_id > level_list[#level_list].id then
		return level_list[#level_list].id
	end
	if current_battle_id ~= nil then
		return current_battle_id
	end
	return false
end

--当前已挑战层
function M:currentBattleLevel()
	local current_id = self:currentBattle()
	if current_id then
		local level_list = self:getLevelData(self.current_playing)
		for i, v in ipairs(level_list) do
			if v.id == current_id then
				return v.index 
			end
		end
		return #level_list
	end
	return 1
end

--通过index转换id
function M:currentBattleID(index,playing_id)
	local level_data = self:getLevelData(playing_id)
	local date_id = level_data[index].id
	return date_id
end

--通过id转换index
function M:currentBattleIndex(id,playing_id)
	local level_data = self:getLevelData(playing_id)
	for i, v in ipairs(level_data) do
		if v.id == id then
			return v.index
		end
	end
	return 0
end

--获取下一个可挑战序号（待挑战关卡）
function M:getNextBattleOrder(battle_id)
	local level_list = self:getLevelData(self.current_playing)
	local next_id = 0
	if battle_id >= level_list[#level_list].id then
		return 0
	end
	for i, v in ipairs(level_list) do
		if v.id == battle_id then
			if v.cfg.next_stage ~= nil then --有下一关
				return v.cfg.next_stage
			else --没有下一关啦
				return 0
			end
		elseif v.id == next_id then
			return v.index
		end
	end
end

--获取赛季开启时间
function M:getSeasonUnlock(open_id)
	local open_condition = ConfigManager:getCfgByName("open_condition")
	for i, v in pairs(open_condition) do
		if i == open_id then
			return v.season_unlock
		end
	end
end

--获取解锁关卡
function M:getLockLevel(open_id)
	local open_condition = ConfigManager:getCfgByName("open_condition")
	for i, v in pairs(open_condition) do
		if i == open_id then
			local big = math.floor(v.unlock_condition_param/100)
			local small = v.unlock_condition_param - big * 100
			local stage_str = big.."-"..small
			return stage_str
		end
	end
end

--获取付费挑战消耗
function M:getPayBattleCost()
	local system_cost = ConfigManager:getCfgByName("system_cost")
	return system_cost[9].cost[1]
end

--获取已扫荡次数
function M:getUsedMoppingNum(index)
	local free_times = self.m_data.free_times
	local num = free_times[tostring(index)]
	if num ~= nil then
		return num
	end
	return 0
end

--是否有红点
function M:isHasRed(index)
	local free_times = self:getCommonData() --免费次数
	local usedNum = self:getUsedMoppingNum(index) --已使用扫荡次数
	if usedNum < free_times then
		return true
	end
	return false
end

--获取每个关卡最大层数
function M:maxStateLevel(type_key)
	local level_data = self:getLevelData(type_key)
	return #level_data
	
end

--判断是否有扫荡次数
function M:isHasAutoSweepNum(Tab_Node)
	local cost = 0
	local item_name = 0
	local sweep_flag = false -- 是否可以扫荡
	for i, v in ipairs(Tab_Node) do
		local common_num = self:getCommonData()
		local VipPay_num = self:getVipPayNum(v.type_key) or 0
		local sum_num = common_num + VipPay_num
		local spent_num = self.m_data.free_times[tostring(v.type_key)] or 0--已扫荡次数
		if spent_num < sum_num then --有扫荡次数
			sweep_flag = true
		end
		if spent_num >= common_num and spent_num < sum_num then
			local level_data = self:getLevelData(v.type_key)
			local current_state_cost = level_data[1].cfg.cost[1] or 0
			local itemData = RewardUtil:getProcessRewardData(current_state_cost)
			cost = cost + math.modf(GameUtil:formatValueToString(itemData.data_num))
			item_name = itemData.icon_name
		end
	end
	return sweep_flag,cost,item_name
end



return M
