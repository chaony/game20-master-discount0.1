local M = class("MysticGroupDetailsPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_id = self.m_params.id
	self.m_lv = self.m_params.lv or 1
	self:initGroupData()
end

function M:initGroupData()
	local group_cfg = ConfigManager:getCfgByName("mystic_buff")
	local one_cfg = group_cfg[self.m_id][self.m_lv]
	self.m_group_cfg = one_cfg
end

return M
