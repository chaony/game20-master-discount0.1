local M = class("MazeStageHospitalView",LikeOO.OOPopBase)

M.m_uiName = "MazeStage/MazeStageHospital"
M.m_size_type = 2

function M:onEnter()
	if self.m_model.m_cell_data.status == 0 then
		self:setTextByLanKey("ok_btn_text", "new_str_0029")
	else
		-- 治疗、供奉
		self:setTextByLanKey("ok_btn_text", self.m_model.m_cell_data.type == 5 and "new_str_0158" or "new_str_0161")
	end
	local cell_type = self.m_model.m_cell_data.type
	local maze_cell_type = ConfigManager:getCfgByName("maze_cell_type")
	local maze_cell_type_item = maze_cell_type[cell_type] or {}
	local explain = maze_cell_type_item.explain or "???"
	self:setTextByLanKey("tips_text", explain)
	self:setTextByLanKey("common_title_text", maze_cell_type_item.name or "???")
	if self.m_model.m_cell_data.type == 5 then --5.医馆
		 --self:setTextByLanKey("common_title_text", "new_str_0156")
		 --self:setTextByLanKey("tips_text", "new_str_0157")
	elseif self.m_model.m_cell_data.type == 6 then -- 6.药王庙
		 --self:setTextByLanKey("common_title_text", "new_str_0159")
		 --self:setTextByLanKey("tips_text", "new_str_0160")
	end
	self:setObjectVisible("ok_btn", self.m_model.m_open_flag == true)
	self:refreshUI()
end

function M:refreshUI()

end

return M