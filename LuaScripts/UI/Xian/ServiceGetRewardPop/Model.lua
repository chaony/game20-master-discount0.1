local M = class("ServiceGetRewardPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_reard_data = self.m_params.data or {}
	self.m_rewards = self.m_reard_data.data.gifts or {}
	self.m_callback = self.m_params.callback
end




return M
