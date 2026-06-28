local M = class("RacconGameEntranceModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_open_id = 360
	self.m_game_data = UserDataManager:getActivesDataByOpenId(self.m_open_id)
end

function M:getStartTime()
	return self.m_game_data["start_ts"]
end

function M:getEndTime()
	return self.m_game_data["end_ts"]
end

return M
