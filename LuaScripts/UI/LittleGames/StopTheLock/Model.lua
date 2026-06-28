local M = class("StopTheLockModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_group_id = self.m_params.group_id
	self.m_game_id = self.m_params.game_id
	self.m_is_mult = self.m_params.mult or false
	local puzzle_kaisuo_cfg = ConfigManager:getCfgByName("puzzle_kaisuo")
	self.m_cur_puzzle_kaisuo_cfg = puzzle_kaisuo_cfg[self.m_game_id] or {}
end

function M:getMaxLevel()
	return self.m_cur_puzzle_kaisuo_cfg.game_num
end

function M:getLevelData(level)
	local dot_num = self.m_cur_puzzle_kaisuo_cfg.game_id[level] or 1
	local speed = self.m_cur_puzzle_kaisuo_cfg.speed[level] or 5
	return dot_num, speed
end

return M
