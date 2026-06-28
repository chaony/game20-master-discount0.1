local M = class("HeroSelectPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_param = self.m_params.param -- 回调参数
	self.m_filter_func = self.m_params.filter_func -- 筛选函数
	self.m_callfunc = self.m_params.callback -- 回调
	local heroIds = table.copy(UserDataManager.hero_data:getHerosId())
	if self.m_filter_func then
		heroIds = self.m_filter_func(heroIds)
	end
	self.m_heros = heroIds
	self.m_show_heros = table.copy(heroIds)
	self.m_select = heroIds[1]
end

function M:getHeroDataByIndex(index)
	return self.m_show_heros[index]
end

function M:setSelectHero(oid)
	self.m_select = oid
end

function M:setMartial(data)
	self.m_race = data
	if data == 1 then
		self.m_show_heros = table.copy(self.m_heros)
	else
		local list = {}
		for i,v in ipairs(self.m_heros) do
			local hero_data,hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
			if hero_cfg.race == data - 1 then
				table.insert(list, v)
			end
		end
		self.m_show_heros = list
	end
end

return M
