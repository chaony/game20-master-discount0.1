local M = class("HuashanSwordLogModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("arena_mountain_hua_arena_logs")
end

function M:onEnter()
	self.m_version = self.m_params.vsn or 0
end

function M:getShowData()
	local logs = self.m_data.logs or {}
	return logs
end

function M:initData(data)
    table.merge(self.m_data, data)
end

return M
