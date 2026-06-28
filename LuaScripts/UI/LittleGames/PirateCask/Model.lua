local M = class("PirateCaskModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_group_id = self.m_params.group_id
	self.m_is_mult = self.m_params.mult or false
	self.m_game_id = 1001
	local puzzle_feidao_cfg = ConfigManager:getCfgByName("puzzle_feidao")
	self.m_cur_puzzle_feidao_cfg = puzzle_feidao_cfg[self.m_game_id] or {}
end

function M:getLevelDataByIndex(index)
	local game_id = self.m_cur_puzzle_feidao_cfg.game_id or {}
	local bullet = self.m_cur_puzzle_feidao_cfg.bullet or {}
	local dir = self.m_cur_puzzle_feidao_cfg.dir or {}
	return game_id[index], bullet[index], dir[index] 
end

function M:getMaxLevel()
	local game_id = self.m_cur_puzzle_feidao_cfg.game_id or {}
	return #game_id
end

function M:getChallenge()
	return self.m_cur_puzzle_feidao_cfg.challenge or 0
end

return M
