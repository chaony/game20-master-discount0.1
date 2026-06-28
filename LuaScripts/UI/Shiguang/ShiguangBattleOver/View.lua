local M = class("ShiguangBattleOverView",LikeOO.OOPopBase)

M.m_uiName = "ShiGuang/ShiguangBattleOver"
M.m_size_type = 2

function M:onEnter()
	-- self:setTextByLanKey("title_text", "new_str_0200")
	self:setTextByLanKey("title_text", "new_str_0456" , self.m_model:getShowName())
	self:setTextByLanKey("ok_btn_text", "new_str_0201")
	self:setTextByLanKey("tips_text", "new_str_0243")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getShowData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				local luaBehaviour = UIUtil.findLuaBehaviour(transform)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "des_text", tostring(cell_data))
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

return M