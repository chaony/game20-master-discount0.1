local M = class("GambleMainView",LikeOO.OOPopBase)

M.m_uiName = "Gamble/GambleMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
 	self.m_gray_material = self:findText("material_node").material
	local active_data = self.m_model:getActiveCfg() or {}
	self:setText("close_title_text", active_data.name or "")
	self:refreshUI()
end

function M:refreshUI()
	self:switchToggleIndex()
	if self.m_scroll_view_toggle then
		self.m_scroll_view_toggle:moveToCellIndex(self.m_model:getSelectedIndex())
	end
end

function M:switchToggleIndex()
	self:updateLoopScrollToggle()
	self:updateLoopScrollContent()
	self:updateNationFlag()
	self:updateActivityTimer()
end

--左侧标签滑动框
function M:updateLoopScrollToggle()
	local data_tog = self.m_model:getMainData()
	if self.m_scroll_view_toggle == nil then
		local loopscroll = self:findGameObject("loopscroll_toggle")
		local params = {
			show_data = data_tog,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_obj, cell_data)
				self:updateLoopScrollToggleCell(index, cell_obj)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("switch_toggle", index)
			end,
		}
		self.m_scroll_view_toggle = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view_toggle:reloadData(data_tog, true)
	end
end

function M:updateLoopScrollToggleCell(index, cell_obj)
	local selected = index == self.m_model:getSelectedIndex()
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
	if luaBehaviour then
		local tag_name = luaBehaviour:FindText("tag_name_text")
		tag_name.text = Language:getTextByKey("gamble_text_011", index)
		if selected then
			tag_name.color = Color(255 / 255, 240 / 255, 231 / 255)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", true)
		else
			tag_name.color = Color(143 / 255, 147 / 255, 156 / 255)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", false)
		end
	end
end

--内容滑动框
function M:updateLoopScrollContent()
	local data = self.m_model:getSelectedMainData() or {}
	local data_questions = data.questions or {}
	if self.m_scroll_view_content == nil then
		local loopscroll = self:findGameObject("loopscroll_content")
		local params = {
			show_data = data_questions,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateLoopScrollContentCell(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("open_question", cell_data)
			end
		}
		self.m_scroll_view_content = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view_content:reloadData(data_questions)
	end
end

function M:updateLoopScrollContentCell(cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local content_str = ""
	local answers = cell_data.cfg.answers
	if cell_data.data.option and #cell_data.data.option > 0 then
		for k, v in pairs(cell_data.data.option or {}) do
			content_str = content_str .. "[" .. v .. "] " .. answers[v][1] .. "  "
		end
	else
		content_str = Language:getTextByKey("gamble_text_012")
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "content_text", "gamble_text_008", cell_data.cfg.question, content_str)
	
	local status = cell_data.data.status
	if cell_data.data.stage > 1 then --过了预测阶段，都置于查看状态，不管有没有预测
		status = 2
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "status_btn_text", "gamble_text_00" .. (status + 1))
	local texture_name = status == 0 and "a_ui_currency_btn_small_2" or "a_ui_currency_btn_small_3"
	LuaBehaviourUtil.setImg(luaBehaviour, "status_btn", texture_name, "common_ui")
end

function M:updateNationFlag()
	local cell_data = self.m_model:getSelectedMainData()
	self:setImg(cell_data.cfg.country1 or "", "nation_flag", "nation_flag_0_image")
	self:setImg(cell_data.cfg.country2 or "", "nation_flag", "nation_flag_1_image")
	self:setTextByLanKey("nation_name_0_text", cell_data.cfg.name1 or "")
	self:setTextByLanKey("nation_name_1_text", cell_data.cfg.name2 or "")
end

function M:updateActivityTimer()
	local time_left, stage = self.m_model:getCurrentGroupTimeLeft()
	self:setObjectVisible("time_node", time_left > 0)
	self:setTextByLanKey("time_down_show_text", stage == 2 and "gamble_text_016" or "gamble_text_013")
	self:setObjectVisible("time_down_show_text", time_left <= 0)
	if time_left > 0 then
		self:setTextByLanKey("time_down_text", GameUtil:formatTimeBySecond(time_left))
	elseif time_left == 0 then
		self.m_control:outdateCheck()
	end
	
	time_left = self.m_model:getActivityTimeLeft()
	if time_left <= 0 then
		self:updateMsg(99999)
	end
end

return M