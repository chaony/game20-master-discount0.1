local M = class("GuildHighWarTaskPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("guild_high_war_new_quest_index")
end

function M:onEnter()
	self:UpdateData(self.m_data)
end

function M:UpdateData(data)
	self.m_data = data
	self.m_task_data = {}
	local quests = self.m_data.quests
	local cfg = ConfigManager:getCfgByName("guild_high_war_daliytask")
	for k,v in pairs(quests) do 
		local data = {}
		data.id = tonumber(k)
		data.target_id = cfg[tonumber(k)].target_id
		data.name = cfg[tonumber(k)].name 
		data.target_value =cfg[tonumber(k)].target_value
		data.reward = cfg[tonumber(k)].reward
		data.order = cfg[tonumber(k)].order
		data.cur_progress = v.value
		data.status = v.status
		table.insert(self.m_task_data,data)
	end
	table.sort(self.m_task_data,function(a, b) 
		return a.id<b.id
	end)
end


function M:getTaskData()
	--if task_key == self.m_task_tag_mine then
	--	return self.m_mine_task_data or {}
	--elseif task_key == self.m_task_tag_union then
	--	return self.m_union_task_data or {}
	--end
	return self.m_task_data
end


return M
