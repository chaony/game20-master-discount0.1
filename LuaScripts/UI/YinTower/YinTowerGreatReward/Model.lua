local M = class("YinTowerGreatRewardModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_index = self.m_params.index
	self.m_cell_data = self.m_params.cell_data
	if self.m_params.cell_data then
		self.m_bao_xiang_icon = self.m_params.cell_data.bao_xiang_icon
		self.m_vsn = self.m_params.cell_data.vsn
	end
end

function M:getIndex()
	return self.m_index
end

function M:getType()
	if self.m_cell_data then
		return self.m_cell_data.type
	end
	return 1
end

function M:getBoxStatus()
	if self.m_cell_data then
		return self.m_cell_data.status
	end
	return 0
end

function M:getGiftData()
	return self.m_cell_data.gifts
end

function M:getBaoXiangImg()
	return self.m_bao_xiang_icon
end

function M:getVSN()
	return self.m_vsn
end

return M
