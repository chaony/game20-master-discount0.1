local M = class("FiveLinesGreatRewardNewView",LikeOO.OOPopBase)

M.m_uiName = "FiveLinesNew/FiveLinesGreatRewardNew"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
	audio:SendEvtUI("Play_UI_Enemy")
	self:setTextByLanKey("main_title_text","fiveline_new_main_title_text")
	self:setTextByLanKey("kaiqi_text","new_str_0997")
	self:setTextByLanKey("yikaiqi_text","fiveline_new_ykq_text")
end

function M:refreshUI()
	--设置标题
	self:setTextByLanKey("common_title_text", "tid#NfourtowerName_"..self.m_model:getType())
	--设置宝箱图片
	LuaBehaviourUtil.setImg(self.m_luaBehaviour,"baoxiang_img", self.m_model:getBaoXiangImg(),  "maze_stage_ui")
	--创建奖励列表
	self:createLoopScroll();
	--设置按钮状态
	local box_status = self.m_model:getBoxStatus()
	self:setObjectVisible("kaiqi_btn", box_status == 0)
	self:setObjectVisible("yikaiqi_btn", box_status == 1)
	
end

function M:createLoopScroll()
	self.m_gift_tab = {}
	local data = self.m_model:getGiftData()
	
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 4,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_obj, cell_data)
				local item_data = RewardUtil:getProcessRewardData(cell_data)
				GameUtil:updateItemElementByData(cell_obj, item_data, true, false)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)

			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(data)
	end
end

return M