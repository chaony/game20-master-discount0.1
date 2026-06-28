local M = class("RacconFinalPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_callback = self.m_params.callback
	self.m_callback_new = self.m_params.callback_new
	self.m_status,self.m_task_id = self:getTaskData()
end

function M:getTaskData()
	local status, task_id = nil, nil
	if self.m_common_quest_pop == true then
		return
	end
	local active = UserDataManager:getActivesDataByOpenId(347)
	if active and active.version then
		local lianliankan_quest = ConfigManager:getCfgByName("lianliankan_quest") or {}
		local cur_task_cfg = lianliankan_quest[347] or {}
		local cur_vsn_cfg = cur_task_cfg[active.version] or {}
		for i, v in pairs(cur_vsn_cfg) do
			task_id = i
		end
		if task_id > 0 then
			local common_quest_data = UserDataManager.m_common_quest["347"] or {}
			local cur_vsn = common_quest_data[tostring(active.version)] or {}
			for i, v in pairs(cur_vsn) do
				if tostring(task_id) == i then
					status = v.status
				end
			end
		end
	end
	return status, task_id
end
function M:getEndTs()
	local active = UserDataManager:getActivesDataByOpenId(347)
	if active and active.end_ts then
		return active.end_ts - UserDataManager:getServerTime() + 1
	end
	return 0
end
--"a_xhx_bklq_btn" a_xhx_klq_btn a_xhx_ylj_btn
function M:getBtnImg()
	if self.m_status == 0 then
		return "a_xhx_bklq_btn"
	elseif self.m_status == 1 then
		return "a_xhx_klq_btn"
	elseif self.m_status == 2 then
		return "a_xhx_ylj_btn"
	end
end

return M
