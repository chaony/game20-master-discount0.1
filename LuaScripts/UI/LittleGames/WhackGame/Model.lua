local M = class("WhackGameModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_group_id = self.m_params.group_id
	self.m_game_id = self.m_params.game_id
	self.m_is_mult = self.m_params.mult or false
	local puzzle_dadishu_cfg = ConfigManager:getCfgByName("puzzle_dadishu")
	self.m_cur_puzzle_dadishu_cfg = puzzle_dadishu_cfg[self.m_game_id] or {}
end

function M:getGameData()
	local game_time = self.m_cur_puzzle_dadishu_cfg.game_time or 20
	local cycle_time = self.m_cur_puzzle_dadishu_cfg.cycle_time or {2,5}
	return game_time, cycle_time
end

return M
