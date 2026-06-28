local M = class("PlayerBackToNewModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.server_data = self.m_params.servers or {}
	self.m_callback = self.m_params.callback
	self.m_callback_new = self.m_params.callback_new
end

function M:getListData()
	return self.server_data
end

function M:getDayLimit()
	local haogan = 3
	local common_tab = ConfigManager:getCfgByName("common")
	if common_tab[592] and common_tab[592].value then
		haogan = common_tab[592].value
	end
	return haogan
end

return M
