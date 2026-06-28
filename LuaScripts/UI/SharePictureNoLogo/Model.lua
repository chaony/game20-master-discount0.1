local M = class("SharePictureModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_picture_callback = self.m_params.picture_callback
	self.m_sort = self.m_params.sort or 1
end

return M
