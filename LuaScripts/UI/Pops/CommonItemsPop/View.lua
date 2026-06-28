local M = class("CommonItemsPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/CommonItemsPop"
M.m_size_type = 2

function M:onEnter()	
	self:setText("ok_text", self.m_model.m_ok_text)
	self:setText("common_title_text", self.m_model.m_title)
	self:refreshUI()
end

function M:refreshUI()
	self:updateListScroll()
end

function M:updateListScroll()
	local data = self.m_model.m_items
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			one_line_count = 4,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:listHandle(cell_object, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)

			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data)
	end
end

function M:listHandle(obj, id)
	local data = self.m_model:getDataByIndex(id)
	GameUtil:updateItemElement(obj, data, true, true)
end

return M