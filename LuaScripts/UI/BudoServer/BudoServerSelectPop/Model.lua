local M = class("BudoServerSelectPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"
	self:getData("quest_index")
end

function M:onEnter()
	local day = math.floor((UserDataManager:getServerTime() + UserDataManager:getTimeZone())/86400)
	local yu_day = (UserDataManager:getServerTime() + UserDataManager:getTimeZone())%86400
	if yu_day >  0 then
		day = day + 1
	end
	self.m_open_race = (day-1)%4 + 1
	for k,v in pairs(UserDataManager.race_tower_status) do
		self.m_open_race = v
	end
end

--更新数据
function M:updateServerData(serverdata)
	table.merge(self.m_data,serverdata)
end

--检查种族塔开启 四的倍数
function M:getOpenTimeByIndex(race)
	local cur_race =  self.m_open_race --今日开启的种族
	local race_sequence = ConfigManager:getCommonValueById(570, {})
	local cur_race_day = 0 -- race_sequence[race]
	local open_race_day = 0
	for k,v in pairs(race_sequence) do
		if v == race then
			cur_race_day = k
		end
		if v == cur_race then
			open_race_day = k
		end
	end

	local sub_num = math.abs(open_race_day - cur_race_day) 
	if open_race_day == 4 then
		if cur_race_day == 4 then
			sub_num = 0
		else
			sub_num = cur_race_day
		end
	end
	if sub_num == 0 then
		return Language:getTextByKey("budo_str_010") --"今日开启"
	elseif sub_num == 1 then
		if open_race_day == 4 or open_race_day < cur_race_day then
			return Language:getTextByKey("budo_str_011") --"明日开启"
		else
			return Language:getTextByKey("budo_str_013") --"三天后开启"
		end
	elseif sub_num == 2 then
		return Language:getTextByKey("budo_str_012") --"两天后开启"
	elseif sub_num == 3 then
		return Language:getTextByKey("budo_str_013") --"三天后开启"
	end
end

function M:getFloorByIndex(race)
	local cur_floor = UserDataManager:getRaceFloorByRace(race or 0)
	return Language:getTextByKey("budo_str_001", cur_floor) 
end

function M:checkIsOpen(race)
	if self.m_open_race == race then
		return true
	else
		return false	
	end
	-- for k,v in pairs(UserDataManager.race_tower_status) do
	-- 	if race == v then
	-- 		return true
	-- 	end
	-- end
	-- return false
end

--获取主线任务
function M:getMainQuests()
	local Budo_main_quest = {}
	local quest_main = ConfigManager:getCfgByName("quest_main")
	for i, v in pairs(self.m_data.main_quests) do
		local str_head_two = string.sub(i,1,2)
		if str_head_two == "15" then
			local key = tonumber(i)
			local quset_main_data = quest_main[key]
			table.insert(Budo_main_quest,{id = i,status = v,data = quset_main_data})
		end
	end
	table.sort(Budo_main_quest,function(data1,data2)
		return data1.id > data2.id
	end)
	return Budo_main_quest
end

return M
