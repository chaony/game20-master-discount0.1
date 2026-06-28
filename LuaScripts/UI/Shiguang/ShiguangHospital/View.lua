local M = class("ShiguangHospitalView",LikeOO.OOPopBase)

M.m_uiName = "Shiguang/ShiguangHospital"
M.m_size_type = 2

function M:onEnter()
	-- 治疗、供奉
	self:setTextByLanKey("ok_btn_text", self.m_model.m_cell_data.type == 12 and "new_str_0158" or "new_str_0161")
	if self.m_model.m_cell_data.type == 12 then --5.医馆
		self:setTextByLanKey("common_title_text", "new_str_0156")
		self:setTextByLanKey("tips_text", "new_str_0157")
	elseif self.m_model.m_cell_data.type == 13 then -- 6.药王庙
		self:setTextByLanKey("common_title_text", "new_str_0159")
		self:setTextByLanKey("tips_text", "new_str_0160")
	end
	self:setObjectVisible("ok_btn", self.m_model.m_open_flag == true)
	self:refreshUI()
end

function M:refreshUI()

end

return M