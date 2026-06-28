local M = class("FormationSetModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_open_tab_index = 1
	self.m_sel_tab_index = 0 --选中页签类型 {1武神，2阵法}
	self.m_sel_her_index = 0 --选中筛选页签类型 {1势力，2定位}
	self.m_hero_list = table.copy(UserDataManager.hero_data:getHerosId())
	self.m_assist_heros = self.m_params.assist_heros or {} -- 助阵英雄
end

--获取英雄筛选类型列表
function M:getTypeList()
	if self.m_sel_her_index == 1 then
		return {0,1,2,3,4} --种族
	else
		return {0,1,2,3,4,5,6} --职业
	end
end

--获取英雄列表
function M:getHeroList()
	return self.m_hero_list
end

--根据id获得英雄数据
function M:getHero(id)
	local hero_data, hero_cfg = nil
	local hero_data = self.m_assist_heros[id]
	if hero_data then
		hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
	else
		hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(id)
	end
	return hero_data, hero_cfg
end

return M
