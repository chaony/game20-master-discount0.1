local M = class("WorldBossSelectMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("world_boss_trial_index")
end

function M:onEnter()
	self.world_boss_data = self.m_data.world_boss
	self.hero_train_data = self.m_data.train_challenge
	self.legend_data = self.m_data.legend
	self.m_activeboss_open_id = 170
	self.boss_num = self:getLeftTimes(self.world_boss_data.battle_times)
	self.legend_weekly_etime = self.legend_data.weekly_etime
	self.activeboss_etime = self.hero_train_data.ntime
end

function M:initData(data)

end

function M:getBossData(key)
	if key == "worldboss" then
		return {num = self.boss_num}
	elseif key == "activeboss" then
		return {num = self:getActivebossTime()}
	elseif key == "legend" then
		return {num = self:getLegendTime()}
	else
		return {}
	end
end

function M:updateHerTrainData(data)
	self.hero_train_data = data and data or self.hero_train_data
end

function M:getActivebossTime()
	local server_time = UserDataManager:getServerTime()
	local time = self.activeboss_etime - server_time
	if time <= 0 then
		return
	end
	local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(time)
	return Language:getTextByKey("legend_str_026", day, hour)
end

function M:getLegendTime()
	local server_time = UserDataManager:getServerTime()
	local time = self.legend_weekly_etime - server_time
	if time <= 0 then
		return
	end
	local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(time)
	return Language:getTextByKey("legend_str_026", day, hour)
end

function M:active_boss_open()
	if UserDataManager:getActivesByOpenId(self.m_activeboss_open_id) == false then
		return false
	end
	return true
end

function M:getLeftTimes(times)
	local total_times = ConfigManager:getVipValueByKey("word_boss_challenge_times", 0)
	return total_times - times
end

return M
