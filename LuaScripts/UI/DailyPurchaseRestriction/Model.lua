local M = class("DailyPurchaseRestrictionModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	self.m_open_id = 380
	self.m_version = self.m_params.version or 1
	self.is_tokens = self.m_params.is_token
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_active_data = UserDataManager:getActivesRechargeDataByOpenId(self.m_open_id)
end

function M:getViewName()
	local cfg = ConfigManager:getCfgByName("active_recharge")
	for _, v in pairs(cfg) do
		if v.open_id == self.m_open_id and v.version == self.m_active_data.version then
			return v.name_2
		end
	end
	return ""
end

function M:getEndTs()
	local server_time = UserDataManager:getServerTime()
	local next_fresh_time = TimeUtil.getIntTimestamp(server_time)
	local end_times = next_fresh_time + 24 * 3600
	return end_times
end

function M:getGiftCfg()
	local gift_tab = ConfigManager:getCfgByName("tongyong_gift")[self.m_open_id] or {}
	local gift_version_tab = gift_tab[self.m_active_data.version] or {}
	return gift_version_tab[1][1][1][1]
end



return M
