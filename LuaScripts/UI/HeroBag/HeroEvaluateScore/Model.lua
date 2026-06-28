local M = class("HeroEvaluateScoreModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

M.dataTime = 22

function M:onEnter()

	self.m_num = 0
end

function M:setTabIndex(index)
	self.m_tab_index = index
	--self:updateList()
end




return M
