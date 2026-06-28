local M = class("DragonBoatView",LikeOO.OOPopBase)

M.m_uiName = "Activities/DragonBoat/DragonBoat"
M.m_size_type = 1
M.m_iphoneXAdapter = true

M.LOCAL_TAB = { {open_id=353, btn_name = "btn_1",text = "btn1_text", name = "粽情好礼", red_point_img = "btn_red_point_img1"},
				{open_id=354, btn_name = "btn_2",text = "btn2_text", name = "粽意礼包", red_point_img = "btn_red_point_img2"},
				{open_id=355, btn_name = "btn_3",text = "btn3_text", name = "美味兑换", red_point_img = "btn_red_point_img3"},
				{open_id=356, btn_name = "btn_4",text = "btn4_text", name = "流觞曲水", red_point_img = "btn_red_point_img4"},
				{open_id=326, btn_name = "btn_5",text = "btn5_text", name = "厨神争霸", red_point_img = "btn_red_point_img5"},
				{open_id=323, btn_name = "btn_6",text = "btn6_text", name = "美味尝鲜", red_point_img = "btn_red_point_img6"},
}


function M:onEnter()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})

	self:refreshUI()
	local main_btn_cfg = GameUtil:getActiveData(352)
	if main_btn_cfg then
		self:setTextByLanKey("close_title_text", main_btn_cfg.name)
	else
		self:setTextByLanKey("close_title_text", "")	
	end

	for k,v in pairs(M.LOCAL_TAB) do
		local btn_cfg = self.m_model:getActiveData(v.open_id)
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
			local is_show = self.m_model:getItemTimeLimit(v.btn_name ) == 2
			self:setObjectVisible(v.red_point_img, red_flag and not is_show)
		elseif v.open_id == 354 then
			red_flag = RedPointUtil:getCommonGiftRedByOpenId(v.open_id, true)
			local is_show = self.m_model:getItemTimeLimit(v.btn_name) == 2
			self:setObjectVisible(v.red_point_img, red_flag and not is_show)
		elseif v.open_id == 323 then
			red_flag = self.m_model:checkCookRed()
			local is_show = self.m_model:getItemTimeLimit(v.btn_name) == 2
			self:setObjectVisible(v.red_point_img, red_flag and not is_show )
		else
			local is_show = self.m_model:getItemTimeLimit(v.btn_name) == 2
			self:setObjectVisible(v.red_point_img, red_flag and self.m_model:getActStatus() == 1 and not is_show)
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
		if end_ts < 0 then
			self:setTextByLanKey("text_timer", "new_str_0558")
		end
		self:updateMsg("udpate_data")
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
	M.super.destroy(self)
end
return M

