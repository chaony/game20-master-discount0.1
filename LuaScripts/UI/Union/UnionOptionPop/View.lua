local M = class("UnionOptionView",LikeOO.OOPopBase)

M.m_uiName = "Union/UnionOptionPop"
M.m_size_type = 2

local apply_type = {"union_str_1027", "union_str_1028", "union_str_1029"}
function M:onEnter()	
	self:setTextByLanKey("cancle_text", "new_str_0007")
	self:setTextByLanKey("ok_text", "new_str_0006")
	self:setTextByLanKey("common_title_text", "union_str_0025")
	self:setTextByLanKey("des_text", "union_str_1030")
	self:setTextByLanKey("lv_text", "union_str_1031")
	self:setTextByLanKey("rh_type_text", "union_str_1032")
	self:setTextByLanKey("union_name_text", "union_str_1036")
	self:setTextByLanKey("tips_text", "union_str_1065")
	self:setTextByLanKey("gh_text", "union_tw_0003")
	self.name_inputField = self:findInputField("name_inputField")
	self.name_inputField.placeholder.text = Language:getTextByKey("union_str_0006")
	self.name_inputField.text = self.m_model.m_data.name
	self.des_inputField = self:findInputField("des_inputField")
	self.des_inputField.placeholder.text = Language:getTextByKey("union_str_1043")
	self.des_inputField.text = self.m_model.m_data.apply_desc or ""

	-- local create_cost = ConfigManager:getCommonValueById(69)
	-- local data = RewardUtil:getProcessRewardData(create_cost)
	-- local user_num = GameUtil:formatValueToString(data.user_num)
	-- local data_num = GameUtil:formatValueToString(data.data_num)
	-- self:setText("cost_value_text", data_num)
	-- self:setTextByLanKey("cost_text", "union_str_1021")
	self:refreshUI()
end

function M:refreshUI()
	local flag_cfg = ConfigManager:getCfgByName("guild_flag")[self.m_model.m_data.flag]
	if flag_cfg then
		--self:setImg(flag_cfg.icon, "maze_stage_ui", "icon_img")
		local icon_img = self:findImage("icon_img")
		GameUtil:updateResourcesImg(icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
	end
	self:setTextByLanKey("type_text", apply_type[self.m_model.m_data.apply])
	self:setText("lv_text", self.m_model.m_data.apply_lv)
end

function M:getNameText( )
	return self.name_inputField.text
end

function M:resetNameText()
	self.name_inputField.text = ""
end

function M:getDesText()
	return self.des_inputField.text
end



return M