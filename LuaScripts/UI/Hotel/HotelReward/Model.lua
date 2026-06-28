local M = class("HotelRewardModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_level = self.m_params.level
	self.m_is_daily_reward = self.m_params.is_point
end

return M