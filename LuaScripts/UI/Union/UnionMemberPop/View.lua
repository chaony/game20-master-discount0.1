local M = class("UnionMemberView",LikeOO.OOPopBase)

M.m_uiName = "Union/UnionMemberPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0109")
	self:setTextByLanKey("create_btn_text", "union_str_0003")
	self:setTextByLanKey("join_btn_text", "union_str_0046")
	
	self:refreshUI()
end

function M:refreshUI()
	self:updateListScroll()
end

function M:updateListScroll()
	local data = self.m_model:getListData()
	local all_cell_size = {}
	for i,v in ipairs(data or {}) do
		if v.uid == self.m_model.m_target_uid then
			all_cell_size[i] = Vector2(844.4, 190)
		else
			all_cell_size[i] = Vector2(844.4, 119)
		end
	end
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			all_cell_size = all_cell_size,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:listHandle(cell_object, index, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, {index = index, data = cell_data})
			end,
			ui_name = self.m_uiName
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data,true, all_cell_size)
	end
end

function M:listHandle(obj, id, data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local HeadNode = luaBehaviour:FindGameObject("HeadNode")
	local name_text = luaBehaviour:FindText("name_text")
	local lv_text = luaBehaviour:FindText("lv_text")
	local time_text = luaBehaviour:FindText("time_text")
	local score_text = luaBehaviour:FindText("score_text")
	local npc_img = luaBehaviour:FindGameObject("npc_img")
	local president_img = luaBehaviour:FindGameObject("president_img")
	local time_bg = luaBehaviour:FindGameObject("time_bg")

	GameUtil:setUserAvatar(HeadNode, data, nil, nil, {show_flag = true, scale = 1})
	if data.name == "" then
		name_text.text = Language:getTextByKey("new_str_0141")
	else
		name_text.text = data.name
	end
	president_img:SetActive(data.position<3)
	if data.position == 1 then
		GameUtil:setLanImgText(president_img.transform, "a_bh_icon_bangzhu", "icon_img")
	elseif data.position == 2 then
		GameUtil:setLanImgText(president_img.transform, "a_bh_icon_zhanglao", "icon_img")
	end
	npc_img:SetActive(self.m_model:getIsNPC(data.uid))
	--lv_text.text = Language:getTextByKey("union_str_0004") .. data.level
	score_text.text = data.self_guild_exp

	local score_title_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_title_text", "new_str_0557")

	local title_id = data.title
	if title_id and title_id ~= 0 then
		score_text.transform.anchoredPosition = Vector3.New(-166,-90,0)
		score_title_text.transform.anchoredPosition = Vector3.New(-276,-90,0)
		name_text.transform.anchoredPosition = Vector3.New(-188,-60,0)
	else
		score_text.transform.anchoredPosition = Vector3.New(-166,-80,0)
		score_title_text.transform.anchoredPosition = Vector3.New(-276,-79,0)
		name_text.transform.anchoredPosition = Vector3.New(-188,-45,0)
	end
	local time_str = ""
	if data.is_online == 0 then
		time_bg:GetComponent("RectTransform").sizeDelta = Vector2(137, 27)
		local time = UserDataManager:getServerTime() - data.last_active_time
		local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(time)

		if day > 0 then
			time_str = string.format(Language:getTextByKey("mail_str_0002"),day)
		elseif hour > 0 then
			time_str = string.format(Language:getTextByKey("mail_str_0003"),hour)
		elseif min > 0 then
			time_str = string.format(Language:getTextByKey("mail_str_0004"),min)
		else
			time_str = Language:getTextByKey("mail_str_0005")
		end
		--time_text.color = GlobalConfig.COMMON_COLLOR.COMMON_11
		time_text.color = Color( 83/255, 49/255, 26/255)
	else
		time_bg:GetComponent("RectTransform").sizeDelta = Vector2(60, 27)
		time_str = Language:getTextByKey("mail_str_0006")
		--time_text.color = GlobalConfig.COMMON_COLLOR.COMMON_12
		time_text.color = Color( 0, 178/255, 4/255)
	end
	time_text.text = time_str

	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "star_text", "union_str_1076", tostring(data.star or 0))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "battle_times_text", "union_str_1077", tostring(data.battle_times or 0))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "hero_num_text", "union_str_1078", tostring(data.hero_num or 0))
	
	local rect = obj:GetComponent("RectTransform")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "handle_point_btn", self.m_model.m_position ~= GlobalConfig.UNION_POS.COMMON)
	if data.uid == self.m_model.m_target_uid then
		rect.sizeDelta = Vector2(rect.rect.width, 190)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "handle_Panel", true)
		LuaBehaviourUtil.setImg(luaBehaviour, "handle_point_img", "a_ui_currency_shouqi", "common_ui")
		self:updateHandleScroll(luaBehaviour:FindGameObject("handle_scroll"))
	else
		rect.sizeDelta = Vector2(rect.rect.width, 119)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "handle_Panel", false)
		LuaBehaviourUtil.setImg(luaBehaviour, "handle_point_img", "a_ui_currency_xiala", "common_ui")
	end
