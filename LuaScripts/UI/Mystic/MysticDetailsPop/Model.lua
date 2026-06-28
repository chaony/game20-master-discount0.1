local M = class("MysticDetailsPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_solt = self.m_params.solt
	self.m_oid = self.m_params.oid 
	if self.m_params.id then
		self.m_id = self.m_params.id
		self.m_evo = 1
	else
		local data = UserDataManager.mystic_data:getMysticDataById(self.m_oid)
		self.m_id = data.id
		self.m_evo = data.evo
	end
	self.m_look = self.m_params.look or 1
end

return M
