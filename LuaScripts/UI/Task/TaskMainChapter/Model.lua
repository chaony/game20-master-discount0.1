---@class TaskMainChapterModel:OODataBase
local M = class("TaskMainChapterModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("quest_index")
end

function M:onEnter()
	local quest_type = self.m_params.quest_type
	self.param = self.m_params.param
	self.m_callback = self.m_params.callback

	if type(quest_type) == "table" then
		self.m_quest_types = quest_type
		self.m_quest_type = quest_type[1]
	else
		self.m_quest_type = quest_type or 1
		self.m_quest_types = {self.m_quest_type}
	end

	self.isle_flag=self.m_params.isle_flag
	self.m_end_ts=self.m_params.m_end_ts

	self.m_can_get_flag = false --是否有可领取的奖励
	self:initData()
end

function M:initData(data)
	table.merge(self.m_data, data or {})
	self:initMainQuestsData()
end

function M:setGetFlag(flag)
	self.m_can_get_flag = flag
end

function M:getGetFlag()
	return self.m_can_get_flag
end

function M:initMainQuestsData()
	self.m_main_quests_data = {}
	self.tableName = "quest_special"
	for k,v in ipairs(self.m_quest_types) do
		if v == 104 then
			self.tableName = "credit_dice"
		end
		local quest_data = UserDataManager:getChapterQuestSpecialData(v, self.param)
		table.insertto(self.m_main_quests_data, quest_data)
	end
	if #self.m_quest_types > 1 then
		GameUtil:taskDataSort(self.m_main_quests_data)
	end
	self.m_show_point_cfg = nil
	for i, v in ipairs(self.m_main_quests_data) do
		if v.status == 0 then
			local show_point = v.cfg.show_point or 0
			if show_point > 0 then
				local quest_special = ConfigManager:getCfgByName(self.tableName)
				for k,v in ipairs(self.m_quest_types) do
					local quest_special_items = quest_special[v] or {}
					local quest_special_item = quest_special_items[show_point]
					if quest_special_item then
						self.m_show_point_cfg = quest_special_item
						break
					end
				end
			end
			break
		end
	end
end

function M:getMainQuestsData()
	return self.m_main_quests_data or {}
end

function M:getShowPointCfg()
	return self.m_show_point_cfg
end

function M:getQuestLockFlag(stage_id)
	return ConfigManager:getQuestLockFlag(stage_id)
end

return M
