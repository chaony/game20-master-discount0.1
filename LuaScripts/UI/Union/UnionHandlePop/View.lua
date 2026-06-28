local M = class("UnionHandleView",LikeOO.OOPopBase)

M.m_uiName = "Union/UnionHandlePop"
M.m_size_type = 2

function M:onEnter()	
	self:setTextByLanKey("common_title_text", "union_str_1051")

	self:refreshUI()
end

function M:refreshUI()
	self:updateListScroll()
end

function M:updateListScroll()
	local data = self.m_model.m_handle_list
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
				self:updateMsg(click_name, cell_data)
			end,
			ui_name = self.m_uiName
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data,true)
	end
end

function M:listHandle(obj, id, data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	if data == GlobalConfig.UNION_HANDLE_ID.DEMOTE then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_btn_text", "union_str_1054", Language:getTextByKey("union_str_1056"))
	elseif data == GlobalConfig.UNION_HANDLE_ID.CHANGE_ELITE then
		local flag = self.m_model:isNPC()
		if flag then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_btn_text", "union_str_1054", Language:getTextByKey("union_str_1057"))
		else
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_btn_text", "union_str_1053")
		end
	elseif data == GlobalConfig.UNION_HANDLE_ID.PROMOTE_ELDER then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_btn_text", "union_str_1052")
	elseif data == GlobalConfig.UNION_HANDLE_ID.DELETE then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_btn_text", "union_str_1055")
	elseif data == GlobalConfig.UNION_HANDLE_ID.BLACK then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_btn_text", "new_str_0376")
	end
end

return M