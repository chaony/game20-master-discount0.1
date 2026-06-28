local M = class("GambleChooseView",LikeOO.OOPopBase)

M.m_uiName = "Gamble/GambleChoose"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("common_title_text", "")
	self:setTextByLanKey("default_double_check_text", "gamble_text_004")
	local question_data = self.m_model:getQuestionData() or {}
	self:setTextByLanKey("question_text", question_data.question or "")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
	self:refreshChooseDoubleCheckButtonStatus()
end

function M:updateLoopScroll()
	local data = self.m_model:getContentData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateInsideRankLoopScrollCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("choose_answer", index)
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:updateInsideRankLoopScrollCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "choose_flag_img", index == self.m_model:getChooseIndex())
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "answer_text", cell_data[1] or "")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "weight_text", cell_data[2] or "")
end

function M:refreshChooseDoubleCheckButtonStatus()
	self:setObjectVisible("default_double_check_img", self.m_model:getChooseDoubleCheckFlag() == 0)
end

return M