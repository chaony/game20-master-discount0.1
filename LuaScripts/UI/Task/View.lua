---@class TaskView:OOPopBase
---@field m_model TaskModel
local M = class("TaskView",LikeOO.OOPopBase)

M.m_uiName = "Task/Task"
M.m_size_type = 1
M.m_iphoneXAdapter = true
local __TAB_BTN_NODE = {
	{btn_key = "daliy_togglebtn", lua_name = "UI.Task.TaskDailyNode", btn_text = "daliy_btn_text", text_key = "new_str_0026", red_point_img = "daliy_red_point_img", red_point_key = "m_daily_red_point" }, -- 日常
	{btn_key = "week_togglebtn", lua_name = "UI.Task.TaskWeekNode", btn_text = "week_btn_text", text_key = "new_str_0027", red_point_img = "week_red_point_img", red_point_key = "m_weekly_red_point" }, -- 周常
	{btn_key = "main_togglebtn", lua_name = "UI.Task.TaskMainNode", btn_text = "main_btn_text", text_key = "new_str_0028", red_point_img = "main_red_point_img", red_point_key = "m_main_red_point" }, -- 主线
}

function M:onEnter()
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control,{mode = 16})
	self.m_toggle_btns = {}
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.btn_text, string.cutTextForString(Language:getTextByKey(v.text_key)))
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end, nil, self.m_uiName)
		self:setObjectVisible(v.red_point_img, false)
	end
	self.m_content_panel = self:findGameObject("content_panel")
	self.m_content_panel2 = self:findGameObject("war_order_btn")
    self:setTextByLanKey("common_title_text", "new_str_0360")
    self:setTextByLanKey("quest_auto_recv_btn_text", "mail_str_0017")
	self:setTextByLanKey("season_shop_btn_text", "season_shop_btn_tex")
	self:refreshUI()
	local token_cls = CustomRequire("UI.Task.TaskToKenNode")
	self.m_cur_token_node = token_cls.new(self.m_control, {parent = self.m_content_panel2})
	self:setTextByLanKey("close_title_text", "new_str_0360")
end

function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg(update_key)
	end
end

function M:refreshTokenData(slider_anim)
	if self.m_cur_token_node then
		self.m_cur_token_node:refreshData(slider_anim)
	end
end

function M:refreshUI()
	self:refreshRedPoint()
	local is_open = BtnOpenUtil:isBtnOpen(80) -- 战令是否开启
	self:setObjectVisible("war_order_btn", is_open == true)
	--快速导航
	self:setObjectVisible("guide_btn", true)
end

function M:switchTabNode(index)
	if self.m_cur_tab_node then
		self.m_cur_tab_node:destroy()
		self.m_cur_tab_node = nil
	end
	for k, v in pairs(__TAB_BTN_NODE) do
		local cur_tab_text = self:findText(v.btn_text)
		cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_25 or GlobalConfig.COMMON_COLLOR.COMMON_24
		--local outline_width = index == k and 2 or 0
		--UIUtil.setOutlineExEffectColor(cur_tab_text, nil, GlobalConfig.COMMON_COLLOR_OUTLINE.COMMON_3, outline_width)
	end
	local btn_tab = __TAB_BTN_NODE[index]
	if btn_tab then
	    local tab_cls = CustomRequire(btn_tab.lua_name)
	    self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
	end
	self:refreshQuestAutoRecvBtn(index)
end

function M:refreshCommonNode()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:refreshUI()
	end
	self:refreshRedPoint()
	self:refreshQuestAutoRecvBtn()
end

function M:refreshQuestAutoRecvBtn(index)
	index = index or self.m_model.m_sel_tab_index
	local show_recv_btn = (index == 3 and self.m_model.m_have_recv_main_quests == true) or (index == 1 and self.m_model.m_have_recv_daily_quests == true) or (index == 2 and self.m_model.m_have_recv_week_quests == true)
	self:setObjectVisible("quest_auto_recv_btn", show_recv_btn)
end

function M:runAnim(response)
	if self.m_cur_tab_node and self.m_cur_tab_node.runAnim then
		self.m_cur_tab_node:runAnim(response)
	end
	self:refreshRedPoint()
	self:refreshQuestAutoRecvBtn()
end

function M:runAnimRewardFly(response)
	if self.m_cur_tab_node and self.m_cur_tab_node.runAnimRewardFly then
		self.m_cur_tab_node:runAnimRewardFly(response)
	end
	self:refreshRedPoint()
	self:refreshQuestAutoRecvBtn()
end

function M:refreshRedPoint()
    for k, v in pairs(__TAB_BTN_NODE) do
        local red_flag = self.m_model[v.red_point_key]
        self:setObjectVisible(v.red_point_img, red_flag == true)
    end
	local season_red_flag = RedPointUtil:isFuncRedPointById(240)
	self:setObjectVisible("season_achievement_btn_red_point", season_red_flag)
end

function M:setValue(value1, value2,text_obj)
    local sequence = Tweening.DOTween.Sequence()
    sequence:SetAutoKill(false)
    sequence:Append(Tweening.DOTween.To(function(index)
        local temp = math.floor(index)
        text_obj.text = GameUtil:formatValueToString(temp)
    end, value1, value2, 1))
    return sequence
end

function M:destroy()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:destroy()
		self.m_cur_tab_node = nil
	end
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
	if self.m_cur_token_node then
		self.m_cur_token_node:destroy()
		self.m_cur_token_node = nil
	end
    M.super.destroy(self)
end

return M