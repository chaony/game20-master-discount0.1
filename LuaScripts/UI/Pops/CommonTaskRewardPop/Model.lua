local M = class("CommonTaskRewardPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_quest_Data = self.m_params.main_quest or {}
	self.m_questId = self.m_params.quest_id or {}
	self.m_callback = self.m_params.callback
	self.m_callbackNext = self.m_params.callbackNext
	self.m_show_next_chapter = self.m_params.show_next_chapter
	--self.m_questId, self.m_quest_Data = self:getShowData()
end

function M:questCfgName()
	local quest_tab = ConfigManager:getCfgByName("quest_main")
	local quest_cfg = quest_tab[tonumber(self.m_questId)]
	return Language:getTextByKey(quest_cfg.name) 
end

function M:getShowData()
	local temp_data = nil
	local temp_id = 0
	self.new_reward = {}
	if table.nums(self.m_quests) > 0 then
		for k,v in pairs(self.m_quests) do
			if temp_id == 0 then
				temp_id = k
				temp_data = v
			else
				self.new_reward[k] = v
			end
		end
	end 
	return temp_id,temp_data
end


return M
