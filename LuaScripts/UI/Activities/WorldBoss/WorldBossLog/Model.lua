local M = class("WorldBossLogModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_data = {}
	self.m_battle_config_id = self.m_params.battle_config_id
	self:initData(self.m_params)
end

function M:getShowData()
	local logs = self.m_data.damage_log or {}
	return logs
end

function M:initData(data)
	-- Logger.log(data,"data ====")
    table.merge(self.m_data, data)
end

return M
