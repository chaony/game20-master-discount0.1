local M = class("MythArenaSecondRecordPopModel", LikeOO.OODataBase)

function M:onCreate()
	-- self.m_transfer = "up_to_down"
	self.m_real_big_stage = self.m_params.big_stage
	self.m_cur_big_stage_id = math.min(6, self.m_params.big_stage - 1) --最高展示到半决赛
	M.super.onCreate(self)
	self:getData("myth_arena_stage_logs", {stage_id = self.m_cur_big_stage_id})
end

function M:onEnter()
	self.m_tab_id = {}
	self.m_total_logs = {}
	self:initTagData()
	self:updateData()
	self.m_select_index = 1
	self.m_myth_times_cfg = ConfigManager:getCfgByName("myth_times") or {}
end

function M:initTagData()
	self.m_tab_id[1] = self.m_cur_big_stage_id
	if self.m_cur_big_stage_id - 1 > 2 then
		self.m_tab_id[2] = self.m_cur_big_stage_id - 1
	end
end

function M:updateData(data)
	if data then
		table.merge(self.m_data, data)
	end
	self:updateLogData(self.m_data.logs)
end

function M:updateLogData(logs_data)
	if self.m_total_logs[self.m_cur_big_stage_id] == nil then
		self.m_total_logs[self.m_cur_big_stage_id] = logs_data
	else
		table.merge(self.m_total_logs[self.m_cur_big_stage_id], logs_data)
	end
end

function M:getCurLogs()
	if self.m_total_logs[self.m_cur_big_stage_id] then
		return self.m_total_logs[self.m_cur_big_stage_id]
	end
	return {}
end

function M:getCfgValueByKey(cfg_key)
	if self.m_myth_times_cfg[cfg_key] then
		return self.m_myth_times_cfg[cfg_key]
	end
	return nil
end

return M
