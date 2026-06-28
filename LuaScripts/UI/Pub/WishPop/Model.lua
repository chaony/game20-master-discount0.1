local M = class("WishPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("gacha_wish_list_index")
end

function M:onEnter()
	self.m_cards = UserDataManager.hero_data:getHeroCfgMakeRace()
	for i,v in ipairs(self.m_cards) do
		for i=#v,1, -1 do
			local cfg = v[i]
			if cfg.is_visible ~= 1 then
				table.remove(v,i)
			end
		end
	end
	self.m_wish_hero = self.m_data.hero_wish_list
	self.m_martialTable = {"1","3","2","4"}
	self.m_martial = "1"
	self.m_list = {}
	self:initList()
end

function M:initList()
	for k,v in ipairs(self.m_martialTable) do
		if self.m_list[v] == nil then
			self.m_list[v] = {}
		end
		local index = (tonumber(v) - 1)*5 + 1
		for i=1,5 do
			local cid = self.m_wish_hero[index]
			local cfg = UserDataManager.hero_data:getHeroConfigByCid(cid)
			if cfg and cfg.race == tonumber(v) and cfg.is_visible == 1 then
				self.m_list[v][i] = cid
			else
				self.m_list[v][i] = 0
			end
			index = index + 1
		end
	end
	Logger.log(self.m_list,"m_list ====")
end

function M:getCardsbyIndex(index)
	local martial = self.m_martialTable[index]
	return martial, self.m_list[martial]
end

function M:setMartial(index)
	self.m_martial = self.m_martialTable[index]
end

function M:getCardsCfgByMartial(martial)
	if martial == nil then return {} end
	return self.m_cards[tonumber(martial)] or {}
end

function M:getCardsCfg()
	return self:getCardsCfgByMartial(self.m_martial)
end

function M:cardSelectChange(sid)
	local index = 0
	for i=1,5 do
		if index == 0 and self.m_list[self.m_martial][i] == 0 then
			index = i
		elseif self.m_list[self.m_martial][i] == sid then
			self.m_list[self.m_martial][i] = 0
			return true
		end
	end
	if index > 0 then
		self.m_list[self.m_martial][index] = sid
		return true
	end
	return false
end

function M:isSelected(sid)
	for i=1,5 do
		if self.m_list[self.m_martial][i] == sid then
			return true
		end
	end
	return false
end

function M:getNewWishHero()
	local heros = {}
	for i,v in ipairs(self.m_martialTable) do
		local index = (tonumber(v) - 1)*5 + 1
		for ii,vv in ipairs(self.m_list[v]) do
			heros[index] = vv
			index = index + 1
		end
	end
	-- for i =16, 20 do  -- 去掉水后加的
	-- 	heros[i] = 0
	-- end
	return heros
end

function M:isFull()
	for i,v in ipairs(self.m_martialTable) do
		for ii,vv in ipairs(self.m_list[v]) do
			if vv <= 0 then
				return false
			end
		end
	end
	return true
end

return M
