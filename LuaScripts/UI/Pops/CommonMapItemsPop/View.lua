local M = class("CommonMapItemsPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/CommonMapItemsPop"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
    创建任务列表
]]
function M:updateLoopScroll()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("list_scroll")
		local params = {
            ui_name = self.m_uiName,
            show_data = self.m_model.m_rewards,
            one_line_count = 6,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				GameUtil:updateItemElement(cell_object, cell_data,false,true)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				if luaBehaviour then
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"camp_bg", false)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"camp_img", false)
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
         
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(self.m_model.m_rewards)
	end
end

return M