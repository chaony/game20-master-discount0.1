local M = class("QiMenDunJiaContentPopTwoModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	--self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_content_str = self.m_params.content_str or ""
end

function M:getConstent()
	return self.m_content_str
end

return M
