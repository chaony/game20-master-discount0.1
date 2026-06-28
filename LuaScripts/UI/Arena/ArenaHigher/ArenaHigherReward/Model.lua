local M = class("ArenaHigherRewardModel", LikeOO.OODataBase)

local __TAB_BTN_NODE = {
	{btn_key = "togglebtn_1", btn_text = "togglebtn_text_1", text_key = "new_str_0026", open = true, url_key = "high_arena_select_arena_rank"}, -- 日常
	{btn_key = "togglebtn_2", btn_text = "togglebtn_text_2", text_key = "world_boss_str_0027", open = true, url_key = "high_arena_select_arena_score_rank"}, -- 段位
	{btn_key = "togglebtn_3", btn_text = "togglebtn_text_3", text_key = "UnionWar_str_007", open = true, url_key = "high_arena_select_arena_score_rank"}, -- 排行
}

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params.data
	self.m_open_tab_index = self.m_params.open_tab_index or 1
	self:initData(self.m_data)
end

function M:getRankData()
	local arena_reward_list_cfg = ConfigManager:getCfgByName("arena_reward_list")
	local arena_reward_list_cfg_item = arena_reward_list_cfg[2] or {}
	return arena_reward_list_cfg_item
end

function M:getTabBtnNode()
	return __TAB_BTN_NODE
end

--- 网络数据回调
function M:netData(data, tag)
	self:initData(data)
end

function M:initData(data)
	table.merge(self.m_data, data)
	self:initDailyQuestsData()
	self:initDwData()
end

function M:initDailyQuestsData()
	local show_data = {}
	local quests = self.m_data.quests or {}
	local arena_quest_time = ConfigManager:getCfgByName("arena_quest_time")
	for k,v in pairs(quests) do
		local key = tonumber(k)
		local cfg = arena_quest_time[key]
		if cfg then
			local value = v.value or 0
			local status = v.status or 0 -- 2为领过奖励 - 如果没有领取status没有
			local target_value = cfg.target_value
			if status == 2 then
				status = -1
			else
				if value >= target_value then -- 完成可领取
					status = 2
				end
			end
			local lock_flag, lock_text = ConfigManager:getQuestLockFlag(cfg.stage_id)
			if lock_flag then
				status = -0.5
			else
				if status == 2 then
					self.m_daily_red_point = true
				end
			end
			local real_cur_progress, real_target_progress = UserDataManager:getQuestProgress(cfg, value)
			table.insert(show_data, {id = key, cfg = cfg, status = status, cur_progress = real_cur_progress, target_value = real_target_progress, lock_flag = lock_flag, lock_text = lock_text})
		end
	end
	GameUtil:taskDataSort(show_data)
	self.m_daily_quests_data = show_data
end

function M:getDailyQuestsData()
	return self.m_daily_quests_data
end

function M:initDwData()
	self.m_dw_data = UserDataManager:getChapterQuestSpecialData(95)
end

function M:getDwData()
	return self.m_dw_data
end

return M
