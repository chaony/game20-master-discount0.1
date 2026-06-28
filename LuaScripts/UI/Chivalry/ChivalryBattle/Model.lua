local M = class("ChivalryBattleModel", LikeOO.OODataBase)



function M:onCreate()
	M.super.onCreate(self)
	self.seven_star = ConfigManager:getCommonValueById(109) == 1 --是否为群英试炼
	self.open_id = self.m_params.open_id or 395
	self.refresh_main = self.m_params.refresh_main or "Chivalry.ChivalryMain"
	self.m_active_data = UserDataManager:getActivesDataByOpenId(self.open_id)
	if self.m_active_data ~= nil then
		self.m_version = self.m_active_data.version or 7--版本号
	else
		self.m_version = 7--版本号
	end
	self.is_show_break_btn = self.m_params.is_show_break_btn or 0 --1：展示击破按钮，0：不展示击破按钮
	self:getData("common_train_challenge_index",{open_id = self.open_id,version = self.m_version})
end

function M:onEnter()
	--Logger.logError(self.m_data,"self.m_data~~~~~~~~~~~~~~~~")
	self.m_hero_skin_data = self.m_params.hero_skin_data or {}
	
	self.m_open_data = self.m_params.open_data --open_condition表数据
	self.m_active_data = self.m_params.active_data --活动开启表
	self.m_max_damage = self.m_data.max_damage or 0 --最大伤害
	self.m_assist_heros = self.m_data.assist_heros --助战英雄
	self.m_enemys = self.m_data.enemys --敌人
	self.all_hero = self:getAllHeroIds()
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

--获取buff描述
function M:getHeroBffoData()
	local hero_event_buff = ConfigManager:getCfgByName("active_train")
	return hero_event_buff[self.open_id][self.m_version][1].buff_des
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

--获取展示英雄id
function M:getShowHeroId()
	local hero_train_stage = ConfigManager:getCfgByName("active_train")
	return hero_train_stage[self.open_id][self.m_version][1].hero_id
end

--任务数据
function M:getTasks()
	return self.m_data.quests
end

--获取任务红点
function M:getTaskRedPoint()
	if self.m_data.quests then
		for i, v in pairs(self.m_data.quests) do
			if v.status == 1 then
				return true
			end
		end
	end
	return false
end

--获取击破红点
function M:getBreakRedPoint()
	local milepost_data = self:readMilepost()
	if milepost_data then
		for i, v in ipairs(milepost_data) do
			if self.m_data.all_attack_times >= v.times then
				local isReceive = self:getBreakRewardIsReceive(i)
				if not isReceive then
					return true
				end
			end
		end
	end
	return false
end

--判断击破奖励是否已领取 true:已领取，false：未领取
function M:getBreakRewardIsReceive(id)
	if self.m_data.received_attack_reward then
		for i, v in pairs(self.m_data.received_attack_reward) do
			if v == id then
				return true
			end
		end
	end
	return false
end

--读取数据
function M:readMilepost()
	local diamond_milepost = ConfigManager:getCfgByName("active_train_attack_quest")
	return diamond_milepost[self.open_id][self.m_version][1]
end

--获取所有英雄
function M:getAllHeroIds()
	local ids = table.copy(UserDataManager.hero_data:getHerosId())
	UserDataManager.hero_data:heroIdsSort(ids, "team")
	return ids
end

--获取所有英雄信息
function M:getHeroData(hero_id)
	for i, v in pairs(self.all_hero) do
		local data, cfg = UserDataManager.hero_data:getHeroDataById(v)
		if data.id == hero_id then
			return true,data.evo
		end
	end
	return false
end

--获取buff加成
function M:getHeroBuff()
	local active_train_hero_buff = ConfigManager:getCfgByName("active_train_hero_buff")
	if active_train_hero_buff[self.open_id] == nil then
		return false
	end
	for i, v in pairs(active_train_hero_buff[self.open_id][self.m_version]) do
		local is_has_hero,hero_evo = self:getHeroData(i)
		for evo_i, evo_data in pairs(v) do
			if hero_evo == evo_i then
				return true,evo_data.percent
			end
		end
	end
	for i, v in pairs(active_train_hero_buff[self.open_id][self.m_version]) do
		local data = UserDataManager.hero_data:getHeroConfigByCid(i)
		return false,data
	end
	
end

--获取活动version
function M:getActVsn(open_id, is_recharge)
	open_id = open_id or 393
	local active = nil
	if is_recharge then
		active = UserDataManager:getActivesRechargeDataByOpenId(open_id)
	else
		active = UserDataManager:getActivesDataByOpenId(open_id)
	end
	if active and active.version then
		return active.version
	end
	return 1
end

--获取试炼主题名称
function M:getBattleNameData(id)
	local hero_event_buff = ConfigManager:getCfgByName("active_train")
	if hero_event_buff[self.open_id][id] then
		return hero_event_buff[self.open_id][id][1].name
	else
		return nil
	end
end

return M
