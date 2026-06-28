local M = class("GuJianQiTanMazeRewardModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_version = self.m_params.version or 1
	self.ranks_rewards = self:getRankRewards()
end

--奖励列表
function M:getRankRewards()
	local base_reward_tab = ConfigManager:getCfgByName("sword_akuma_floor")
	local vsn_reward_tab = base_reward_tab[self.m_version] or {}
	return vsn_reward_tab
end

return M
