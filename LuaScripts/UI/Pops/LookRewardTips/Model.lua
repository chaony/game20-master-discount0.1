local M = class("LookRewardTipsModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_rewards = self.m_params.rewards or {}
	self.m_callback = self.m_params.callback
	self.m_delay = self.m_params.delay
	self.m_click_transform = self.m_params.click_transform
	self.m_show_check_mark = self.m_params.show_check_mark
	self.m_look_model = self.m_params.look_model or 0
	self.m_offset_y = self.m_params.offset_y or 0
	self.m_tips = self.m_params.tips
	self.m_scale = self.m_params.scale or 1
end

return M
