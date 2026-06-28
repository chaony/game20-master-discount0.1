local M = class("GuildHighWarBattlingPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_city_id = self.m_params.city_id
	self:getData("guild_high_war_battle_teams", {city_id = self.m_city_id})
end

function M:onEnter()
	self.m_user_infos = self.m_data.user_infos or {}
	self.m_atk_data = self.m_data.atk_data or {}
	self.m_def_data = self.m_data.def_data or {}
	self.m_user_tab = {}
end

function M:getUserInfoByUid(uid)
	local user_data = self.m_user_infos[uid] or {}
	return user_data
end

function M:getShowData()
	return #self.m_atk_data > #self.m_def_data and self.m_atk_data or self.m_def_data
end

return M
