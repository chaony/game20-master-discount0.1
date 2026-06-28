local M = class("MasterApprenticeRewardPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData("mentorship_quest_index")
end

function M:onEnter()
	self.m_status = self.m_params.status
	self.m_master = self.m_params.master
	self:initData()
end

function M:initData(data)
	if data then
		self.m_data = data
	end
	self.m_quests = self.m_data.quests
	self.m_task_list = self:getTaskList()
end

function M:getTaskList()
	local list = {}
	local tab = ConfigManager:getCfgByName("quest_master")	
	for k,v in pairs(tab) do
		--if v.type == self.m_status then
		--end
		if v.pre_id and self:checkPreId(k) == true then
			table.insert( list, k)
		end
	end
	return list
end

function M:checkPreId(id)
	for k,v in pairs(self.m_quests) do
		if id == tonumber(k) then
			return true
		end
	end
	return false
end

function M:getTaskData(id)
	local tab = ConfigManager:getCfgByName("quest_master")
	local cfg = tab[id]
	local data = self.m_quests[tostring(id)]
	return data, cfg
end

function M:chechMasterStatue()
	if self.m_status == 2 then
		return true
	end
	local open_flag, tips = BtnOpenUtil:isBtnOpen(52)
	return open_flag
end

function M:formNum(num)
	local t1, t2 = math.modf(num)
	return t1
end


return M
