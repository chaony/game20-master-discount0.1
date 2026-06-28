local M = class("LittleGamesRankRewardModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.is_mult = self.m_params.mult or false --是否是多期小游戏
	self.m_key = self.m_params.key or 1 --是否是多期小游戏
end

function M:getRankData()
	local game_street_rank_cfg = ConfigManager:getCfgByName("game_street_rank")
	if self.is_mult == true then
		local mini_game_tab = ConfigManager:getCfgByName("mini_game_rank")
		game_street_rank_cfg = mini_game_tab[self.m_key]
	end
	return game_street_rank_cfg
end

return M
