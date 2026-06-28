local M = class("PlotPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("chapter_unlock", nil, nil, nil, {forceBack = true})
end

function M:onEnter()
	self.m_callback = self.m_params.callback
	self.m_enter_callback = self.m_params.enter_callback
	self.m_new_heros = self.m_params.new_heros
	self.m_open_chapter = self.m_params.open_chapter
	self.m_demonstrate = self.m_params.demonstrate
end

return M
