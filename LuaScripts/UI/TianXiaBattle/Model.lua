local M = class("TianXiaBattleModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("world_group_index")
end

function M:onEnter()
	self.m_servers = self.m_data.servers or {}
	self.m_regroup_time = self.m_data.regroup_time or ""
end

function M:getShowData()
	return self.m_servers
end

return M
