local M = class("HelpDagLevelModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_callback = self.m_params.callback
	self.stage_id = self.m_params.stage_id or 1
	self.level_id = self.m_params.level_id or 1
	self.m_show_result = false
	self.m_guide = self.m_params.guide or 0 --是否是引导 0：不是引导，1：是引导
end





return M
