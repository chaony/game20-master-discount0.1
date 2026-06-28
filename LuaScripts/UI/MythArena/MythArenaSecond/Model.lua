

local M = class("MythArenaSecondModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_open_type = self.m_params.open_type or "now" -- last 历史
	self.m_last_stage = self.m_params.last_stage or 0
	self.m_last_group_id = self.m_params.last_group_id or 0
	self.m_cur_group_id = 1
	if self.m_open_type == "last" then
		local params = {}
		self.m_big_stage = self.m_params.real_big_stage or 1
		params.group_id = self.m_last_group_id
		params.stage_id = self.m_last_stage
		self.m_cur_group_id = self.m_last_group_id
		self:getData("myth_arena_group_logs", params)
	else
		self.m_big_stage = self.m_params.big_stage or 1
		self:getData("myth_arena_enter")
	end
end

function M:onEnter()
	self.m_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	self.m_small_stage = self.m_params.small_stage or 1 --1竞猜 2 战斗
	self.m_small_end_time = self.m_params.small_end_time or -1 
	self.m_myth_times_cfg = ConfigManager:getCfgByName("myth_times") or {}
	self.m_show_drop_down = false
	self:initData()
	self:updateData()
	
end

function M:initData()
	self.m_stage_name = Language:getTextByKey(self:getCurStageName())
end

function M:updateData(data)
	table.merge(self.m_data, data or {})
	self.m_logs = self.m_data.logs or {} 
	self.m_user_info = self.m_data.user_info or {} 
	self.m_guess_data = self.m_data.guess_data or {}
	self.m_cur_group_id = self.m_data.cur_group or 1
	self.m_max_group = self.m_data.max_group or 1
	self.m_self_group_id = self.m_data.self_group_id or 0
	self.m_is_jc = self.m_small_stage == 1 and self.m_self_group_id ~= self.m_cur_group_id
	self.m_group_data = self:getGroupData()
end

function M:updateGuessData(guess_data)
	if guess_data then
		table.merge(self.m_guess_data, guess_data)
	end
end

function M:getGroupData()
	local group_tab = {}
	for i = 1, self.m_max_group do
		table.insert(group_tab, i)
	end
	return group_tab
end

function M:setDropDownStatus()
	self.m_show_drop_down = not(self.m_show_drop_down)
end

function M:getLogsByIndex(index)
	if self.m_logs[index] then
		return self.m_logs[index]
	end
	return nil
end

function M:getUserInfoByUid(auid)
	local uid = tostring(auid)
	if self.m_user_info[uid] then
		return self.m_user_info[uid]
	end
	return nil
end

function M:getGuessDataByGroupId(group_id)
	local g_id = group_id or self.m_cur_group_id
	g_id = tostring(g_id)
	if self.m_guess_data[g_id] then
		return self.m_guess_data[g_id].uid
	end
	return nil
end

function M:getCurStageName()
	local stage_name = ""
	local stage_id = self.m_big_stage
	if self.m_open_type == "last" and self.m_last_stage > 0 then
		stage_id = self.m_last_stage
	end
	if self.m_myth_times_cfg[stage_id] then
		stage_name = self.m_myth_times_cfg[stage_id].name
	end
	return stage_name
end

function M:getEndTs()
	local end_ts = self.m_small_end_time - UserDataManager:getServerTime() + 1
	if self.m_open_type == "last" then
		end_ts = 999
	end
	return end_ts
end

function M:getImgPathByStage()
	local bg_path = ""
	local name_img_path = ""
	local stage_id = self.m_big_stage
	if self.m_open_type == "last" and self.m_last_stage > 0 then
		stage_id = self.m_last_stage
	end
	if stage_id == 3 or stage_id == 4 then
		bg_path = "a_wlsh_jjtt_qa"
		name_img_path = "a_fylt_deq_qizidi"
	elseif stage_id == 5 or stage_id == 6 then
		bg_path = "a_wlsh_jjtt_ql"
		name_img_path = "a_fylt_deq_qizileizhudi"
	elseif stage_id == 7 then
		bg_path = "a_fylt_deq_qizih"
		name_img_path = "a_fylt_deq_qizileizhudi"
	end
	return bg_path, name_img_path
end

function M:getCurStageId()
	local stage_id = self.m_big_stage
	if self.m_open_type == "last" and self.m_last_stage > 0 then
		stage_id = self.m_last_stage
	end
	return stage_id
end

return M