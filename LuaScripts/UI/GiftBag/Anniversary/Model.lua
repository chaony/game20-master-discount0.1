local M = class("AnniversaryModel", LikeOO.OODataBase)

M.point = {}
TONGYONG_ZHAOYUN = {[1] = {image = "z_zyzd_txh_bg",hero_id =511},[2]= {image = "z_zyzd_txh",hero_id = 605}}
function M:onCreate()
	--self:getData("common_quest_recv_task")
	self.m_open_id = self.m_params.open_id or 418
	self.m_actives = UserDataManager:getActivesDataByOpenId(self.m_open_id)
	self.m_version =self.m_actives and  self.m_actives.version or 1
	self:getData("common_quest_index",{open_id = self.m_open_id, vsn = self.m_version or 1})
	--self:getData()
end

function M:onEnter()
	self.is_open_type = 2
	self.m_callback = self.m_params.callback
	self.m_callback_new = self.m_params.callback_new
	self.m_task_data = {}
	self.m_hero_stats = 0 --0 未完成(领取灰) 1 领取 2 已领取
	self:refreshData(self.m_data or {})
	self.m_current_num = 0
    self.m_all_num = 3
end

--获取活动结束时间
function M:getEndTs()
	if self.m_actives and self.m_actives.end_ts then
		return self.m_actives.end_ts
	end
	return 0
end

--是否达成条件
function M:IsGetHero()
	local data = self.m_task_data or {}
	if not data or data == {} then return false end
	for k,v in ipairs(data) do
		if v.status == 1 or v.status == 0 then
			return false
		end
	end
	return true
end

function M:GetCurrentTaskNum()
	local data = self.m_task_data or {}
	self.m_current_num = 0
	for k,v in ipairs(data) do
		if v.status == 1 or v.status == 2 then
			self.m_current_num = self.m_current_num + 1
		end
	end
	return self.m_current_num
end
function M:refreshData(indexData)
	if not indexData then return end 
	self.m_task_data = {}
	local configData = ConfigManager:getCfgByName("lianliankan_quest")
	local IDData  = configData[self.m_open_id]
	if not IDData then return end
	local versionData = IDData[self.m_version or 1]
	for k,v in pairs(indexData.quests ) do
		local data = {}
		data.id = k
		data.reward = versionData[tonumber(k)].reward[1]
		data.status = v.status
		table.insert(self.m_task_data,data)
	end
	table.sort(self.m_task_data,function(a,b)
		return a.id< b.id
	end)
	--侠客
end

return M