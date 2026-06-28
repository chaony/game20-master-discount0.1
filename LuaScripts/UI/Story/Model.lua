local M = class("StoryModel", LikeOO.OODataBase)

function M:onCreate()
	--self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
end

return M
