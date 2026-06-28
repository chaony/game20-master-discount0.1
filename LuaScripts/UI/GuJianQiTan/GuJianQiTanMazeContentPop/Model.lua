local M = class("GuJianQiTanMazeContentPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_content_data = self.m_params.content_data or {}
end

function M:getConstent()
	self.m_content_str = ""
	local title, detail
	for k, v in pairs(self.m_content_data) do
		title = v.title or ""
		detail = v.detail or ""
		self.m_content_str = self.m_content_str .. title .. "\n" .. detail .. "\n\n"
	end
	return self.m_content_str or ""
end

return M
