local M = class("LibrarySelectView",LikeOO.OOPopBase)

M.m_uiName = "Library/LibrarySelect"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("title_text", "new_str_0314")
	self:setTextByLanKey("ok_btn_text", "new_str_0315")
	self:setTextByLanKey("detail_btn_text", "new_str_0007")
	self:setTextByLanKey("tips_text", "new_str_0318", self.m_model:getHeroName())
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()

end

--[[
	创建列表
]]
function M:updateLoopScroll()
	self.m_model.m_select_cell_data = nil
	self.m_select_index = nil
	self.m_select_cell_object = nil
	local data = self.m_model:getShowData()
	self:setObjectVisible("tips_text", #data == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 3,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if self.m_select_index == index or cell_data.lend_num >= GlobalConfig.ASSIST_SUMMARIES_LIMIT_NUM then
					return
				end
				if self.m_select_cell_object then
					local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_cell_object)
					local duigoudi_img = luaBehaviour:FindGameObject("duigoudi_img")
					duigoudi_img:SetActive(false)
				end
				self.m_model.m_select_cell_data = cell_data
				self.m_select_cell_object = cell_object
				self.m_select_index = index
				local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_cell_object)
				local duigoudi_img = luaBehaviour:FindGameObject("duigoudi_img")
				duigoudi_img:SetActive(true)
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	GameUtil:updateItemElementByData(cell_object, cell_data, false, false)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "user_name_text", tostring(data.user_name))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "borrow_num_text", "new_str_0319", GlobalConfig.ASSIST_SUMMARIES_LIMIT_NUM)
	local lend_num = data.lend_num
	local duigoudi_img = luaBehaviour:FindGameObject("duigoudi_img")
	if self.m_select_index == index or data.select_flag then
		duigoudi_img:SetActive(true)
		self.m_model.m_select_cell_data = cell_data
		self.m_select_cell_object = cell_object
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "borrow_num_bg_img", false)
	else
		duigoudi_img:SetActive(false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "borrow_num_bg_img", lend_num >= GlobalConfig.ASSIST_SUMMARIES_LIMIT_NUM)
	end
end

return M