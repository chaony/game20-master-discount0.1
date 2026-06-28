local M = class("ThreeHeroesFiveGallantsBattleModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("chivalrous_train_index")
end

function M:onEnter()
	self.m_hero_skin_data = self.m_params.hero_skin_data or {}
	self.m_active_data = self:getActiveData()
	--if self.m_active_data ~= nil then
	--	self.m_version = self.m_active_data.version or 1--版本号
	--else
	--	self.m_version = 1--版本号
	--end
	self.m_version = self.m_params.version or 1
	self.open_id = self.m_params.open_id or 388
	self.m_open_data = self.m_params.open_data --open_condition表数据
	self.m_active_data = self.m_params.active_data --活动开启表
	self.m_max_damage = self.m_data.max_damage or 0 --最大伤害
	self.m_assist_heros = self.m_data.assist_heros --助战英雄
	self.m_enemys = self.m_data.enemys --敌人
	--self.m_start_time = self:stringTimeByNumberTime(self.m_active_data.cell_data.cfg.start_time) --活动开始时间
	self.m_current_start_day = self.m_params.current_day or 0  --当前日期为活动开启后的第几天
	--self:getRankingData()
end

--刷新服务器数据
function M:updateServer(response)
	table.merge(self.m_data,response)
end

--刷新最大伤害
function M:updateMaxDamage(response)
	self.m_max_damage = response.data.max_damage
end

--排名奖励
function M:getRankingData()
	self.ranking_reward = {}
	local dragon_ranking = ConfigManager:getCfgByName("chivalrous_reward")
	local last_rank_num = 1
	if dragon_ranking[self.m_version] then
		for i, v in pairs(dragon_ranking[self.m_version]) do
			table.insert(self.ranking_reward,{min_num = last_rank_num,max_num = i,cfg = v})
			last_rank_num = i + 1
		end
	else
		Logger.logError("hero_event_ranking 中没有找到 version："..tostring(self.m_version))
	end
	
end

--获取展示奖励
function M:getRankingReward(rank_num)
	rank_num = rank_num or 0
	for i, v in pairs(self.ranking_reward) do
		if rank_num <= v.max_num and rank_num >= v.min_num then
			return v
		end
	end
	return self.ranking_reward[#self.ranking_reward]
end

--获取种族加成
function M:getRace()
	local dragonsword_login = ConfigManager:getCfgByName("dragonsword_login")
	local version_data = dragonsword_login[self.m_version]
	return version_data[self.m_current_start_day]
end

--时间转换  从具体年月日转换为时间戳
function M:stringTimeByNumberTime(time_string)
	local _, _, y, moth, d, h, mi, s = string.find(time_string, "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)")
	return os.time({year = y, month = moth, day = d, hour = h, min = mi, sec = s})
end

--获取活动开始时间
function M:getCurrentDay()
	local cur_tim = UserDataManager:getServerTime() --当前时间
	local surplus_time = cur_tim - self.m_start_time --从活动开始到当前时间的差值
	local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算活动开启时间
	return remain_day + 1
end

--获取基本显示信息
function M:BasicInfo()
	local event = ConfigManager:getCfgByName("hero_event")
	return event[self.m_version] or {}
end

--获取buff显示
function M:getHeroBffoData()
	local hero_event_buff = ConfigManager:getCfgByName("hero_event_buff")
	return hero_event_buff[self.m_version]
end

--是否有符合活动的英雄
function M:IsHashero(heros_data,hero_evo)
	for i, v in pairs(heros_data) do
		local data,cfg = UserDataManager.hero_data:getHeroDataById(v)
		if data.evo >= hero_evo  then
			return data,cfg
		end
	end
	return nil,nil
end

--获取活动名称
function M:getActiveName()
	local open_condition = ConfigManager:getCfgByName("open_condition")
	local name = open_condition[self.open_id].name
	return name or ""
end

--获取活动数据
function M:getActiveData()
	local active_tab = ConfigManager:getCfgByName("active")
	for i, v in pairs(active_tab) do
		if v.open_id == self.open_id then
			return v
		end
	end
	return nil
end

--获取展示英雄id
function M:getShowHeroId()
	local chivalrous_practice_stage = ConfigManager:getCfgByName("chivalrous_practice_stage")
	for i, v in ipairs(chivalrous_practice_stage) do
		if i == self.m_params.cur_camp then
			return v.boss_show
		end
	end
	return nil
end

--任务数据
function M:getTasks()
	return self.m_data.quests
end

--获取任务红点
function M:getTaskRedPoint()
	for i, v in pairs(self.m_data.quests) do
		if v.status == 1 then
			return true
		end
	end
	return false
end

return M
