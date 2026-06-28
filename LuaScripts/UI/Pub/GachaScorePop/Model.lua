local M = class("GachaScorePopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	--self.m_pool_id = self.m_params.pool_id
	self.m_score = self.m_params.value
	self.m_score_consume = self.m_params.consume
end

return M