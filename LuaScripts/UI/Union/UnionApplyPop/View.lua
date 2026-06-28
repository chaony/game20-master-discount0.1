local M = class("UnionApplyPopView",LikeOO.OOPopBase)

M.m_uiName = "Union/UnionApplyPop"
M.m_size_type = 2

function M:onEnter()
	self:setText("common_title_text", Language:getTextByKey("union_str_0008"))
	self:setTextByLanKey("all_ignore_btn_text", "union_str_0048")
	self:setTextByLanKey("all_agree_btn_text", "union_str_0049")
	UserDataManager:removeRedDotByKey("guild_apply")
	self:refreshUI()
end

function M:refreshUI()
	self:setText("have_text", Language:getTextByKey("union_str_1044") .. self.m_model.m_member_num)
	self:setText("apply_text", Language:getTextByKey("friend_str_0011") .. #self.m_model.m_list_data)
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
				self:updateMsg(click_name, cell_data)
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data,true)
	end
end

function M:listHandle(obj, id, data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local HeadNode = luaBehaviour:FindGameObject("HeadNode")
	local name_text = luaBehaviour:FindText("name_text")
	local lv_text = luaBehaviour:FindText("lv_text")
	local power_text = luaBehaviour:FindText("power_text")
	local power_value_text = luaBehaviour:FindText("power_value_text")

	GameUtil:setUserAvatar(HeadNode, data, nil, nil, {show_flag = true, scale = 1})
	if data.name == "" then
		name_text.text = Language:getTextByKey("new_str_0141")
	else
		name_text.text = data.name
	end
	
	lv_text.text =  data.level
	power_text.text = Language:getTextByKey("friend_str_0041")
	power_value_text.text = data.full_combat
end

return M