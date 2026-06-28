local M = class("UnionIndexView",LikeOO.OOPopBase)

M.m_uiName = "Union/UnionIndexPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0403")
	self:setTextByLanKey("create_btn_text", "union_str_1068")
	self:setTextByLanKey("join_btn_text", "union_str_1067")
	self:setTextByLanKey("artifact_btn_text", "union_str_1040")
	self:refreshUI()
end

function M:refreshUI()
	self:setObjectVisible("create_bg_img", false)	
	-- if self.m_model.creat_limit > 0 then
	--self:setTextByLanKey("create_des", "union_str_0061", self.m_model.creat_limit)
	-- self:setObjectVisible("create_bg_img", self.m_model:checkCanCreatTeam() == false)
	-- 	self:setObjectVisible("create_bg_img", false)
	-- else
	-- 	self:setObjectVisible("create_bg_img", false)	
	-- end
end

return M