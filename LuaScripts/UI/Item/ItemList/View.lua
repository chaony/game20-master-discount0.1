local M = class("ItemListView",LikeOO.OOPopBase)

M.m_uiName = "Item/ItemList"
M.m_size_type = 2
local __TAB_BTN_NODE = {
	{btn_key = "items_togglebtn", lua_name = "", btn_text = "items_btn_text", text_key = "new_str_0041", open = true, red_point = "items_red_point_img", red_point_id = 1002}, -- 道具
	{btn_key = "equips_togglebtn", lua_name = "", btn_text = "equips_btn_text", text_key = "new_str_0042", open = true, open = true, red_point = "equips_red_point_img" }, -- 装备
	{btn_key = "pieces_togglebtn", lua_name = "", btn_text = "pieces_btn_text", text_key = "new_str_0043", open = true, red_point = "pieces_red_point_img", red_point_id = 1001 }, -- 灵魂石
	{btn_key = "all_togglebtn", lua_name = "", btn_text = "all_btn_text", text_key = "new_str_0044", open = true, red_point = "all_red_point_img", red_point_id = 1 }, -- 全部
	--{btn_key = "mapItem_togglebtn", lua_name = "", btn_text = "mapItem_btn_text", text_key = "new_str_0575", open = true, red_point = "mapItem_red_point_img"}, -- 江湖道具
	{btn_key = "mystices_togglebtn", lua_name = "", btn_text = "mystices_btn_text", text_key = "new_str_0816", open = true, red_point = "mystices_red_point_img", red_point_id = 1003}, -- 秘籍
}

function M:onEnter()
	UserDataManager:removeRedDotByKey("main_bag_once")
	self.m_first_enter = true
	self:setTextByLanKey("common_title_text", "new_str_0359")
	self:setTextByLanKey("common_no_have_text", "new_str_0351")
	self.m_toggle_btns = {}
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.btn_text, string.cutTextForString(Language:getTextByKey(v.text_key)))
		local tog_btn = self:findToggle(v.btn_key)
		tog_btn.gameObject:SetActive(v.open)
		self.m_toggle_btns[k] = tog_btn
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
		self:setObjectVisible(v.red_point, false)
	end
	local mystices_bl = BtnOpenUtil:isBtnOpen(62)
	self:setObjectVisible("mystices_togglebtn", mystices_bl == true)
	self.m_detail_node = self:findGameObject("detail_node")
	self.m_model:refreshListData(self.m_model.m_open_tab_index)
	self:switchTabNode(self.m_model.m_open_tab_index)
	self:refreshUI()
	self.m_first_enter = false
end

function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg(update_key)
	end
end

function M:refreshUI()

end

function M:switchTabNode(index, keep_offset)
	for k,v in pairs(__TAB_BTN_NODE) do
		local cur_tab_text = self:findText(v.btn_text)
		cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_TOGGLE_FOCUS or GlobalConfig.COMMON_COLLOR.COMMON_TOGGLE
		--cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_1 or GlobalConfig.COMMON_COLLOR.COMMON_5
		local red_flag = RedPointUtil:hasRedPointById(v.red_point_id)
		self:setObjectVisible(v.red_point, red_flag == true)
	end
    self:updateLoopScroll(keep_offset)
end

