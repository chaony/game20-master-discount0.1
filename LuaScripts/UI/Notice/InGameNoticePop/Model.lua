local M = class("InGameNoticePopModel",LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end


function M:onEnter()
	self.m_callback = self.m_params.callback
	self.m_callback_new = self.m_params.callback_new
	self.m_notice = {}
	self.current_id = 1
end



--获取公告信息
function M:getNoticeContent(id)
	for i, v in pairs(self.m_notice) do
		if i == id then
			return v
		end
	end
	return nil
end

--获取公告信息数量
function M:getNoticeListCount()
	return #self.m_notice
end

return M
