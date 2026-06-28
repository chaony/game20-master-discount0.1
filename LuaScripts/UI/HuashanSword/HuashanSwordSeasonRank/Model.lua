local M = class("HuashanSwordSeasonRankModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	
end

function M:getShowData()
	local logs = self.m_data.logs or {}
	return logs
end

function M:initData(data)
    table.merge(self.m_data, data)
end

return M
