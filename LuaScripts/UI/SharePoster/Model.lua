local M = class("SharePosterModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_version = self.m_params.version
	self.m_picture_id = self.m_params.picture_id
	self.m_sort = self.m_params.sort or 1
	self.m_moon_shadow_flag = self.m_params.moon_shadow_flag or false
	self.m_callback = self.m_params.callback
end

function M:getTexture()
	local name = nil
	local sword_star = ConfigManager:getCfgByName("sword_star")
	local sword_star_cfg = sword_star[self.m_version][self.m_picture_id]
	if sword_star_cfg then
		local bundleid = SDKUtil.sdk_params.applicationId or ""
		if bundleid == "com.hermes.wl" then
			name = sword_star_cfg.channel_batydance
		else
			name = sword_star_cfg.channel_other
		end
	end
	return name
end

return M
