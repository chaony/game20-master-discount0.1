local M = class("HeroBossModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("hero_boss_index")
end

function M:onEnter()
	local cfg = ConfigManager:getCfgByName("hero_boss")
	self.m_cfg = cfg[self.m_data.id]
end

function M:getLeftTimes(is_challenge)
	if is_challenge then
		return self.m_cfg.challenge_max_times - self.m_data.challenge_times
	else
		return self.m_cfg.loot_max_times - self.m_data.loot_times
	end
end

function M:getMyRank(rank, score, is_guild)
	local user = {}
	if is_guild == true then
		user.name =  UserDataManager.user_data:getUserStatusDataByKey("guild_name")
	else
		user.name = UserDataManager.user_data:getUserStatusDataByKey("name")
	end
	user.uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	user.level = UserDataManager.user_data:getUserStatusDataByKey("level")
	user.avatar = UserDataManager.user_data:getUserStatusDataByKey("avatar")
	user.guild_uid = UserDataManager.user_data:getUserStatusDataByKey("guild_uid")
	user.guild_name = UserDataManager.user_data:getUserStatusDataByKey("guild_name")
	user.server_name = UserDataManager.user_data:getUserStatusDataByKey("server_name") or ""
	local myRank = {rank = rank, score = score, user = user}
	return myRank
end

function M:getBossID()
	return self.m_data.id or 1
end

return M