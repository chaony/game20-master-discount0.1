local M = class("ThreeHeroesFiveGallantsHeroTrainTaskModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_task_data = self.m_params.data
	self.version = self.m_params.version
	self.camp = self.m_params.camp or 1
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
	local quest_tab = ConfigManager:getCfgByName("chivalrous_practice_quest")
	local vsn_quest_tab = quest_tab[self.camp]
	local show_quest = {}
	for i=1,#vsn_quest_tab do
		local data = self:getQuestData(i)
		if next(data) ~= nil then
			local quest_data = {}
			quest_data.cfg = vsn_quest_tab[i]
			quest_data.data = data
			quest_data.id = i
			table.insert(show_quest, quest_data)
		end 
	end
	return show_quest
end

function M:getQuestData(id)
	return self.m_task_data[tostring(id)] or {}
end

return M