local M = class("DaySevenPopModel", LikeOO.OODataBase)

M.point = {}
TONGYONG_ZHAOYUN = {[1] = {image = "z_zyzd_txh_bg",hero_id =511},[2]= {image = "z_zyzd_txh",hero_id = 605}}
function M:onCreate()
	--self:getData("common_quest_recv_task")
	--self.m_open_id = 381
	--self.m_actives = UserDataManager:getActivesDataByOpenId(self.m_open_id)
	--self.m_version =self.m_actives and  self.m_actives.version or 1
	--self:getData("common_quest_index",{open_id = self.m_open_id, vsn = self.m_version or 1})
	self:getData()
end

function M:onEnter()
	self.is_open_type = 2
	self.m_callback = self.m_params.callback
	self.m_callback_new = self.m_params.callback_new
	self.m_task_data = {}
	self.m_hero_stats = 0 --0 未完成(领取灰) 1 领取 2 已领取
	--self:refreshData(self.m_data or {})
	self.m_current_num = 0
    self.m_all_num = 3
	self:InitTaskData()
end

function M:InitTaskData()
	local cfg = ConfigManager:getCfgByName("common")
	table.insert(self.m_task_data,cfg[810].value)
	for k,v in ipairs(cfg[811].value) do
		table.insert(self.m_task_data,v)
	end
	table.insert(self.m_task_data,cfg[812].value)
	--table.insert(self.m_task_data,cfg[813].value)
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
	local versionData = IDData[self.m_version or 1]
	for k,v in pairs(indexData.quests) do
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
	self.m_hero_stats = 0
	local status = indexData.union_data or 0
	if status == 1 then  --已领取
		self.m_hero_stats = 2
	elseif status == 0 then --未领取
		-- 判断领取条件
		if self:IsGetHero() == true then
			self.m_hero_stats = 1
		else
			self.m_hero_stats = 0
		end
	end
end

return M