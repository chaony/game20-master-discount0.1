local M = class("HuntTreasuresGuildTXServerModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("active_mining_group_index",{ver = self.m_params.version})
end

function M:onEnter()
	self.m_servers = self.m_data.servers or {}
	self.m_act_data = UserDataManager:getActivesDataByOpenId(287)
end

function M:getShowData()
	return self.m_servers
end

function M:getEndTs()
	if self.m_act_data and self.m_act_data.end_ts then
		return self.m_act_data.end_ts - UserDataManager:getServerTime()
	end
	return 0
end


return M
