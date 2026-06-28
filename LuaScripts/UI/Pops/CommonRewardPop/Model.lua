local M = class("CommonRewardPopModel", LikeOO.OODataBase)

local __DEFAULT_FLY_REWARD_TYPES = {[RewardUtil.REWARD_TYPE_KEYS.COIN] = 1, [RewardUtil.REWARD_TYPE_KEYS.HERO_EXP] = 1}

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_rewards = self.m_params.reward or {}
	self.m_callback = self.m_params.callback
	self.m_params.extra = self.m_params.extra or {}
	self.m_from_type = self.m_params.extra.from_type or 0;
	self.m_from_rewards = self.m_params.extra.from_rewards
	self.m_tips = self.m_params.extra.tips
	self.m_tips_up = self.m_params.extra.tips_up
	self.m_delay = self.m_params.extra.delay
	self.m_double = self.m_params.extra.double or false;
	self.m_fly = self.m_params.extra.fly or false
	self.m_allDouble = self.m_params.extra.allDouble or false;
	self.m_firstReward = self.m_params.extra.firstReward or false;
	self.m_fly_target = self.m_params.extra.fly_target
	self.m_fly_reward_types = self.m_params.extra.fly_reward_types or __DEFAULT_FLY_REWARD_TYPES
	self.m_target_control = self.m_params.extra.target_control or static_rootControl
end

function M:getTarget()
	if self.m_fly_target and self.m_target_control.m_view then
		return self.m_target_control.m_view:findGameObject(self.m_fly_target)
	end
	local bag_img = static_rootControl.m_view:findGameObject("bag_btn")
	return bag_img
end

return M
