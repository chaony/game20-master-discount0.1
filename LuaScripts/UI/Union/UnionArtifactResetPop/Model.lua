local M = class("UnionArtifactResetPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_on_ok_call = self.m_params.on_ok_call
	self.m_on_cancel_call = self.m_params.on_cancel_call
	self.m_ok_text = self.m_params.ok_text or Language:getTextByKey("new_str_0006")
	self.m_cancel_text = self.m_params.cancel_text or Language:getTextByKey("new_str_0007")
	self.m_text = self.m_params.text or ""
	self.m_title = self.m_params.title or Language:getTextByKey("union_str_0019")
	self.m_cost = self.m_params.cost
	self.m_return_lvup_cost = self.m_params.return_lvup_cost
end

return M
