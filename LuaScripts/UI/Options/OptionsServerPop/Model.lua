local M = class("OptionsHeadPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_tab = 1
	self.m_head_index = 1
	self.m_border_index = 1
	self.m_recommend = {1,2,3,4}
	self.m_team = {1,2,3,4,5,6,7,8}
	self.m_server = {1,2,3,4,5,6,7,8,9,10}
end

function M:setTab(index)
	self.m_tab = index
end

function M:setHeadSelect(index)
	self.m_head_index = index
end

function M:setBorderSelect(index)
	self.m_border_index = index
end

return M
