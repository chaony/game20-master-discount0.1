local M = class("UnionFindPopView",LikeOO.OOPopBase)

M.m_uiName = "Union/UnionFindPop"
M.m_size_type = 2

local apply_type = {"union_str_1027", "union_str_1028", "union_str_1029"}
function M:onEnter()
	-- self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 1})
	self:setTextByLanKey("common_title_text", "union_str_1041")
	self:setTextByLanKey("detail_title_text", "union_str_1030")
	self:setTextByLanKey("union_number_text", "union_str_1079")
	self:setTextByLanKey("join_lv_text", "union_str_1031")
	self:setTextByLanKey("join_type_text", "union_str_1032")
	self:setTextByLanKey("union_id_text", "union_str_1033")
	self:setTextByLanKey("fresh_btn_text", "union_str_1035")
	self:setTextByLanKey("union_name_text", "union_str_1036")
	self:setTextByLanKey("union_lv_text", "union_str_1037")
	self:setTextByLanKey("union_people_text", "union_str_1038")
	self:setTextByLanKey("union_act_text", "union_str_1073")
	self:setTextByLanKey("union_furnace_text", "union_str_1040")

	self:setTextByLanKey("no_text",  "union_no_tex")
	self:setTextByLanKey("tiaojian_title_text", "union_tw_0002")
	self:setTextByLanKey("tiaojian_value_text",  "legend_str_019")

	self.find_input = self:findInputField("find_input")
	self.find_input.placeholder.text = Language:getTextByKey("union_str_0024")
	self:refreshUI()
end

function M:refreshUI()
	local guild_data = self.m_model:getSelectUnionData()
	if guild_data then
		self:findGameObject("president_head"):SetActive(false)
		self:findGameObject("president_name_text"):SetActive(true)
		self:findGameObject("detail_title_img"):SetActive(true)
		self:findGameObject("detail_img"):SetActive(true)
		self:findGameObject("line_1_img"):SetActive(true)
		self:findGameObject("line_2_img"):SetActive(false)
		self:findGameObject("line_3_img"):SetActive(false)
		self:findGameObject("union_icon_bg"):SetActive(true)
		self:findGameObject("union_icon_img"):SetActive(true)

		self:setText("president_name_text", guild_data.name)
		self:setText("detail_text", guild_data.apply_desc)
		self:setTextByLanKey("join_lv_value_text", "new_str_0075", guild_data.apply_lv)
		self:setText("union_id_value_text", guild_data.id)
		self:setTextByLanKey("tiaojian_value_text", apply_type[guild_data.apply])
		local flag_cfg = ConfigManager:getCfgByName("guild_flag")[guild_data.flag]
		--self:setImg(flag_cfg.icon, "maze_stage_ui", "union_icon_img")
		local union_icon_img = self:findImage("union_icon_img")
		GameUtil:updateResourcesImg(union_icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
	else
		self:findGameObject("president_head"):SetActive(false)
		self:findGameObject("president_name_text"):SetActive(false)
		self:findGameObject("detail_title_img"):SetActive(false)
		self:findGameObject("detail_img"):SetActive(false)
		self:findGameObject("line_1_img"):SetActive(false)
		self:findGameObject("line_2_img"):SetActive(false)
		self:findGameObject("line_3_img"):SetActive(false)
		self:findGameObject("union_icon_bg"):SetActive(false)
		self:findGameObject("union_icon_img"):SetActive(false)
	end
	self:updateListScroll()
end

function M:updateListScroll()
	local data = self.m_model.m_list_data
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:listHandle(cell_object, index, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, index)
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data,true)
	end
end

function M:listHandle(obj, id, data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local name_text = luaBehaviour:FindText("name_text")
	local lv_text = luaBehaviour:FindText("lv_text")
	local num_text = luaBehaviour:FindText("num_text")
	local score_text = luaBehaviour:FindText("score_text")
	local select_img = luaBehaviour:FindGameObject("select_img")
	-- local apply_btn = luaBehaviour:FindButton("apply_btn")
	local number_text = luaBehaviour:FindText("number_text")
	select_img:SetActive(id == self.m_model.m_select)
	local guild_cfg = ConfigManager:getCfgByName("guild")
	local cfg = guild_cfg[data.level]

	name_text.text = data.name
	lv_text.text = data.level
	num_text.text = tostring(data.member_count) .. "/" .. cfg.number
	score_text.text = data.exp
	number_text.text = data.id

	local flag_cfg = ConfigManager:getCfgByName("guild_flag")[data.flag]
	if flag_cfg then
		LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", flag_cfg.icon, "common_ui")
	end

	local tripodsLv = self.m_model:getTripodsLv(data.tripods)
	local total_lv = 0
	for k,v in pairs(tripodsLv) do
		LuaBehaviourUtil.setText(luaBehaviour, string.format("tripod_lv_%d_text",k), v)
		total_lv = total_lv + v
	end
	--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tripod_lv_text", tostring(total_lv))
end

function M:getFindUnionName()
	return self.find_input.text
end

function M:setFindUnionName(text)
	self.find_input.text = tostring(text)
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M