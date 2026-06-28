local M = class("HotelRunGainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_hotel_level = self.m_params.hotel_level
	self.m_outputs = self.m_params.outputs
	self.m_spine_res = self.m_params.spine_res
	self.m_unlock = self.m_params.unlock
	self.m_gain_value = 0
	for i, v in pairs(self.m_outputs) do
		self.m_gain_value = self.m_gain_value + v
	end
end

return M