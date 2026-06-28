local M = class("IdlePopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/IdlePop"

function M:onEnter()
	self:setTextByLanKey("tips_text","new_str_0779")
	self:setTextByLanKey("tips_text2","new_str_0780")
	self.m_battery_slider = self:findSlider("battery_slider")
	self:refreshUI()
end

function M:refreshUI()
	local network_reachability = GameUtil:getNetworkReachability()
	if network_reachability == "wifi" then
		self:setTextByLanKey("network_type_text","new_str_0781")
	elseif network_reachability == "4G" then
		self:setTextByLanKey("network_type_text","new_str_0782")
	else
		self:setTextByLanKey("network_type_text","new_str_0783")
	end
	local battery_value = U3DUtil:Get_SystemInfo_batteryLevel()
	self:setTextByLanKey("battery_text",math.floor(battery_value*100) .. '%')
	self.m_battery_slider.value = battery_value
end

function M:updateTimeText()
	local server_time = UserDataManager:getServerTime()
	local server_time_tab = TimeUtil.gmTime(server_time)
	self:setTextByLanKey("time_text", string.format("%02d:%02d", server_time_tab.hour, server_time_tab.min))
end

return M