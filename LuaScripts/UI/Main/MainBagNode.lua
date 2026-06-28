--- 背包
local M = class("MainBagNode",LikeOO.OOUIbase)

M.m_uiName = "Main/MainBagNode"
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = {
	{btn_key = "items_togglebtn", lua_name = "", btn_text = "items_btn_text", text_key = "new_str_0041", open = true, red_point = "items_red_point_img", red_point_id = 1002}, -- 道具
	{btn_key = "equips_togglebtn", lua_name = "", btn_text = "equips_btn_text", text_key = "new_str_0042", open = true, red_point = "equips_red_point_img" }, -- 装备
	{btn_key = "pieces_togglebtn", lua_name = "", btn_text = "pieces_btn_text", text_key = "new_str_0043", open = true, red_point = "pieces_red_point_img", red_point_id = 1001}, -- 灵魂石
	{btn_key = "all_togglebtn", lua_name = "", btn_text = "all_btn_text", text_key = "new_str_0044", open = true, red_point = "all_red_point_img", red_point_id = 1}, -- 全部
	{btn_key = "mystices_togglebtn", lua_name = "", btn_text = "mystices_btn_text", text_key = "new_str_0816", open = true, red_point = "mystices_red_point_img", red_point_id = 1003}, -- 秘籍
}

function M:onEnter()
	UserDataManager:removeRedDotByKey("main_bag_once")
	self.m_toggle_btns = {}
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.btn_text, string.cutTextForString(Language:getTextByKey(v.text_key)))
		local tog_btn = self:findToggle(v.btn_key)
		tog_btn.gameObject:SetActive(v.open)
		self.m_toggle_btns[k] = tog_btn
		if k == self.m_model.m_open_bag_tab_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on)
			if is_on then
				self:updateMsg("bag_tab_click", k)
			end
		end,nil,self.m_uiName)
		self:setObjectVisible(v.red_point, false)
	end
	self.sequence_time = 0
	self.loop_score_sequence = Tweening.DOTween.Sequence()
	self.m_content_node = self:findGameObject("content_node")
	-- self.m_content_node.transform.localScale = Vector3(1,0,1)
	-- self.m_content_node.transform:DOScaleY(1,0.5):SetEase(Tweening.Ease.InOutBack)
	self:setTextByLanKey("tips_text", "new_str_0358")
    self:setTextByLanKey("common_title_text", "new_str_0359")
	self.m_detail_node = self:findGameObject("detail_node")
	self.m_model:refreshBagListData(self.m_model.m_open_bag_tab_index)
	self:switchTabNode(self.m_model.m_open_bag_tab_index)
	self:refreshUI()
	audio:PauseSkillsBusVol()
	self.m_transfer = "scale"
	SceneManager:pause()
end

function M:refreshUI()

end

function M:refreshRedPoint()
	
end

