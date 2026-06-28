local M = class("CommonGetRedPacketPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_reward = self.m_params.reward 
end


return M
