local M = class("LiteratureTaskPopView",LikeOO.OOPopBase)

M.m_uiName = "Activities/EnjoySpring/LiteratureTaskPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
	self:setTextByLanKey("com_title", "enjoySpring_str_0019")
	-- self:setTextByLanKey("com_title2", "共计9轮 每题1分钟")
	self:setTextByLanKey("com_title3", "enjoySpring_str_0020",3)
	self:setTextByLanKey("com_title4", "enjoySpring_str_0034",5)
	self:setTextByLanKey("start_text", "enjoySpring_str_0021")
	self:setTextByLanKey("finish_text", "enjoySpring_str_0028")
	self:refreshUI()
end

function M:refreshUI()
	if self.m_model.m_cur_question > 0 then
		local dui_num =  self.m_model.correct_times
		self:setTextByLanKey("com_title", "enjoySpring_str_0022", dui_num)
	end
	local tc_reward = self:findGameObject("tc_reward")
	UIUtil.destroyAllChild(tc_reward.transform)
	local com_reward = self:findGameObject("com_reward")
	UIUtil.destroyAllChild(com_reward.transform)
	local com_rewards = self.m_model:getRiddleReward(3)
	local tc_rewards = self.m_model:getRiddleReward(5)
	for k, v in pairs(com_rewards) do
		local item_obj = GameUtil:createItemElement(v,true,true)
		item_obj.transform:SetParent(com_reward.transform, false)
	end
	for k, v in pairs(tc_rewards) do
		local item_obj = GameUtil:createItemElement(v,true,true)
		item_obj.transform:SetParent(tc_reward.transform, false)
	end
	if self.m_model.m_finish == true then
		self:setObjectVisible("finish_text", true)
		self:setObjectVisible("start_btn", false)
	else
		self:setObjectVisible("finish_text", false)
		self:setObjectVisible("start_btn", true)	
	end
end

function M:everyDayRefreshEvent()
	--GameUtil:lookInfoTips(self.m_control, {msg = "new_str_1087", delay_close = 2})
	self:updateMsg(99999)
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
	M.super.destroy(self)
end


return M