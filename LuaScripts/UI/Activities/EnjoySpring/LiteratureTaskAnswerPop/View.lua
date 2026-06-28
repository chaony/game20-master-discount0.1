local M = class("LiteratureTaskAnswerPopView",LikeOO.OOPopBase)

M.m_uiName = "Activities/EnjoySpring/LiteratureTaskAnswerPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
	self:refreshUI()
	self:setTextByLanKey("common_title_text", "enjoySpring_str_0024")
end

function M:refreshUI()
	local num = self.m_model.m_cur_question.."/"..self.m_model:getMaxNum()
	self:setTextByLanKey("com_title4", "enjoySpring_str_0023",num)
	local quest_cfg = self.m_model:getQuestion()
	if quest_cfg then
		self:setTextByLanKey("count_des",  quest_cfg.question)
		local answers = {}
		for i = 1, 4 do
			local str = "answer_text_"..i
			local ans_str = quest_cfg["answer"..i]
			self:setTextByLanKey(str, ans_str)
			local img_str = "turns_img_"..i
			self:setObjectVisible(img_str, false)
		end
	end
end

function M:showTurns(callback)
	local quest_cfg = self.m_model:getQuestion()
	if quest_cfg then
		local answers = {}
		if self.m_model.m_cur_answer_id then
			if quest_cfg.correct == self.m_model.m_cur_answer_id then
				audio:SendEvtUI("UI_QDYLi_QD")
			else
				audio:SendEvtUI("UI_Square_Error")
			end
		end
		self.m_model.m_cur_answer_id = nil
		for i = 1, 4 do
			local img_str = "turns_img_"..i
			local img = nil
			if quest_cfg.correct == i then
				img = self:setImg("a_cdm_zhengque","pub_ui",img_str)
			else
				img = self:setImg("a_cdm_cuowu","pub_ui",img_str)	
			end
			img:SetNativeSize()
			self:setObjectVisible(img_str, true)
		end
	end
	self.m_control:setOnceTimer(2,callback)
end

function M:everyDayRefreshEvent()
	GameUtil:lookInfoTips(self.m_control, {msg = "new_str_1087", delay_close = 2})
	self:updateMsg(99999)
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
	M.super.destroy(self)
end
return M