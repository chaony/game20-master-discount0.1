local M = class("QiMenDunJiaContentPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_content_key = self.m_params.content_key or ""
end

function M:getConstent()
	return self.m_content_key
end

return M
