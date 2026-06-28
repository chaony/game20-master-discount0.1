local M = class("RacconGameEndModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_score = self.m_params.score
	self.m_content = self.m_params.content
end

function M:getScore()
	return self.m_score
end

function M:getContent()
	return self.m_content
end

return M
