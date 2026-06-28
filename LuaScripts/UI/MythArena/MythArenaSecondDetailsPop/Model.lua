local M = class("MythArenaSecondDetailsPopModel", LikeOO.OODataBase)

function M:onCreate()
	-- self.m_transfer = "up_to_down"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_log_data = self.m_params.log_data or {}
	self.m_user_data = self.m_params.user_data or {}
	self.m_guess_uid = self.m_params.guess_uid or 0
	self.m_cur_stage = self.m_params.cur_stage or 0
end

function M:getBattleLog()
	local battle_log = self.m_log_data.battle_log or {}
	return battle_log
end

function M:getUserInfoByUid(auid)
	local uid = tostring(auid)
	if self.m_user_data[uid] then
		return self.m_user_data[uid]
	end
	return nil
end

return M
