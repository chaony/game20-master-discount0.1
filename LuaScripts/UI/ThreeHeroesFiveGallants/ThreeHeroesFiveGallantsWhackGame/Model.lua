local M = class("ThreeHeroesFiveGallantsWhackGameModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.open_id = self.m_params.open_id or 387
	self.m_version = self.m_params.version or 1
	self.frequency = 0 --挑战次数
	self.m_active_data = self:getActiveData()
	self:getData("game_street_common_index",{open_id = self.open_id,vsn = self.m_version})
end

function M:onEnter()
	self.m_game_id = self.m_params.game_id
	self.m_is_mult = self.m_params.mult or false
	self.m_join_stage = self.m_params.join_stage or 1 --加入的势力
	local puzzle_dadishu_cfg = ConfigManager:getCfgByName("puzzle_dadishu")
	self.m_cur_puzzle_dadishu_cfg = puzzle_dadishu_cfg[self.m_game_id] or {}
	self:getreward()
end

function M:netData(data, tag)
	table.merge(self.m_data, data or {})
end

function M:getGameData()
	local game_time = self.m_cur_puzzle_dadishu_cfg.game_time or 20
	local cycle_time = self.m_cur_puzzle_dadishu_cfg.cycle_time or {2,5}
	return game_time, cycle_time
end

--获取活动数据
function M:getActiveData()
	local tongyong_little_game = ConfigManager:getCfgByName("tongyong_little_game")
	for i, v in pairs(tongyong_little_game) do
		if i == self.open_id then
			for value_i, value_v in pairs(v) do
				--self.m_version = value_i
				self.frequency = value_v.frequency
				return value_v
			end
		end
	end
	return nil
end

--获取奖励
function M:getreward()
	local common = ConfigManager:getCfgByName("chivalrous_period")
	return common[1][self.m_join_stage].proportion
end

return M
