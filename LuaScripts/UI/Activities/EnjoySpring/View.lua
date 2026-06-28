local M = class("EnjoySpringView",LikeOO.OOPopBase)

M.m_uiName = "Activities/EnjoySpring/EnjoySpring"
M.m_size_type = 1
M.m_iphoneXAdapter = true

M.LOCAL_TAB = { {open_id=310, text = "btn1_text", name = "翠柳轩", red_point_img = "btn_red_point_img1"},
				{open_id=311, text = "btn2_text", name = "云鸢柳", red_point_img = "btn_red_point_img2"},
				{open_id=309, text = "btn3_text", name = "文曲榜", red_point_img = "btn_red_point_img3"},
				{open_id=308, text = "btn4_text", name = "赏春阁", red_point_img = "btn_red_point_img4"},
}


function M:onEnter()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})

	self:refreshUI()
	local main_btn_cfg = BtnOpenUtil:getBtnCfg(307)
	if main_btn_cfg then
		self:setTextByLanKey("close_title_text", main_btn_cfg.name)
	else
		self:setTextByLanKey("close_title_text", "")	
	end

	for k,v in pairs(M.LOCAL_TAB) do
		local btn_cfg = BtnOpenUtil:getBtnCfg(v.open_id)
		if btn_cfg then
			self:setTextByLanKey(v.text, string.cutTextForString(Language:getTextByKey(btn_cfg.name)))
		else
			self:setTextByLanKey(v.text, string.cutTextForString(Language:getTextByKey(v.name)))
		end
	end
end

function M:refreshUI()
	self:refreshRedPoint()
end

function M:refreshRedPoint()
	for k,v in pairs(M.LOCAL_TAB) do
		local red_flag = RedPointUtil:hasRedPointById(v.open_id)
		if v.open_id == 309 then
			self:setObjectVisible(v.red_point_img, red_flag)
		else
			self:setObjectVisible(v.red_point_img, red_flag and self.m_model:getActStatus() == 1)
		end
	end
end

function M:everyDayRefreshEvent()
	self:updateMsg("update_data")
end

function M:updateActivityTimer()
	local end_ts, act_status = self.m_model:getEndTs()
	if end_ts >= 0 and act_status == 1 then
		local text = GameUtil:formatTimeBySecond(end_ts)
		text = Language:getTextByKey("new_str_0919") .. text
		self:setTextByLanKey("text_timer", text)
	elseif act_status == 2 then
		self:setTextByLanKey("text_timer", "new_str_0558")
	else
		self:updateMsg("udpate_data")
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
	M.super.destroy(self)
end
return M

