local M = class("ArenaNormalLogModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("arena_arena_logs")
end

function M:onEnter()
	self.m_free_times = self.m_params.free_times or 0
	self.m_master_uid = self.m_data.mentor or 0 --师傅Uid
	self.m_revenge_times = self.m_data.revenge_times --使用过的复仇次数
end

function M:getShowData()
	local logs = self.m_data.logs or {}
	return logs
end

function M:getFreeTimes()
	local arena_free_times = ConfigManager:getVipValueByKey("arena_free_times", 0)
	return arena_free_times - self.m_free_times
end

function M:initData(data)
    table.merge(self.m_data, data)
end

return M
