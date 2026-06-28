local M = class("UnionCreateView",LikeOO.OOPopBase)

M.m_uiName = "Union/UnionCreatePop"
M.m_size_type = 2

local apply_type = {"union_str_1027", "union_str_1028", "union_str_1029"}
function M:onEnter()	
	self:setTextByLanKey("cancle_text", "new_str_0007")
	self:setTextByLanKey("ok_text", "new_str_0006")
	self:setTextByLanKey("common_title_text", "union_str_0003")
	self:setTextByLanKey("gh_text", "union_tw_0001")
	self:setTextByLanKey("tiaojian_title_1", "union_tw_0002")

	self:setTextByLanKey("title_text", "creat_union_tex")
	self:setTextByLanKey("title_text2", "UnionWar_str_014")
	self:setTextByLanKey("title_text3", "union_str_0052")

	self.InputField = self:findInputField("InputField")
	self.InputField.placeholder.text = Language:getTextByKey("union_str_0006")
	self.InputField.text = ""

	self.des_input = self:findInputField("des_input")
	self.des_input.placeholder.text = Language:getTextByKey("union_str_0052")
	self.des_input.text = ""

	local create_cost = ConfigManager:getCfgByName("system_cost")[1].cost
	local data = RewardUtil:getProcessRewardData(create_cost[1])
	local user_num = GameUtil:formatValueToString(data.user_num)
	local data_num = GameUtil:formatValueToString(data.data_num)
	self:setText("cost_value_text", data_num)
	self:setImg(data.icon_name, data.atlas_name, "cost_img")
	self:setTextByLanKey("cost_text", "union_str_1021")
	self:refreshUI()
end

function M:refreshUI()
	local flag_cfg = ConfigManager:getCfgByName("guild_flag")[self.m_model.m_emblem]
	if flag_cfg then
		--self:setImg(flag_cfg.icon, "maze_stage_ui", "icon_img")
		local icon_img = self:findImage("icon_img")
		GameUtil:updateResourcesImg(icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
	end

	self:setTextByLanKey("type_text", apply_type[self.m_model.m_apply])
	self:setText("lv_text", self.m_model.m_apply_lv)
end

function M:getNameText( )
	local text = GameUtil:formatInputText(self.InputField.text)
	return text
end

function M:resetNameText()
	self.InputField.text = ""
end

function M:getDesText( )
	local text = GameUtil:formatInputText(self.des_input.text)
	return text
end

return M