function M:switchTabNode(index)
	self.m_model.m_open_bag_tab_index = index
	for k,v in pairs(__TAB_BTN_NODE) do
		local cur_tab_text = self:findText(v.btn_text)
		cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_1 or GlobalConfig.COMMON_COLLOR.COMMON_5
		--local outline_width = index == k and 2 or 0
		--UIUtil.setOutlineExEffectColor(cur_tab_text, nil, GlobalConfig.COMMON_COLLOR_OUTLINE.COMMON_3, outline_width)
		local red_flag = RedPointUtil:hasRedPointById(v.red_point_id)
		self:setObjectVisible(v.red_point, red_flag == true)
	end
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	self.m_cell_tab = {}
	local data = self.m_model.m_show_bag_data or {}
	self:setObjectVisible("line_image", #data > 0)
	self:setObjectVisible("CommonTipsNode", #data == 0)
	local new_index = nil
	if self.m_select_cell_data then -- 用于刷新重新定位
		for k,v in pairs(data) do
			if v.data_type == self.m_select_cell_data.data_type and v.data_id == self.m_select_cell_data.data_id then
				new_index = k
				self.m_select_cell_data = v
				self.m_select_cell_index = k
				break
			end
		end
	end
	if new_index == nil then
		self.m_select_cell_index = 1
		self.m_select_cell_object = nil
	end
	self:openItemInfo(data[self.m_select_cell_index])
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 6,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self.m_cell_tab[index] = cell_object
				local data = cell_data
				local ui_element = GameUtil:updateItemElementByData(cell_object, data, data.user_num > 1, false)
				if data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
					local red_flag = RedPointUtil:checkItemRedPointById(data.data_id)
					ui_element.red_point_img:SetActive(red_flag)
				end
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image", self.m_select_cell_index == index)
				if self.m_select_cell_index == index then
					self.m_select_cell_object = cell_object
					self.m_select_cell_data = cell_data
				end
				-- local content = luaBehaviour:FindGameObject("content")
				-- local canvasGroup = content.transform:GetComponent("CanvasGroup")
			 --    canvasGroup.alpha = 0
			 --    local sequence = Tweening.DOTween.Sequence()
			 --    local function endCallFunc()
			 --        self.sequence_time = 0
			 --        self.loop_score_sequence = nil
			 --    end
			 --    --insert 从某个指定时间段开始播动画
			 --    sequence:Insert(self.sequence_time,DOTweenModuleUI.DOFade(canvasGroup,1,0.3))
			 --    self.sequence_time = self.sequence_time + 0.02
			 --    sequence:OnComplete(endCallFunc)
			 --    self.loop_score_sequence = sequence

			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if self.m_select_cell_object then
					local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_cell_object)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image", false)
				end
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image", true)
				self.m_select_cell_object = cell_object
				self.m_select_cell_index = index
				self.m_select_cell_data = cell_data
				self:openItemInfo(cell_data)
			end,
			ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
		--self:runCellAnim()
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:openItemInfo(cell_data)
	if self.m_item_detail_node then
		self.m_item_detail_node:destroy()
		self.m_item_detail_node = nil
	end
	if cell_data then
		local tab_cls = nil
		if cell_data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
			 if cell_data.item_cfg.type == GlobalConfig.ITEM_TYPE.CONDITION_BOX then --条件礼包
			 	tab_cls = CustomRequire("UI.Item.ItemBoxNode")
			-- elseif cell_data.item_cfg.type == GlobalConfig.ITEM_TYPE.MUL_BOX then --多可选宝箱
			-- 	tab_cls = CustomRequire("UI.Item.ItemMulBoxNode")
			 else
				tab_cls = CustomRequire("UI.Item.ItemDetailNode")
			end
		elseif cell_data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
			tab_cls = CustomRequire("UI.Item.ItemEquipNode")
		elseif cell_data.data_type == RewardUtil.REWARD_TYPE_KEYS.MYSTIC then
			tab_cls = CustomRequire("UI.Item.MysticDetailNode")
		end
		if tab_cls then
			self.m_item_detail_node = tab_cls.new(self.m_control, {parent = self.m_detail_node})
			self.m_item_detail_node:updateView(cell_data)
		end
	end
end

function M:runCellAnim()
	for k, v in pairs(self.m_cell_tab) do
		if not IsNull(v) then
			local transform = v.transform
			local content = UIUtil.findTrans(transform, "content")
			content.localPosition = Vector3(0,math.floor((k-1)/5)*140,0)
			local sequence = Tweening.DOTween.Sequence()
			--sequence:AppendInterval(0.01)
			sequence:Append(content:DOLocalMoveY(0,0+0.005*k))
			sequence:SetAutoKill(true)
		end
	end
end

function M:destroy()
	if self.m_item_detail_node then
		self.m_item_detail_node:destroy()
		self.m_item_detail_node = nil
	end
	audio:ResumeSkillsBusVol()
    M.super.destroy(self)
	SceneManager:continue()
end


return M