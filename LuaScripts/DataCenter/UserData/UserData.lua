local M={
	user_status = {},
	old_level = nil,
	uid = nil,
	guild_talent_coin = 0
}

-- 设置玩家基本数据
function M:setUserData(data)
	if data == nil then return end
	self.user_status = data
	if self.old_level == nil then
		self.old_level = data.level
	end
	EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event="user_status_update", data = data} )
end

function M:getUid()
	if self.uid ~= nil then
		return self.uid
	end
	if self.user_status and self.user_status.uid then
		return self.user_status.uid
	else
		return ""
	end
end

--[[--
	通过key获得用户基础数据
]]
function M:getUserStatusDataByKey(key)
	--特殊处理巅峰帮会货币
	if key == "guild_talent_coin" then
		self.guild_talent_coin = self.user_status["guild_talent_coin"] or self.guild_talent_coin
		self.user_status["guild_talent_coin"] = self.guild_talent_coin
	end
	--特殊处理巅峰帮会货币
	return self.user_status[key]
end

function M:getOldLv()
	return self.old_level, self.user_status.level
end

function M:updateOldLv()
	self.old_level = self.user_status.level 
end

function M:getOwnRankData(data)
	local rank = data.rank or 0
	local score = data.score or 0
	local data = {rank = rank, score = score, time = 0}
	local uid = self:getUserStatusDataByKey("uid")
	local name = self:getUserStatusDataByKey("name")
	local level = self:getUserStatusDataByKey("level")
	local vip = self:getUserStatusDataByKey("vip")
	local avatar = self:getUserStatusDataByKey("avatar")
	local frame = self:getUserStatusDataByKey("frame")
	local title = self:getUserStatusDataByKey("title")
	local full_combat = self:getUserStatusDataByKey("full_combat")
	local guild_name = self:getUserStatusDataByKey("guild_name")
	data.user = {uid = uid, name = name, level = level, vip = vip, avatar = avatar, frame = frame, title = title, full_combat = full_combat,guild_name = guild_name}
	return data
end

return M