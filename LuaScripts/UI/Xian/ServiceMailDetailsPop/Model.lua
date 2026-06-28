local M = class("ServiceMailDetailsPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"
	self:getData()
end

function M:onEnter()
	self.m_mail_data = self.m_params or {}
	self.m_rewards = self.m_mail_data.data.gifts
end

return M
