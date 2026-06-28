local M = class("ArenaRaceTopTipsModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("arena_index")
end

function M:onEnter()
	self.m_rank = self.m_params.rank
	self.m_title_des = self.m_params.title_des
	self.m_title = self.m_params.title
	self.m_content_des = self.m_params.content_des
	self.m_ok_call_back = self.m_params.ok_call_back
end

return M
