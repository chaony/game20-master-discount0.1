local M = class("CompareSwordResultHistoryView", LikeOO.OOPopBase)
--剑试天下 前三甲界面 切换查看往届历史弹窗
M.m_uiName = "CompareSwordWithWorld/CompareSwordResult/CompareSwordResultHistory"
M.m_iphoneXAdapter = true
M.m_size_type = 2

function M:onEnter()

	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
	self:setTextByLanKey("common_title_text", "compare_sword_history_001")
end

function M:updateLoopScroll()
	self.m_click_cell_object = nil
	local data = self.m_model.m_active
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")  
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name) --点击事件
				if click_name == "btn_look" then
					self:updateMsg("onclick_btn_look", {active = cell_data})
				end
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

local name_str = "compare_sword_history_"     --支持10届
function M:updateScrollViewCell(idx , obj , data)
	local luaObj = UIUtil.findLuaBehaviour(obj.transform)
	if luaObj  then
		local time_str = GameUtil:getTimeStrByActivves(data)
		local name_str = name_str .. data.version
		LuaBehaviourUtil.setTextByLanKey(luaObj , "text_ceilTitle" , name_str)
		LuaBehaviourUtil.setTextByLanKey(luaObj , "text_ceilTime" , time_str)
		LuaBehaviourUtil.setTextByLanKey(luaObj , "text_look" , "compare_sword_history_002")
	end
end

function M:destroy()

	M.super.destroy(self)
end


return M