local M = class("WindAndCloudReceiveRedPacketModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self:getData()
end

function M:onEnter()
	self.m_reward = self.m_params.data.reward or {}
	self.m_info = self.m_params.gameer_data or {}
end

return M
