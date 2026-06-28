local M = class("ChatGroupPopView",LikeOO.OOPopBase)

M.m_uiName = "Chat/ChatGroupPop"
M.m_size_type = 2
function M:onEnter()
	self:setTextByLanKey("create_btn_text","chat_new_text_001")
	self:refreshUI()
end

function M:refreshUI()
	self:updateFriendList()
	self:updateSelectList()
end

function M:updateFriendList()
	local data = { 1, 2, 3 }
	
	if self.m_friend_scroll == nil then
		local list_scroll = self:findGameObject("friend_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
				--LuaBehaviourUtil.setText(luaBehaviour, "type_des_text", type_data[index])
				--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_detail_loopscroll", self.m_model.m_type_select_index == index)
				local rect = cell_object:GetComponent("RectTransform")
				local expend_btn = luaBehaviour:FindGameObject("expend_btn")
			
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				--ChatUtil.player_red_points[cell_data] = 0
				self:updateMsg("click_tab_btn", { index = index,  cell_data = cell_data})
			end
		}
		self.m_friend_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_friend_scroll:reloadData(data, nil)
	end
end

function M:updateSelectList()
	local data = { 1, 2, 3 }

	if self.m_select_scroll == nil then
		local list_scroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 2,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
				--LuaBehaviourUtil.setText(luaBehaviour, "type_des_text", type_data[index])
				--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_detail_loopscroll", self.m_model.m_type_select_index == index)
				local rect = cell_object:GetComponent("RectTransform")

			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				--ChatUtil.player_red_points[cell_data] = 0
				self:updateMsg("click_tab_btn", { index = index,  cell_data = cell_data})
			end
		}
		self.m_select_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_select_scroll:reloadData(data, nil)
	end
end

return M