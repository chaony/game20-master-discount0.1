local M = class("CommonPopView",LikeOO.OOPopBase)
--拜师成功
M.m_uiName = "Pops/SuccessFromMasterPop"
M.m_size_type = 2

function M:onEnter()	
	self:refreshUI()
end

function M:refreshUI()
	local master_obj = self:findGameObject("head_node")
	local app_obj = self:findGameObject("head_node2")
	if self.m_model.m_status == 1 then
		self:setHeadNode(master_obj, self.m_model.m_info)
		self:setHeadNode(app_obj, UserDataManager.user_data.user_status)
		self:setTextByLanKey("title_text", "master_apprentice_str_0033")
		self:setTextByLanKey("master_name", self.m_model.m_info.name)
		self:setTextByLanKey("appren_name", UserDataManager.user_data.user_status.name)
	else	
		self:setTextByLanKey("title_text", "master_apprentice_str_0034")
		self:setHeadNode(master_obj, UserDataManager.user_data.user_status )
		self:setHeadNode(app_obj,self.m_model.m_info)
		self:setTextByLanKey("appren_name", self.m_model.m_info.name)
		self:setTextByLanKey("master_name", UserDataManager.user_data.user_status.name)
	end
end

function M:setHeadNode(obj, data)
	
end


return M