local M = class("GuJianQiTanMazeBattleOverModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params.data or {}
end

function M:getAllGifts()
	return self.m_data.all_gifts or {}
end

return M
