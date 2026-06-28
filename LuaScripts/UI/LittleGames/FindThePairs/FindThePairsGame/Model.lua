local M = class("FindThePairsGameModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_group_id = self.m_params.group_id
	self.m_game_id = self.m_params.game_id
	self.m_open_id = self.m_params.open_id
	self.m_is_mult = self.m_params.mult or false
	self.m_open_type = self.m_params.open_type or ""
	local puzzle_lianliankan = ConfigManager:getCfgByName("puzzle_lianliankan")
	self.m_cur_puzzle_lianliankan_cfg = puzzle_lianliankan[self.m_game_id] or {}
end

function M:getMaxLevel()
	return self.m_cur_puzzle_lianliankan_cfg.game_num or 1
end

function M:getLevelData(level)
	local level_time = self.m_cur_puzzle_lianliankan_cfg.game_id[level] or 1
	return level_time
end

function M:getServerLogDes(score)
	local tongyong_little_game_end = ConfigManager:getCfgByName("tongyong_little_game_end") or {}
	local cur_vsn_cfg = tongyong_little_game_end[self.m_group_id] or {}
	local des = ""
	for i =  1, #cur_vsn_cfg do
		local ability = cur_vsn_cfg[i].ability
		if score >= ability[1] and score < ability[2] then
			des = cur_vsn_cfg[i].epilogue
		end
	end
	return des
end

return M
