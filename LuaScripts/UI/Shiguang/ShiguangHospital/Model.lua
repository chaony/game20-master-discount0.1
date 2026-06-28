local M = class("ShiguangHospitalModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_cell_data = self.m_params.data
	self.m_open_flag = self.m_cell_data.open_flag
end

return M
