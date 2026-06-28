local M = class("MailDetailPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_rewards = self.m_params.gift
end

function M:getContent()
	for k,v in pairs(self.m_params.content) do
		return k,v
	end
end


return M
