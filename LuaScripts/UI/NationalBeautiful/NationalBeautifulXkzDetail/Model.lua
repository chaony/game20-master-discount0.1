local M = class("NationalBeautifulXkzDetailModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params.net_data
	--self.m_parent_model = self.m_params.parent_model or nil
	self:updateData()
	--self:initData(self.m_params)
	self.open_id = self.m_params.open_id or 410
	self.version = self.m_params.version or 1
	self.m_hero_index = self.m_params.hero_index or 1
	self.m_cur_index = self.m_params.cur_index or 1
	self.m_help_id = self.m_params.help_id or ""
	self.m_active = self.m_params.active
	self.m_raccon_biography_hero = ConfigManager:getCfgByName("common_biography_hero")[self.open_id][self.version] or {}
	self.m_raccon_biography_stage = ConfigManager:getCfgByName("common_biography_stage")[self.open_id][self.version] or {}
	self.m_raccon_biography_reward = ConfigManager:getCfgByName("common_biography_reward")[self.open_id][self.version]or {}
	self.m_cur_reward_cfg = self.m_raccon_biography_reward[self.m_hero_index] or {}
	self.m_cur_stage_cfg = self.m_raccon_biography_stage[self.m_hero_index] or {}
	self.m_cur_cfg = self.m_raccon_biography_hero[self.m_hero_index] or {}
	self.m_show_data = {}
	self.m_show_data_id = {}
	self.m_total_data = {}
	self.m_cur_cell_group = nil
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
	self.m_cost_stage = self.m_data.cost_stage or {}
	self.m_health = self.m_data.health or 0
end

function M:isCanVisible(stage_id) 
	local stage_data = self:getStageDataByHeroIndex(self.m_hero_index)
	for i, v in pairs(stage_data) do
		if v == stage_id then
			return true
		end
	end
	return false
end

function M:isCost(stage_id)
	for i, v in pairs(self.m_cost_stage) do
		if v == stage_id then
			return true
		end
	end
	return false
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

function M:getStageData(is_refresh)
	local min_unlock_group = 999
	local show_data = {}
	local show_stage_id_tab = {}
	local total_data = {}
	if next(self.m_show_data) and not is_refresh then
	else
		for i, v in pairs(self.m_cur_stage_cfg) do
			local cur_stage = v
			local cur_group = cur_stage.group
			local cur_group_id = cur_stage.group_id
			local stage_front = cur_stage.stage_front or -1
			local is_show = stage_front == 0 
			if stage_front > 0 and not is_show then
				is_show = self:isCanVisible(stage_front)
			end
			if is_show then
				if show_data[cur_group] == nil then
					show_data[cur_group] = {}
				end
				if show_stage_id_tab[cur_group] == nil then
					show_stage_id_tab[cur_group] = {}
				end
				show_data[cur_group][cur_group_id] = cur_stage
				show_stage_id_tab[cur_group][cur_group_id] = i
				local cur_finish = self:isCanVisible(i)
				if not cur_finish then
					min_unlock_group = math.min(min_unlock_group, cur_group)
				end
			end
			if total_data[cur_group] == nil then
				total_data[cur_group] = {}
			end
			total_data[cur_group][cur_group_id] = cur_stage
		end
		self.m_show_data = show_data
		self.m_show_data_id = show_stage_id_tab
		self.m_min_unlock_group = min_unlock_group
		self.m_total_data = total_data
	end
	return self.m_show_data, self.m_show_data_id, self.m_min_unlock_group, self.m_total_data
end

function M:getBtnShow(pos_data, pos_index)
	for i = 1, #pos_data do
		if pos_data[i] == pos_index then
			return true
		end
	end
	return false
end

function M:initData(response)
	if response then
		table.merge(self.m_data,response)
	end
end

function M:checkStageOpen()
	return false
end

function M:getFormationData(stage_data)
	--local stage_battle_tab = ConfigManager:getCfgByName("stage_battle")
	local battle_item
	local enemy_item, enemy_data
	local v = stage_data
	battle_item = ConfigManager:getCfgStageBattle(stage_data.battle_id) or {}--stage_battle_tab[stage_data.battle_id] or {}
	enemy_data = {}
	for kk, vv in pairs(battle_item.monster or {}) do
		enemy_item = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, vv.id, 0})
		enemy_item.quality = vv.evo
		enemy_item.hero_data = vv
		enemy_item.dyns = {}
		table.insert(enemy_data, enemy_item)
	end
	local open_formation_data = {battle_id = stage_data.battle_id, cfg_type = v.type, id = v.id, pre_id = v.stage_front, name = Language:getTextByKey(v.name), reward = v.reward, enemy = enemy_data,
							   visible_flag = true, open_flag = self:checkStageOpen(v.stage_front),
							   open_event = v.battle_event1, win_event = v.battle_event2}
	return open_formation_data
end

function M:getCurRecvData()
	local cur_recv = self.m_chapter_recv[tostring(self.m_cur_index)] or {}
	return cur_recv
end

function M:isRecvByBoxId(box_id)
	local cur_recv = self:getCurRecvData()
	for i = 1, #cur_recv do
		if cur_recv[i] == box_id then
			return true
		end
	end
	return false
end

function M:getChapterNumsByHeroIndex(hero_index)
	local cur_finish_stage = self.m_finish_stage[tostring(self.m_cur_index)] or {}
	local total_nums = 0
	for i, v in pairs(cur_finish_stage) do
		if i == tostring(hero_index) then
			total_nums = table.nums(v) + total_nums
		end
	end
	return total_nums
end

function M:getCurStageRecvDataByHeroIndex(hero_index)
	local cur_recv = self.m_stage_recv[tostring(hero_index)] or {}
	return cur_recv
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

function M:getBoxShowData()
	local show_data = {}
	local hot_value = self:getChapterNumsByHeroIndex(self.m_hero_index)
	local cur_box_cfg = self.m_cur_reward_cfg
	local socre_cfg_tab = cur_box_cfg.score or {}
	local rewards_cfg_tab = cur_box_cfg.reward or {}
	self.m_have_recv_daily_quests = false
	for cfg_index, cfg_score in pairs(socre_cfg_tab) do
		local is_recv = self:isStageRecvByBoxId(self.m_hero_index, cfg_index)
		local status = 0 -- 2 可领取 0不可领取 -1 已领取
		if is_recv then
			status = -1
		else
			if cfg_score <= hot_value then
				status = 2
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
	return show_data
end

return M
