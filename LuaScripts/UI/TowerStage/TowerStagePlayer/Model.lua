local M = class("TowerStagePlayerModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_players = self.m_params.players or {}
end

function M:getPlayerData()
	return self.m_players
end

function M:getPlayerCount()
	return #self.m_players
end

function M:getPlayerDataByIndex(index)
	return self.m_players[index]
end

return M
