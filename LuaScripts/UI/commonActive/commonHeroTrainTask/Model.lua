local M = class("commonHeroTrainTaskModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_task_data = self.m_params.data
	self.version = self.m_params.version or 1
	self.open_id = self.m_params.open_id or 395
	self.refresh_ui_name = self.m_params.refresh_ui_name or "Chivalry.ChivalryBattle"
	self.m_callback = self.m_params.callback
end


function M:updateQuests(data)
	self.m_task_data = data.quests
end

function M:checkActiveIsEnd()
	for k,v in pairs(self.hero_train_data.actives) do
		if v.open_status > 0 then
			return v.end_ts - UserDataManager:getServerTime()
		end
	end
    return 0
end

function M:getQuestList()
	local quest_tab = ConfigManager:getCfgByName("active_train_quest")
	local vsn_quest_tab = quest_tab[self.open_id][self.version]
	local show_quest = {}
	for i=1,#vsn_quest_tab[1] do
		local data = self:getQuestData(i)
		if next(data) ~= nil then
			local quest_data = {}
			quest_data.cfg = vsn_quest_tab[1][i]
			quest_data.data = data
			quest_data.id = i
			table.insert(show_quest, quest_data)
		end 
	end
	return show_quest
end

function M:getQuestData(id)
	if self.m_task_data then
		return self.m_task_data[tostring(id)] or {}
	end
	return {}
end

return M