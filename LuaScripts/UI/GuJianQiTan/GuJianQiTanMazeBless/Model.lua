local M = class("GuJianQiTanMazeBlessModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData("")
end

function M:onEnter()
	self.m_sword_akuma_buff = ConfigManager:getCfgByName("sword_akuma_buff") or {}
	self.m_callBack = self.m_params.callback
	local data = self.m_params.data or {}
	self.m_cur_cell_id = data.id or 0
	self.m_buff_index = data.buff or {}
	self.m_cur_cfg_id = self.m_buff_index[1] and self.m_buff_index[1].buff_id or 1
	self.m_cur_index = 1
end

function M:getCfgDataByKey(cfg_id, key)
	local cur_cfg = self.m_sword_akuma_buff[cfg_id] or {}
	local value = cur_cfg[key] or nil
	return value
end


return M
