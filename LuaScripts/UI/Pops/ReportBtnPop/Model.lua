local M = class("ReportBtnPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_obj = self.m_params.obj -- 目标预制
	self.m_module_id = self.m_params.module_id -- 对应举报界面的id
	self.m_user_name = self.m_params.name
	self.m_uid = self.m_params.uid
	self.m_chat = self.m_params.chat
end

return M
