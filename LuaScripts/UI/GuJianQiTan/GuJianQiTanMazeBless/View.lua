local M = class("GuJianQiTanMazeBlessView",LikeOO.OOPopBase)

M.m_uiName = "GuJianQiTan/GuJianQiTanMazeBless"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("sure_btn_text", "new_str_0006")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	self.m_select_cell = nil
	self.m_model.m_select_index = -1
	local data = self.m_model.m_buff_index
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			--pos_center = true,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				Logger.logWarningAlways(click_name, "click_name==============")
				self:updateMsg("select_buff", index)
			end,
			ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local title_des = self.m_model:getCfgDataByKey(cell_data.buff_id, "title") or ""
	local detail_des = self.m_model:getCfgDataByKey(cell_data.buff_id, "detail") or ""
	local quality = self.m_model:getCfgDataByKey(cell_data.buff_id, "quality") or 1
	local color_index = quality + 3
	local text_color = GlobalConfig.QUALITY_FRIEND_ITEM[color_index].RGBA
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"name_text", title_des)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"detail_text", detail_des)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img", self.m_model.m_cur_index == index)
	LuaBehaviourUtil.setTextColor(luaBehaviour, "name_text", text_color)
end

return M