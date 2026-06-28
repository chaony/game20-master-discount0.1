local M = class("RacconGameEntranceView",LikeOO.OOPopBase)

M.m_uiName = "Raccon/RacconGameEntrance"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("close_title_text", "raccon_text_0021")
	self:displayActivityPeriod()
end

function M:displayActivityPeriod()
	local start_ts = self.m_model:getStartTime()
	local end_ts = self.m_model:getEndTime()
	local start_date = TimeUtil.gmTime(start_ts or 0)
	local end_date = TimeUtil.gmTime(end_ts or 0)
	local format_start_time = start_date.year .. "." .. start_date.month .. "." .. start_date.day
	local format_end_time = end_date.year .. "." .. end_date.month .. "." .. end_date.day
	self:setTextByLanKey("des_text", "raccon_text_0023")
	self:setText("time_text", format_start_time .. "-" .. format_end_time)
end

return M