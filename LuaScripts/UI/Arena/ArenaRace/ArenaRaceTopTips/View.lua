local M = class("ArenaRaceTopTipsView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaRace/ArenaTopTIpsPop"
M.m_size_type = 2

function M:onEnter()
	if self.m_model.m_rank then
		self:setTextByLanKey("cur_rank_text", "arena_str_0017", self.m_model.m_rank)
	end
	if self.m_model.m_content_des then
		self:setTextByLanKey("msg_text", self.m_model.m_content_des)
	end
	if self.m_model.m_title_des then
		self:setTextByLanKey("title_msg_text",  self.m_model.m_title_des)
	end
	if self.m_model.m_title then
		self:setTextByLanKey("common_title_text", self.m_model.m_title)
	end
	self:setTextByLanKey("ok_text", "new_str_0006")
	self:refreshUI()
	if self.m_model.m_call_back then
		self.m_model.m_call_back()
	end
end

function M:refreshUI()
end

return M