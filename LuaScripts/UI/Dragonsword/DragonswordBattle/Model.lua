local M = class("DragonswordBattleModel",LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end


function M:onEnter()
	self.m_data = {}
	self.m_version = self.m_params.version or 1  --版本号
	self.m_open_data = self.m_params.open_data --open_condition表数据
	self.m_active_data = self.m_params.active_data --活动开启表
	self.m_max_damage = self.m_params.max_damage --最大伤害
	self.m_assist_heros = self.m_params.assist_heros --助战英雄
	self.m_enemys = self.m_params.enemys --敌人
	self.m_start_time = self:stringTimeByNumberTime(self.m_active_data.start_time) --活动开始时间
	self.m_current_start_day = self.m_params.current_day or 0  --当前日期为活动开启后的第几天
	self:getRankingData()
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
	local dragon_ranking = ConfigManager:getCfgByName("dragon_ranking")
	local last_rank_num = 1
	for i, v in pairs(dragon_ranking[self.m_version]) do
		table.insert(self.ranking_reward,{min_num = last_rank_num,max_num = i,cfg = v})
		last_rank_num = i + 1
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

return M
