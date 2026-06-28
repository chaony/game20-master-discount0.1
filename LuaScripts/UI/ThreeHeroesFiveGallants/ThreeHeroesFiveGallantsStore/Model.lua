local M = class("ThreeHeroesFiveGallantsStoreModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.Map2DControl = require("UI.ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsMap2D.Map2DControl").new()
	self.current_tab = 1
	self.open_id = self.m_params.open_id or 386
	self.version = self.m_params.version or 1
	self.cur_camp = self.m_params.cur_camp or 1 --阵营
	self.m_score = self.m_params.score or 0 --侠义值
	self.m_recv_chivalrous = self.m_params.recv_chivalrous or {}
	self:updateStoreData() --获得故事数据
	UserDataManager.local_data:setUserDataByKey("track_task_activity", self.m_params.tasks or {})

	local task_table = ConfigManager:getCfgByName("active_plot_task")
	local task_team_table = ConfigManager:getCfgByName("active_plot_taskteam")
	
	local track_task = {}
	for k, v in pairs(self.m_params.tasks or {}) do
		local task_id = tonumber(k)
		local task_team_id = task_table[task_id].tasks_types
		local task_team = task_team_table[task_team_id]
		track_task[tostring(task_team.map_id)] = task_id
	end
	UserDataManager.local_data:setUserDataByKey("track_task_activity", track_task)

	UserDataManager:setTasksActivityData(self.m_params.tasks or {})
end

function M:getVersion()
	return self.version
end

function M:updateData(data)
	table.merge(self.m_recv_chivalrous, data)
end

--故事数据
function M:updateStoreData()
	self.m_store_data = {}
	local active_plot_map = ConfigManager:getCfgByName("active_plot_map")
	local active_plot_taskteam = ConfigManager:getCfgByName("active_plot_taskteam")
	local map_id_self = {}
	for k, v in pairs(active_plot_taskteam) do
		if v.camp == self.cur_camp then
			map_id_self = v.map_team
		end
	end
	for k, v in pairs(active_plot_map) do
		if v.camp == self.cur_camp then
			for kk, vv in pairs(map_id_self) do
				if v.mother_map_id == vv then
					table.insert(self.m_store_data,{map_id = k, open_condition = v.Opening_conditions, cfg = v})
					break
				end
			end
		end
	end
	
	table.sort(self.m_store_data, function(a, b) return a.map_id < b.map_id end)
	
	self.m_bg_data = {}
	local index = 1
	for k, v in pairs(self.m_store_data) do
		local got_flag = false
		for kk, vv in pairs(self.m_bg_data) do
			if vv == v.cfg.mother_map_id then
				got_flag = true
				break
			end
		end
		if got_flag == false then
			self.m_bg_data[index] = v.cfg.mother_map_id
			index = index + 1
		end
	end
end

function M:getStoreData()
	return self.m_store_data
end

function M:getCurrentBGName()
	local active_plot_map = ConfigManager:getCfgByName("active_plot_map")
	local map_id = self.m_bg_data[self.current_tab] or 0
	return active_plot_map[map_id].map_resource or ""
end

--获取奖励宝箱
function M:getRewardBoxData()
	local chivalrous_period = ConfigManager:getCfgByName("chivalrous_period")
	local chivalrous_camp = ConfigManager:getCfgByName("chivalrous_camp")
	local chivalrous_reward = ConfigManager:getCfgByName("chivalrous_reward")

	local day_count = 0
	local activity_info = UserDataManager:getActivesDataByOpenId(self.open_id)
	if activity_info then
		local server_time = UserDataManager:getServerTime()
		day_count = math.floor((server_time - activity_info.start_ts) / (60 * 60 * 24)) + 1
	end
	
	local key = 1
	local chivalrous_period_version = chivalrous_period[self.version] or {}
	for k, v in pairs(chivalrous_period_version) do
		key = k
		if day_count <= v.end_day then
			break
		end
	end

	local method_id = chivalrous_camp[1][self.m_params.period][self.cur_camp].method or 1001
	
	local reward_node = {}
	for i, v in pairs(chivalrous_reward[method_id][3]) do
		local status = -1 -- -1：未开启  1：可领取  2：已领取
		if v.parameter <= self.m_score then
			status = 1
			for kk, vv in pairs(self.m_recv_chivalrous) do
				if i == vv then
					status = 2
					break
				end
			end
		end
		table.insert(reward_node,{id = i,cfg = v,status = status})
	end
	table.sort(reward_node, function(a, b) return a.cfg.parameter < b.cfg.parameter end)
	return reward_node, self.m_score
end

--获取活动名称
function M:getActiveName()
	local open_condition = ConfigManager:getCfgByName("open_condition")
	local name = open_condition[self.open_id].name
	return name or ""
end

return M
