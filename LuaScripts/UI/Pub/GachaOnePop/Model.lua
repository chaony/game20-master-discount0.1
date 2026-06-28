local M = class("GachaOnePopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_card = self.m_params.cards[1]
	self.m_pool_id = self.m_params.pool_id
	self.m_new_card = self.m_params.new_card
	self.m_type_index = self.m_params.type_index
	self.m_open = false
end

return M
