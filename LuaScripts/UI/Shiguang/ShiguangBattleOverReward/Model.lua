local M = class("ShiguangBattleOverRewardModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_ending_reward = self.m_params.ending_reward or {}
end

-- 只展示一个奖励
function M:getFirstReward()
	return self.m_ending_reward[1]
end

return M