--[[
	创建列表
]]
function M:updateLoopScroll(keep_offset)
	local data = self.m_model:getShowData()
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
	if self.m_first_enter then
		self.m_control:setOnceTimer(0.2, function()
			self:openItemInfo(data[self.m_select_cell_index])
		end)
	else
		self:openItemInfo(data[self.m_select_cell_index])
	end
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 6,
			loop_scroll_object = loopscroll,
			init_cell = function(index, cell_object)
				self.m_control:setOnceTimer(index <= 36 and 0.016*index or 0, function()
					local cell_data = self.m_loop_scroll_view.m_show_data[index]
					local itemNode = GameUtil:createPrefab("Common/ItemNode")
					local canvas_group = itemNode:GetComponent("CanvasGroup")
					canvas_group.blocksRaycasts = false
					itemNode.name = "cell_content"
					itemNode.transform:SetParent(cell_object.transform, false)
					if cell_data then
						self:updateScrollViewCell(index, itemNode, cell_data)
						if self.m_select_cell_index == index then
							self.m_select_cell_object = cell_object
							self.m_select_cell_data = cell_data
						end
					end
				end)
			end,
			update_cell = function(index, cell_object, cell_data)
				local content_tran = UIUtil.findTrans(cell_object.transform, "cell_content")
				if not IsNull(content_tran) then
					self:updateScrollViewCell(index, content_tran.gameObject, cell_data)
					if self.m_select_cell_index == index then
						self.m_select_cell_object = cell_object
						self.m_select_cell_data = cell_data
					end
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local content_tran = UIUtil.findTrans(cell_object.transform, "cell_content")
				if content_tran then
					if self.m_select_cell_object then
						local select_content_tran = UIUtil.findTrans(self.m_select_cell_object.transform, "cell_content")
						local luaBehaviour = UIUtil.findLuaBehaviour(select_content_tran)
						LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image", false)
					end
					local luaBehaviour = UIUtil.findLuaBehaviour(content_tran.gameObject)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image", true)
					self.m_select_cell_object = cell_object
					self.m_select_cell_index = index
					self.m_select_cell_data = cell_data
					self:openItemInfo(cell_data)
				end
			end,
			ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, keep_offset)
	end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local ui_element = GameUtil:updateItemElementByData(cell_object, data, data.user_num > 1, false)
	if data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
		local red_flag = RedPointUtil:checkItemRedPointById(data.data_id)
		ui_element.red_point_img:SetActive(red_flag)
	end
	if data.data_type == RewardUtil.REWARD_TYPE_KEYS.RED_ENVELOPE then
		ui_element.red_point_img:SetActive(true)
	end
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image", self.m_select_cell_index == index)
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
			--elseif cell_data.item_cfg.type == GlobalConfig.ITEM_TYPE.MUL_BOX then --多可选宝箱
			--	tab_cls = CustomRequire("UI.Item.ItemMulBoxNode")
			else
				tab_cls = CustomRequire("UI.Item.ItemDetailNode")
			end
		elseif cell_data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
			tab_cls = CustomRequire("UI.Item.ItemEquipNode")
		elseif cell_data.data_type == RewardUtil.REWARD_TYPE_KEYS.MYSTIC then
			tab_cls = CustomRequire("UI.Item.MysticDetailNode")
		elseif cell_data.data_type == RewardUtil.REWARD_TYPE_KEYS.RED_ENVELOPE then
			tab_cls = CustomRequire("UI.Item.RedPacketDetailNode")
		end
		if tab_cls then
			self.m_item_detail_node = tab_cls.new(self.m_control, {parent = self.m_detail_node})
			self.m_item_detail_node:updateView(cell_data)
		end
	end
end

----[[
--	创建商店列表
--]]
--function M:updateLoopScroll()
--	local count = self.m_model:getDataCount()
--	if self.m_loopScroll == nil then
--	    self.m_loopScroll = LoopScrollUtil.new() 
--	    self.m_loopScroll:createLoop(self.m_control, self:findGameObject("loopscroll"))
--	    self.m_loopScroll:creatCell("Common/ItemNode", count, true, 20, 4, handler(self, self.setCellHander))
--	else
--		self.m_loopScroll:refresh(count)
--	end
--end
--
----Scroll内cell的回调
--function M:setCellHander(handertype, id, obj)
--    if handertype == 1 then
--    	local transform = obj.transform
--    	local data = self.m_model:getDataByIndex(id)
--    	GameUtil:updateItemElementByData(obj, data, data.user_num > 1, false, handler(self, self.itemClick))
--    	-- UIUtil.setButtonClick(transform, handler(self, self.itemClick) , id, "item_btn")
--    end
--end

--function M:itemClick(obj, data)
--	self:updateMsg("item_click", data)
--end

function M:destroy()
	if self.m_item_detail_node then
		self.m_item_detail_node:destroy()
		self.m_item_detail_node = nil
	end
	M.super.destroy(self)
end

return M