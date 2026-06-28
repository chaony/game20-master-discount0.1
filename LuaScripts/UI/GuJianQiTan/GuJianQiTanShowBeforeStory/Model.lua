local M = class("GuJianQiTanShowBeforeStoryModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.new_chapter = self.m_params.new_chapter;
	self.m_mode = self.m_params.mode or 0
	self.m_open_event = self.m_params.open_event or 0
end

return M
