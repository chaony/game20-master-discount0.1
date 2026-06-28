local M = class("LegendRewardModel", LikeOO.OODataBase)

local __TAB_BTN_NODE = {
	{btn_key = "togglebtn_1", quest_key = "Daily", btn_text = "togglebtn_text_1", text_key = "new_str_0026", open = true, url_key = "legend_recv_daily_reward"}, -- 日常
	{btn_key = "togglebtn_2", quest_key = "Weekly", btn_text = "togglebtn_text_2", text_key = "new_str_0028", open = true, url_key = "legend_recv_weekly_reward"}, -- 周常
	{btn_key = "togglebtn_3", quest_key = "", btn_text = "togglebtn_text_3", text_key = "UnionWar_str_007", open = true, url_key = ""}, -- 排行
}

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("legend_index", {})
end

function M:onEnter()
	self.m_open_tab_index = self.m_params.open_tab_index or 1
	self:initData(self.m_data)
end

function M:getRankData()
	local legend_reward_list_cfg = ConfigManager:getCfgByName("legend_reward_list")
	local legend_reward_list_cfg_item = legend_reward_list_cfg[self.m_data.legend_type] or {}
	return legend_reward_list_cfg_item
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
	for k,v in ipairs(self:getTabBtnNode()) do
		if v.quest_key ~= "" then
			self:initQuestsData(v.quest_key)
		end
	end
end

function M:initQuestsData(quest_key)
	local show_data = {}
	self["m_"..quest_key.."_red_point"] = false
	local quests = self.m_data[string.lower(quest_key).."_quests"] or {}
	local legend_quest_time = ConfigManager:getCfgByName("legend_quest_time")
	for k,v in pairs(quests) do
		local key = tonumber(k)
		local cfg = legend_quest_time[key]
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
					self["m_"..quest_key.."_red_point"] = true
				end
			end
			local real_cur_progress, real_target_progress = UserDataManager:getQuestProgress(cfg, value)
			table.insert(show_data, {id = key, cfg = cfg, status = status, cur_progress = real_cur_progress, target_value = real_target_progress, lock_flag = lock_flag, lock_text = lock_text})
		end
	end
	GameUtil:taskDataSort(show_data)
	self["m_"..quest_key.."_quests_data"] = show_data
end

function M:getQuestsData(quest_key)
	return self["m_"..quest_key.."_quests_data"]
end

return M
