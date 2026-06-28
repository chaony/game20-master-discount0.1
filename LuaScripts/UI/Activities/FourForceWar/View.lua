local M = class("FourForceWarIndexView",LikeOO.OOPopBase)

M.m_uiName = "Activities/FourForceWar/FourForceWarIndex"
M.m_size_type = 1

function M:onEnter()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
	self:setObjectVisible("close_btn", false)
	self.m_control:setOnceTimer(1, function()
		self:setObjectVisible("close_btn", true)
	end)
end

function M:refreshUI()
	self:refreshRedPoint()
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

