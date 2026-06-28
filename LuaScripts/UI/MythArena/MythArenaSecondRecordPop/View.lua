local M = class("MythArenaSecondRecordPopView",LikeOO.OOPopBase)

M.m_uiName = "MythArena/MythArenaSecondRecordPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = { 
	--    show_sidebar(是否显示侧边栏)
	{btn_key = "tog_1", text_name = "tog_1_text", text_key = "peak_str_0033"}, -- 晋级赛
	{btn_key = "tog_2", text_name = "tog_2_text", text_key = "peak_str_0035" }, -- 淘汰赛
}

function M:onEnter()
	self:setTextByLanKey("common_title_text", "wlsh_myth_001")
	
	for i = 1, 2 do
		local tab_stage_id = self.m_model.m_tab_id[i]
		local ui_data = __TAB_BTN_NODE[i]
		local tog_btn = self:findToggle(ui_data.btn_key)
		if tab_stage_id then
			local cur_stage_cfg = self.m_model:getCfgValueByKey(tab_stage_id)
			if cur_stage_cfg then
				self:setTextByLanKey(ui_data.text_name, cur_stage_cfg.name)
			else
				self:setTextByLanKey(ui_data.text_name, ui_data.text_key)
			end
			tog_btn.gameObject:SetActive(true)
			--self.m_toggle_btns[i] = tog_btn
			if i == self.m_model.m_open_tab_index then
				tog_btn.isOn = true
			end
			UIUtil.addToggleListener(tog_btn, function(is_on)
				if is_on then
					self:switchTabUpdate(is_on, i)
				end
			end,nil,self.m_uiName)
		else
			tog_btn.gameObject:SetActive(false)
		end
	end

	self:refreshDetailsList()
end

function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg("switch_tag", update_key)
	end
end

function M:switch_UI()
	self:refreshDetailsList()
	self.m_loopScroll_view:moveToCellIndex(1)
end

function M:refreshDetailsList()
	self:setObjectVisible("loopscroll2", self.m_model.m_cur_big_stage_id == 4 )
	self:setObjectVisible("loopscroll", self.m_model.m_cur_big_stage_id ~= 4 )

	-- 战斗列表
    local data = self.m_model:getCurLogs()
    if self.m_loopScroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
		if self.m_model.m_cur_big_stage_id == 4  then
			loopscroll = self:findGameObject("loopscroll2")
		end
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
				if self.m_model.m_cur_big_stage_id == 4 then
					self:refreshCellItem2(cell_obj, cell_data, index)
				else
					self:refreshCellItem(cell_obj, cell_data, index)
				end
            end,
            ui_name = self.m_uiName,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "cell_hit_btn" then
					self:updateMsg("cell_hit_btn", index)
				elseif click_name == "left_head_btn" or click_name == "right_head_btn" then
					local user_data = cell_data.user_info[click_name == "left_head_btn" and 1 or 2] or {}
					if user_data then
						self:updateMsg("look_player", user_data.uid)
					end 
				end
            end
        }
        self.m_loopScroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loopScroll_view:reloadData(data, true)
    end
end

function M:refreshCellItem(obj, data, index)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "team_num_text", "peak_str_0037", index)
	if data.user_info and next(data.user_info) then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_right_node", data.user_info[2] and true or false)--竞猜成功
		local head_node_left = luaBehaviour:FindGameObject("head_node_left")
		local head_node_right = luaBehaviour:FindGameObject("head_node_right")
		GameUtil:setUserAvatar(head_node_left, data.user_info[1],true, false, {show_flag = true, scale = 1})
		GameUtil:setUserAvatar(head_node_right, data.user_info[2], true, false,{show_flag = true, scale = 1})
		local left_name_text = LuaBehaviourUtil.setText(luaBehaviour,"left_name_text", data.user_info[1].name)
		local right_name_text = LuaBehaviourUtil.setText(luaBehaviour,"right_name_text", data.user_info[2] and data.user_info[2].name or "")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "win_img", data.guess_success == 1)--竞猜成功
		local title_id1 = data.user_info[1].title
		if title_id1 and title_id1 ~= 0 then
			left_name_text.transform.anchoredPosition = Vector3.New(-78.603, -15, 0)
		else
			left_name_text.transform.anchoredPosition = Vector3.New(-78.603, 0, 0)
		end
		local title_id2 =  data.user_info[2] and data.user_info[2].title or 0
		if title_id2 and title_id2 ~= 0 then
			right_name_text.transform.anchoredPosition = Vector3.New(20.59998, -15, 0)
		else
			right_name_text.transform.anchoredPosition = Vector3.New(20.59998, 0, 0)
		end
	end
end

function M:refreshCellItem2(obj, data, index)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "team_num_text", "peak_str_0037", index)
	if data.user_info and next(data.user_info) then
		for i = 1, 4 do
			local head_node = luaBehaviour:FindGameObject("head_node_" .. i)
			GameUtil:setUserAvatar(head_node, data.user_info[i],true, false, {show_flag = true, scale = 1})
			local name_text = LuaBehaviourUtil.setText(luaBehaviour,"name_text" .. i, data.user_info[i].name)
			local title_id1 = data.user_info[i].title
			if title_id1 and title_id1 ~= 0 then
				name_text.transform.anchoredPosition = Vector3.New(53, -15, 0)
			else
				name_text.transform.anchoredPosition = Vector3.New(53, 0, 0)
			end
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "win_img", data.guess_success == 1)--竞猜成功
	end
end

function M:destroy()
    M.super.destroy(self)
end

return M