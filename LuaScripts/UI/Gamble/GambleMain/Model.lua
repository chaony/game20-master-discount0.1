local M = class("GambleMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_open_id = 428
	local active_data = self:getActiveData()
	self.m_version = active_data.version or 1
	self:getData("world_cup_index", {open_id = self.m_open_id, version = self.m_version})
end

function M:onEnter()
	self.m_selected_index = 1
	self.m_data_main = {}
	self:initData()
	self:initSelectedIndex()
end

function M:initSelectedIndex()
	for k, v in pairs(self.m_data_main) do
		if v and v.data and v.data.stage == 1 then
			self.m_selected_index = k
			break
		end
	end
end

function M:setSelectedIndex(index)
	self.m_selected_index = index
end

function M:getSelectedIndex()
	return self.m_selected_index
end

function M:getOpenID()
	return self.m_open_id
end

function M:getVersion()
	return self.m_version
end

function M:updateData(data)
	table.merge(self.m_data, data)
	self:initData()
end

function M:dataOutdateCheck()
	local out_date_flag = false
	local server_time = UserDataManager:getServerTime()
	for k, v in pairs(self.m_data_main) do
		if v.data.end_time <= server_time and v.data.status ~= 2 then
			out_date_flag = true
			break
		end
	end
	if out_date_flag == true then
		self:initData()
	end
end

function M:initData()
	self.m_data_main = {}
	
	local server_time = UserDataManager:getServerTime()
	
	local world_cup_group_tab = ConfigManager:getCfgByName("world_cup_group") or {}
	local world_cup_group_tab_open_id = world_cup_group_tab[self.m_open_id] or {}
	local world_cup_group_tab_version = world_cup_group_tab_open_id[self.m_version] or {}
	local world_cup_question = ConfigManager:getCfgByName("world_cup_question") or {}
	local world_cup_question_open_id = world_cup_question[self.m_open_id] or {}
	local world_cup_question_version = world_cup_question_open_id[self.m_version] or {}
	
	local groups = {}
	for k, v in pairs(self.m_data.groups or {}) do
		groups[tonumber(k)] = {}
		for kk, vv in pairs(v) do
			groups[tonumber(k)][tonumber(kk)] = vv
		end
	end

	local data
	local cfg
	local group_item
	local question_item
	for k, v in pairs(groups) do
		cfg = world_cup_group_tab_version[k] or {}
		data = table.copy(v)
		data.id = k
		data.stage = 3
		data.end_time = GameUtil:stringToTimesTamp(cfg.end_time)
		group_item = {data = data, cfg = cfg, questions = {}}
		self.m_data_main[k] = group_item
		for kk, vv in pairs(v) do
			cfg = world_cup_question_version[k][kk] or {}
			data = table.copy(vv)
			data.id = kk
			data.status = 0	--0 未选择，1 已选择
			if data.option and #data.option > 0 then
				data.status = 1
			end
			data.stage = 1 --1 预测期， 2 等待结果期， 3 展示期
			if group_item.data.end_time <= server_time then
				data.stage = 2
				if cfg.correct_answer and #cfg.correct_answer > 0 then
					data.stage = 3
				end
			end
			if data.stage < group_item.data.stage then
				group_item.data.stage = data.stage
			end
			self.m_data_main[k].questions[kk] = {data = data, cfg = cfg}
		end
	end
end

function M:getMainData()
	return self.m_data_main
end

function M:getSelectedMainData()
	return self.m_data_main[self.m_selected_index]
end

function M:getRankCfg()
	local world_cup_tab = ConfigManager:getCfgByName("world_cup") or {}
	local world_cup_tab_open_id = world_cup_tab[self.m_open_id] or {}
	local world_cup_tab_version = world_cup_tab_open_id[self.m_version] or {}
	local link_data = world_cup_tab_version.link_open_id or {}
	return {open_id = link_data[1], version = link_data[2]}
end

function M:getHelpContent()
	local world_cup_tab = ConfigManager:getCfgByName("world_cup") or {}
	local world_cup_tab_open_id = world_cup_tab[self.m_open_id] or {}
	local world_cup_tab_version = world_cup_tab_open_id[self.m_version] or {}
	return world_cup_tab_version.des or ""
end

function M:getActiveData()
	return UserDataManager:getActivesDataByOpenId(self.m_open_id) or {}
end

function M:getActiveCfg()
	local activity_info = self:getActiveData()
	local active_tab = ConfigManager:getCfgByName("active")
	return active_tab[activity_info.id or 0]
end

--当前小组赛的剩余时间
function M:getCurrentGroupTimeLeft()
	local left_time = 0
	local toggle_data = self:getSelectedMainData()
	if toggle_data then
		local server_time = UserDataManager:getServerTime()
		local end_time = toggle_data.data.end_time
		left_time = end_time - server_time
		return left_time, toggle_data.data.stage
	end
end

--整个活动的结束时间
function M:getActivityTimeLeft()
	local left_time = 0
	local activity_data = self:getActiveData()
	if activity_data then
		local server_time = UserDataManager:getServerTime()
		local end_time = activity_data.end_ts
		left_time = end_time - server_time
	end
	return left_time
end

return M
