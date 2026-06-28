local M = class("CommonHelpPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_title = self.m_params.title
	self.m_content = self.m_params.content
	self.m_history = self.m_params.history
	self.m_tab_index = 1
end

function M:setTab(index)
	self.m_tab_index = index
end

return M
