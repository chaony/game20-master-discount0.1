local M = class("LuckyRabbitHutProgressPopView", LikeOO.OOPopBase)
--
M.m_uiName = "LuckyRabbitHut/LuckyRabbitHutProgressPop"
M.m_iphoneXAdapter = true
M.m_size_type = 2



function M:onEnter()

	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
	local unlock_index = self.m_model:getUnlockIndex()
	self.m_loop_scroll_view:moveToCellIndex(unlock_index)
	self:setTextByLanKey("common_title_text", "lucky_rabbit_hut_004")
end

function M:updateLoopScroll()
	self.m_click_cell_object = nil
	local data = self.m_model:getMileage()
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

function M:updateScrollViewCell(idx , obj , data)
	local luaObj = UIUtil.findLuaBehaviour(obj.transform)
	if luaObj  then
		local txt_title = Language:getTextByKey("lucky_rabbit_hut_001", data.times)
		LuaBehaviourUtil.setTextByLanKey(luaObj , "text_ceilTitle" , txt_title)
		local txt_bonus = (data["return"] * 100) .. "%"
		LuaBehaviourUtil.setTextByLanKey(luaObj , "text_ceil_bonus" , txt_bonus)
		local txt_times = "/" .. data.times
		LuaBehaviourUtil.setTextByLanKey(luaObj , "text_ceil_time" , txt_times)
		local times_value =  self.m_model.m_total_times >= data.times and data.times or self.m_model.m_total_times
		LuaBehaviourUtil.setTextByLanKey(luaObj , "text_ceil_time_value" , times_value)

		LuaBehaviourUtil.setTextByLanKey(luaObj , "text_ceil_lock" , self.m_model.m_total_times >= data.times and "lucky_rabbit_hut_003" or "lucky_rabbit_hut_002")
		--local txt_times_value = luaObj:FindGameObject("text_ceil_lock")
		--UIUtil.setTextColor(txt_times_value.transform,self.m_model.m_total_times >= data.times and Color( 69/255, 156/255, 69/255) or Color( 123/255, 123/255, 123/255) )
	end
end



function M:destroy()

	M.super.destroy(self)
end


return M