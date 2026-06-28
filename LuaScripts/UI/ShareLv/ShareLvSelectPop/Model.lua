local M = class("ShareLvSelectPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_race = 1
	self.m_pos = self.m_params.slot_id
	self.m_callfunc = self.m_params.callback
	local heroIds = UserDataManager.hero_data:getHerosId()
	local heros = {}
	for i,v in ipairs(heroIds) do
		local data, cfg = UserDataManager.hero_data:getHeroDataById(v)
		if self:isLevelTop(v) == false and data.clv == 0 then
			heros[#heros + 1] = v
		end
	end
	self.m_heros = heros
	self.m_show_heros = table.copy(heros)
	self.m_select = heros[1]
end

function M:isLevelTop(oid)
	for i,v in ipairs(self.m_params.level_top) do
		if v[1] == oid then
			return true
		end
	end
	return false
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