end

----------------------------------------------------------------------------------------------------------
--- 成员管理

function M:updateHandleScroll(scroll_obj)
	local data = self.m_model.m_handle_list
	if self.m_handle_scroll ~= nil then
		self.m_handle_scroll = nil
	end
	
	local params = {
		show_data = data,
		one_line_count = 6,
		loop_scroll_object = scroll_obj,
		update_cell = function(index, cell_object, cell_data)
			local transform = cell_object.transform
			local data = cell_data
			self:handleHandle(cell_object, index, cell_data)
		end,
		click_func = function(index, cell_object, cell_data, click_object, click_name)
			self:updateMsg(click_name, cell_data)
		end,
		ui_name = self.m_uiName
	}
	self.m_handle_scroll = LoopScrollViewUtil.new(params)
end

function M:handleHandle(obj, id, data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local handle_btn 
	if data == GlobalConfig.UNION_HANDLE_ID.DEMOTE then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "handle_btn_text", "union_str_1054", Language:getTextByKey("union_str_1056"))
		LuaBehaviourUtil.setImg(luaBehaviour,"handle_btn","a_ui_currency_btn_small_2","common_ui")
	elseif data == GlobalConfig.UNION_HANDLE_ID.CHANGE_ELITE then
		local flag = self.m_model:getIsNPC(self.m_model.m_target_uid)
		if flag then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "handle_btn_text", "union_str_1054", Language:getTextByKey("union_str_1057"))
			LuaBehaviourUtil.setImg(luaBehaviour,"handle_btn","a_ui_currency_btn_small_2","common_ui")
		else
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "handle_btn_text", "union_str_1053")
			LuaBehaviourUtil.setImg(luaBehaviour,"handle_btn","a_ui_currency_btn_small_3","common_ui")
		end
	elseif data == GlobalConfig.UNION_HANDLE_ID.PROMOTE_ELDER then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "handle_btn_text", "union_str_1052")
		LuaBehaviourUtil.setImg(luaBehaviour,"handle_btn","a_ui_currency_btn_small_3","common_ui")
	elseif data == GlobalConfig.UNION_HANDLE_ID.DELETE then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "handle_btn_text", "union_str_1055")
		LuaBehaviourUtil.setImg(luaBehaviour,"handle_btn","a_ui_currency_btn_small_1","common_ui")
	elseif data == GlobalConfig.UNION_HANDLE_ID.BLACK then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "handle_btn_text", "new_str_0376")
		LuaBehaviourUtil.setImg(luaBehaviour,"handle_btn","a_ui_currency_btn_small_1","common_ui")
	elseif data == GlobalConfig.UNION_HANDLE_ID.ABDICATE then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "handle_btn_text", "union_str_1070")
		LuaBehaviourUtil.setImg(luaBehaviour,"handle_btn","a_ui_currency_btn_small_1","common_ui")
	elseif data == GlobalConfig.UNION_HANDLE_ID.SEND_MAIL then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "handle_btn_text", "union_str_1074")
		LuaBehaviourUtil.setImg(luaBehaviour,"handle_btn","a_ui_currency_btn_small_2","common_ui")
	end
end

return M