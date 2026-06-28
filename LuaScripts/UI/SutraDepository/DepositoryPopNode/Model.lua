local M = class("DepositoryPopNodeModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_oid = self.m_params.cur_m_oid
	self.m_mode = self.m_params.mode or 1
	self.m_mystic_slots = self.m_params.mystic_slots or {}
	self.m_callback = self.m_params.callback
	self.m_old_star = self.m_params.old_star
	--self:initMysticGroup()
end

function M:getMysticData()
	local data,cfg = nil,nil
	if self.m_mode == 2 then
		cfg = UserDataManager.mystic_data:getMysticConfigByCid(self.m_oid)
	else
		data,cfg = UserDataManager.mystic_data:getMysticDataById(self.m_oid)
	end
	return data,cfg
end


function M:getMysticGroup()
	return self.m_group_cfg
end

return M
