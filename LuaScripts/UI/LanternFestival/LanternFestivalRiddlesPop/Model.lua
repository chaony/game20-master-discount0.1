local M = class("LanternFestivalRiddlesPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("")
end

function M:onEnter()
	self.m_riddle_rewards = self.m_params.riddle_rewards or {}
	self.m_status_data = self.m_params.status_data or {}
	self.m_version = self.m_params.version or 1
	self.m_question_index = self.m_params.question_index or 1
	self.m_lantern_login_cfg = ConfigManager:getCfgByName("lantern_login") or {}
	self.m_lantern_riddle_cfg = ConfigManager:getCfgByName("lantern_riddle") or {}
	self.m_cur_select = self.m_status_data.ans or 0
end

function M:getQuestion()
	local library = nil
	if self.m_lantern_login_cfg[self.m_version] and self.m_lantern_login_cfg[self.m_version][self.m_question_index] then
		library = self.m_lantern_login_cfg[self.m_version][self.m_question_index]["library"]
	end
	if self.m_status_data.id and library and self.m_lantern_riddle_cfg[library] and self.m_lantern_riddle_cfg[library][self.m_status_data.id] then
		return self.m_lantern_riddle_cfg[library][self.m_status_data.id]
	end
	return nil
end

--function M:getRightIndex()
--	return 2
--end

function M:getRiddleRewardByIndex(index)
	if self.m_riddle_rewards[index] then
		return self.m_riddle_rewards[index]
	end
	return nil
end

function M:initData(response)
	self.m_version = response.version or 1
	self.m_status_data.res = response.res
end  
  

return M
