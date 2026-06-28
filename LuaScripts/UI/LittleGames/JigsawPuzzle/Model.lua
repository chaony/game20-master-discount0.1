local M = class("JigsawPuzzleModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_score = 0
	self.m_time = 0
	self.m_index = 1
	self.m_group_id = self.m_params.group_id or 5
	self.m_game_id = self.m_params.game_id or 5001
	local puzzle_pintu_cfg = ConfigManager:getCfgByName("puzzle_pintu")
	self.m_cur_puzzle_pintu_cfg = puzzle_pintu_cfg[self.m_game_id] or {}
end

function M:getMaxLevel()
	return self.m_cur_puzzle_pintu_cfg.game_num
end

function M:getScoreByTime()
	local time_tab = self.m_cur_puzzle_pintu_cfg.game_time
	local score_tab = self.m_cur_puzzle_pintu_cfg.cycle_time
	if self.m_index <= #score_tab and self.m_time > time_tab[self.m_index]  then
		self.m_index = self.m_index + 1
	end
	return score_tab[self.m_index] or self.m_cur_puzzle_pintu_cfg.limit
end

function M:addScore()
	local score = self:getScoreByTime()
	self.m_score = self.m_score + score
	self.m_time = 0
	self.m_index = 1
end

function M:resetData()
	self.m_score = 0
	self.m_time = 0
	self.m_index = 1
end

return M
