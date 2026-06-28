local M = class("GuildHighWarTotalLogPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("guild_high_war_battle_logs")
end

function M:onEnter()
	self.m_mode = "atk" --进攻或者驻守
	self.m_cur_select_id = nil
	self.m_logs = self.m_data.logs or {}
	self:initCityId()
end

function M:initCityId()
	local city_id_tab = {}
	for i = 1, #self.m_logs do
		local city_id = self.m_logs[i].city_id
		local count = self.m_logs[i].count
		if self.m_cur_select_id == nil and count > 0 and i==1 then
			self.m_cur_select_id = city_id
		end
		city_id_tab[city_id] = i
	end
	self.m_city_id_tab = city_id_tab
	self.m_city_data = ConfigManager:getCfgByName("guild_high_war_build") or {}
end

function M:getCityDataById(id)
	return self.m_city_data[id] or {}
end

function M:getCurLogsByCityId(city_id)
	local log_index = self.m_city_id_tab[city_id]
	if self.m_logs[log_index] and self.m_logs[log_index].logs then
		return self.m_logs[log_index].logs
	end
	return nil
end

function M:getCurLogsNumsByCityId(city_id)
	local log_index = self.m_city_id_tab[city_id]
	if self.m_logs[log_index] and self.m_logs[log_index].logs then
		return self.m_logs[log_index].count or 0
	end
	return 0
end

function M:needReuqestNet(city_id)
	local cur_rank_nums = table.nums(self:getCurLogsByCityId(city_id))
	local max_rank_count = self:getCurLogsNumsByCityId(city_id) or 0
	if cur_rank_nums == 0 and max_rank_count > 0 then
		return true
	end
	return false
end

function M:updateCityLog(logs_data, city_id)
	if logs_data then
		local logs = self:getCurLogsByCityId(city_id)
		for i = 1, #logs_data do
			table.insert(logs, logs_data[i])
		end
	end
end

function M:getLoadIndex(city_id)
	local max_rank_count = self:getCurLogsNumsByCityId(city_id)
	local cur_rank_nums = table.nums(self:getCurLogsByCityId(city_id))
	local start_pos, end_pos = 0, 0
	if cur_rank_nums + 10 <= max_rank_count then
		start_pos = cur_rank_nums + 1
		end_pos = cur_rank_nums + 10
	elseif max_rank_count - cur_rank_nums > 0 then
		start_pos = cur_rank_nums + 1
		end_pos = max_rank_count
	end
	return start_pos, end_pos
end

function M:getShowHeroData(hero_data)
	if hero_data then
		local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
		data.quality = hero_data.evo
		data.card_id = hero_id
		data.hero_data = hero_data
		return data
	end
end

return M
