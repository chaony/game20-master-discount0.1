local M = class("RacconXkzModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("raccon_index")
end

function M:onEnter()
	self.m_raccon_biography_reward = ConfigManager:getCfgByName("raccon_biography_reward") or {}
	self.m_rbc_cfg = ConfigManager:getCfgByName("raccon_biography_chapter") or {}
	self.m_raccon_biography_hero_cfg = ConfigManager:getCfgByName("raccon_biography_hero") or {}
	self.m_raccon_biography_condition_cfg = ConfigManager:getCfgByName("raccon_biography_condition") or {}
	self.m_rbc_reward_cfg = ConfigManager:getCfgByName("raccon_biography_chapter_reward") or {}
	self.m_cfg_max = self:getMaxCfgOpenChapter()
	self:updateData()
	self.m_cur_index = self:getMaxChapterFinish()
	self.m_cur_day = self.m_params.cur_day or 1
	self.m_help_id = self.m_params.help_id or ""
end

function M:getEndTs()
	local active = UserDataManager:getActivesDataByOpenId(341)
	if active and active.end_ts then
		return active.end_ts - UserDataManager:getServerTime() + 2
	end
	return 0
end

function M:getCfgValueByKey(cfg_key, cur_index)
	cur_index = cur_index or self.m_cur_index
	if self.m_rbc_cfg[cur_index] and self.m_rbc_cfg[cur_index][cfg_key] then
		return self.m_rbc_cfg[cur_index][cfg_key]
	end
	return nil
end

function M:updateData(response)
	if response then
		table.merge(self.m_data,response)
	end
	self.m_version = self.m_data.version or 1
	self.m_finish_option = self.m_data.finish_option or {}
	self.m_finish_stage = self.m_data.finish_stage or {}
	self.m_chapter_recv = self.m_data.chapter_recv or {}
	self.m_stage_recv = self.m_data.stage_recv or {}
	self.m_health = self.m_data.health or 0
end

function M:getFinishStage(hero_index, cur_index)
	cur_index = cur_index or self.m_cur_index
	local cur_stage = self.m_finish_stage[tostring(cur_index)] or {}
	local cur_hero_finish = cur_stage[tostring(hero_index)] or {}
	return cur_hero_finish
end

function M:getTotalChapterNums(cur_index)
	cur_index = cur_index or self.m_cur_index
	local cur_finish_stage = self.m_finish_stage[tostring(cur_index)] or {}
	local total_nums = 0
	for i, v in pairs(cur_finish_stage) do
		total_nums = table.nums(v) + total_nums
	end
	return total_nums
end

function M:getStageDataByHeroIndex(hero_index)
	local cur_finish_stage = self.m_finish_stage[tostring(self.m_cur_index)] or {}
	for i, v in pairs(cur_finish_stage) do
		if i == tostring(hero_index) then
			return v
		end
	end
	return {}
end

function M:getChapterNumsByHeroIndex(hero_index, cur_index)
	cur_index = cur_index or self.m_cur_index
	local cur_finish_stage = self.m_finish_stage[tostring(cur_index)] or {}
	local total_nums = 0
	for i, v in pairs(cur_finish_stage) do
		if i == tostring(hero_index) then
			total_nums = table.nums(v) + total_nums
		end
	end
	return total_nums
end

function M:getCurRecvData(cur_index)
	cur_index = cur_index or self.m_cur_index
	local cur_recv = self.m_chapter_recv[tostring(cur_index)] or {}
	return cur_recv
end

function M:getCurStageRecvDataByHeroIndex(hero_index)
	local cur_recv = self.m_stage_recv[tostring(hero_index)] or {}
	return cur_recv
end

function M:isRecvByBoxId(box_id, cur_index)
	local cur_recv = self:getCurRecvData(cur_index)
	for i = 1, #cur_recv do
		if cur_recv[i] == box_id then
			return true
		end
	end
	return false
end

function M:isStageRecvByBoxId(hero_index, box_id)
	local cur_recv = self:getCurStageRecvDataByHeroIndex(hero_index)
	for i = 1, #cur_recv do
		if cur_recv[i] == box_id then
			return true
		end
	end
	return false
end

function M:getBoxShowData(cur_index)
	cur_index = cur_index or self.m_cur_index
	local show_data = {}
	local is_can_get = false
	local finish_nums = self:getTotalChapterNums(cur_index)
	local cur_box_cfg = self.m_rbc_reward_cfg[cur_index] or {}
	local socre_cfg_tab = cur_box_cfg.score or {}
	local rewards_cfg_tab = cur_box_cfg.reward or {}
	self.m_have_recv_daily_quests = false
	for cfg_index, cfg_score in pairs(socre_cfg_tab) do
		local is_recv = self:isRecvByBoxId(cfg_index, cur_index)
		local status = 0 -- 2 可领取 0不可领取 -1 已领取
		if is_recv then
			status = -1
		else
			if cfg_score <= finish_nums then
				status = 2
				is_can_get = true
			end
		end
		local reward = rewards_cfg_tab[cfg_index] or {}
		local temp = {}
		temp.score = cfg_score
		temp.status = status
		temp.rewards = reward
		temp.box_id = cfg_index
		table.insert(show_data, temp)
	end
	table.sort(show_data, function(a, b) return a.score < b.score end)
	return show_data, is_can_get
end

function M:getRewardPointDataByIndex(cur_index)
	local is_can_get = false
	local finish_nums = self:getTotalChapterNums(cur_index)
	local cur_box_cfg = self.m_rbc_reward_cfg[cur_index] or {}
	local socre_cfg_tab = cur_box_cfg.score or {}
	self.m_have_recv_daily_quests = false
	for cfg_index, cfg_score in pairs(socre_cfg_tab) do
		local is_recv = self:isRecvByBoxId(cfg_index, cur_index)
		local status = 0 -- 2 可领取 0不可领取 -1 已领取
		if is_recv then
			status = -1
		else
			if cfg_score <= finish_nums then
				status = 2
				is_can_get = true
			end
		end
	end
	return is_can_get
end

function M:getDetailBoxRedPoint(hero_index, cur_index)
 	local hot_value = self:getChapterNumsByHeroIndex(hero_index, cur_index)
	local cur_box_cfg = self.m_raccon_biography_reward[hero_index] or {}
	local socre_cfg_tab = cur_box_cfg.score or {}
	for cfg_index, cfg_score in pairs(socre_cfg_tab) do
		local is_recv = self:isStageRecvByBoxId(hero_index, cfg_index)
		local status = 0 -- 2 可领取 0不可领取 -1 已领取
		if is_recv then
		else
			if cfg_score <= hot_value then
				return true
			end
		end
	end
	return false
end

function M:isCanVisible(stage_id)
	local cur_finish_stage = self.m_finish_stage[tostring(self.m_cur_index)] or {}
	for hero_index, hero_finish_stage in pairs(cur_finish_stage) do
		for ii, finish_stage_id in pairs(hero_finish_stage) do
			if finish_stage_id == stage_id then
				return true
			end
		end
	end
	return false
end

function M:isChapterUnlock(hero_index)
	local is_lock = false
	local lock_des = ""
	if self.m_raccon_biography_hero_cfg[hero_index] then
		local open_condition = self.m_raccon_biography_hero_cfg[hero_index].open_condition or {}
		for i, v in pairs(open_condition) do
			local o_id = v
			if self.m_raccon_biography_condition_cfg[o_id] then
				local o_type = self.m_raccon_biography_condition_cfg[o_id].type or 0
				if o_type == 2 then
					local stage_id = self.m_raccon_biography_condition_cfg[o_id].option_id
					local is_finish = self:isCanVisible(stage_id)
					if not is_finish then
						is_lock = true
						lock_des = self.m_raccon_biography_condition_cfg[o_id].condition_des or ""
					end
				end
			end
		end
	end
	return is_lock, lock_des
end

function M:getMaxChapterFinish()
	local start_index = 1
	for k,v in ipairs(self.m_rbc_cfg) do
		start_index = k
		if v.open == 1 then
			break
		end
	end
	local max_index = start_index
	local max_cfg_index = self:getMaxCfgOpenChapter()
	for tab_index = start_index, 3 do
		local stage = self:getCfgValueByKey("stage", tab_index) or {}
		local hero = self:getCfgValueByKey("hero", tab_index) or {}
		local finish = true
		for i = 1, 3 do
			local hero_index = hero[i] or 0
			local max_stage = stage[i] or 999
			local cur_num = table.nums(self:getFinishStage(hero_index, tab_index))
			if cur_num < max_stage then
				finish = false
				break
			end
		end
		if finish then
			max_index = max_index +1
			max_index = math.min(self.m_cfg_max, max_index)
		end
	end
	return max_index
end

function M:getMaxCfgOpenChapter()
	local max = 1
	for i = 1, #self.m_rbc_cfg  do
		if self.m_rbc_cfg[i] and self.m_rbc_cfg[i].open == 1 then
			max = i
		end
	end
	return max
end

return M
