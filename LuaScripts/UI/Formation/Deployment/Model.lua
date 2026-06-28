local M = class("DeploymentModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_deployment_id = self.m_params.deployment_id or 1
end

function M:getShowData()
	local show_data = UserDataManager.deployment_data or {}
	return show_data
end

return M
