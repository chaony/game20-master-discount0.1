local M = class("CommonExclusivePopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_title = self.m_params.title
	self.m_tab_index = 1
end

function M:setTab(index)
	self.m_tab_index = index
end

function M:getHeros()
	local ids = RedPointUtil:checkExclusiveWeaponLvUp()
	UserDataManager.hero_data:heroIdsSort(ids, "lv")
	return ids
end

function M:getHero(id)
	return UserDataManager.hero_data:getHeroDataById(id)
end

return M
