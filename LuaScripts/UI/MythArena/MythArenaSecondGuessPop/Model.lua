local M = class("MythArenaSecondGuessPopModel", LikeOO.OODataBase)

function M:onCreate()
	-- self.m_transfer = "up_to_down"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_stage_id = self.m_params.stage_id or 0
	self.m_reward_cfg_id = self.m_stage_id + 4
	self.m_guess_uid = self.m_params.guess_uid or 0
	self.m_group_id = self.m_params.group_id or 0
	self.m_user_data = self.m_params.user_data or {}
	self.m_myth_times_cfg = ConfigManager:getCfgByName("myth_reward") or {}
	self.m_win_num = 0
	self.m_guess_player_data = {}
end

function M:updateData(data)
	table.merge(self.m_data, data)
end

function M:getGuessRewardData()
	if self.m_myth_times_cfg[tonumber(self.m_reward_cfg_id)] then
		for i, v in pairs(self.m_myth_times_cfg[tonumber(self.m_reward_cfg_id)]) do
			return v
		end
	end
	return nil
end

return M
