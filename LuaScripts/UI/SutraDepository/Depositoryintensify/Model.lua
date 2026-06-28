local M = class("DepositoryintensifyModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.mystic_type = self.m_params.mystic_type
	self.mystic_lv = self.m_params.mystic_lv
end



return M
