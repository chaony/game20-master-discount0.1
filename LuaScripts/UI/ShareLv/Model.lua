local M = class("ShareLvPopModel", LikeOO.OODataBase)
M.SORTTYPE = {EVO = 1, RACE = 2}
function M:onCreate()
	M.super.onCreate(self)
	self:getData("hero_crystal_index")
end

function M:onEnter()
	self.m_client_lv_up = false --是否有过纯前端升级
	self.m_open_lv = ConfigManager:getCommonValueById(372, 300)
	self.m_up_lv = false
	self.sort_type = self.SORTTYPE.EVO
	self.temp_user_data = table.copy(UserDataManager.user_data) --纯前端升级使用
	self:setData(self.m_data)
end

function M:setData(data)
	self.m_data = data
	self.m_client_lv_up = false
	if self.m_data.clv and self.m_data.clv >= self.m_open_lv then
		self.m_up_lv = true
	else
		self.m_up_lv = false
	end
	UserDataManager.m_clv = self.m_data.clv--刷新数据
	UserDataManager.m_clv_limit = self.m_data.clv_limit
	self.m_unlock = 0 -- 未达到解锁要求
	if self.m_data.clv_unlock then
		if #self.m_data.level_top == 0 then
			self.m_unlock = 2 -- 已解锁
		else
			self.m_unlock = 1 -- 可解锁
		end
	end
	self.temp_user_data = table.copy(UserDataManager.user_data) 
	self:updateCrystalSlot()
	self:sortCrystalSlot()
	self:initTopHero()
end

function M:getCombat()
	local combat = 0
	for k,v in ipairs(self.m_data.crystal_slot) do
		if v.hid ~= "" then
			local data, cfg = UserDataManager.hero_data:getHeroDataById(v.hid)
			combat = combat + data.combat
		end
	end
	return combat
end

---前端升级------------------------------------------------------
function M:lvUp()
	self.m_data.clv = self.m_data.clv + 1 
	self.m_client_lv_up = true
	if self.m_data.clv and self.m_data.clv >= self.m_open_lv then
		self.m_up_lv = true
	else
		self.m_up_lv = false
	end
	self.m_unlock = 0 -- 未达到解锁要求
	if self.m_data.clv_unlock then
		if #self.m_data.level_top == 0 then
			self.m_unlock = 2 -- 已解锁
		else
			self.m_unlock = 1 -- 可解锁
		end
	end
	--前端扣除资源
	local crystal_upgrade = ConfigManager:getCfgByName("crystal_upgrade")
	local crystal = crystal_upgrade[self.m_data.clv-1] --上一级需要的资源
	local coin = self.temp_user_data:getUserStatusDataByKey("coin")
	if coin >= crystal.coin then
		coin = coin - crystal.coin
		self.temp_user_data.user_status["coin"] = coin
	end
	local hero_exp = self.temp_user_data:getUserStatusDataByKey("hero_exp")
	if hero_exp >= crystal.exp then
		hero_exp = hero_exp - crystal.exp
		self.temp_user_data.user_status["hero_exp"] = hero_exp
	end
	local dust = self.temp_user_data:getUserStatusDataByKey("dust")
	if dust >= crystal.special_num then
		dust = dust - crystal.special_num
		self.temp_user_data.user_status["dust"] = dust
	end
end

function M:checkCelCanLvUp()
	local crystal_upgrade = ConfigManager:getCfgByName("crystal_upgrade")
	local cry_cfg = crystal_upgrade[self.m_data.clv]
	if cry_cfg == nil then
		return false
	end
	if self.m_data.clv_limit > 0 and self.m_data.clv > 0 and cry_cfg.display_level >= self.m_data.clv_limit then --到达上限
		return false,2
	end
	local coin = self.temp_user_data:getUserStatusDataByKey("coin")
	if coin < cry_cfg.coin then
		return false,1
	end
	local hero_exp = self.temp_user_data:getUserStatusDataByKey("hero_exp")
	if hero_exp < cry_cfg.exp then
		return false,1
	end
	local dust = self.temp_user_data:getUserStatusDataByKey("dust")
	if dust < cry_cfg.special_num then
		return false,1
	end
	return true
end

---------------------------------------------------------

function M:getSoltDataByIndex(index)
	return self.m_crystal_slot[index]
end

function M:setSoltData(data)
	for k,v in pairs(data.slot) do
		self.m_data.crystal_slot[tonumber(k)] = v
	end
	self:updateCrystalSlot()
	self:sortCrystalSlot()
	self:initTopHero()
end

function M:getClearTimeCost(index)
	local system_cost = ConfigManager:getCfgByName("system_cost")[4].cost
	local data = self:getSoltDataByIndex(index)
	local time = data.etime - UserDataManager:getServerTime()
	-- if time > 0 then
	-- 	return math.ceil(system_cost[1][3]*time/(12*3600))
	-- end
	return system_cost[1][3]
end

function M:isHaveSameHero(oid)
	local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	for i,v in ipairs(self.m_data.level_top) do
		local data2 = UserDataManager.hero_data:getHeroDataById(v[1])
		if data.id == data2.id then
			return true, cfg.name
		end
	end

	for k,v in pairs(self.m_data.crystal_slot) do
		if v.hid ~= "" then
			local data2 = UserDataManager.hero_data:getHeroDataById(v.hid)
			if data.id == data2.id then
				return true, cfg.name
			end
		end
	end
end

function M:getMinLvHero()
	local lv = self.m_open_lv
	local hero = nil
	for k,v in pairs(self.m_data.level_top or {}) do
		local data, cfg = UserDataManager.hero_data:getHeroDataById(v[1])
		if data ~= nil then
			if hero == nil then
				hero = data
			end
			if lv > data.lv then
				lv = data.lv
				hero = data
			end
		end
	end
	return hero
end

function M:initTopHero()
	local heros = {}
	if self.m_unlock == 2 then
		--for i,v in ipairs(self.m_crystal_slot) do
		--	heros[#heros + 1] = v.hid
		--	if #heros == 5 then
		--		break
		--	end
		--end
	else
		for i,v in ipairs(self.m_data.level_top) do
			heros[i] = v[1]
		end
	end
	self.m_show_hero = heros
end

function M:updateCrystalSlot()
	self.m_crystal_slot = {}
	for i,v in ipairs(self.m_data.crystal_slot) do
		local slot = table.copy(v)
		slot.id = i
		self.m_crystal_slot[i] = slot
	end
	
	local num = #self.m_crystal_slot + 2
	if num % 4 > 0 then
		num = num + (4 - num % 4)
	end
	num = math.min(num, self.m_data.max_slot_num)
	num = math.max(num, 12)
	self.m_list = {}
	for i=1,num do
		self.m_list[i] = 1
	end
end

function M:sortCrystalSlot(sort_type)
	self.sort_type = sort_type or self.sort_type
	local function sortFunc(d1,d2)
		if d1.hid ~= "" then
			if d2.hid ~= "" then
				local data1, cfg1 = UserDataManager.hero_data:getHeroDataById(d1.hid)
				local data2, cfg2 = UserDataManager.hero_data:getHeroDataById(d2.hid)
				if self.sort_type == self.SORTTYPE.EVO then
					return data1.evo > data2.evo
				elseif self.sort_type == self.SORTTYPE.RACE then
					return cfg1.race > cfg2.race
				end
			else
				return true	
			end
		else
			if d2.hid ~= "" then
				return false
			else
				return d1.etime > d2.etime
			end
		end
	end
	table.sort(self.m_crystal_slot, sortFunc)
end

function M:getIndexByOid(oid)
	for k,v in pairs(self.m_crystal_slot) do
		if oid == v.hid then
			return k
		end
	end
	return -1
end

--是否展示练武场排行榜
function M:showRank()
	local crystal_upgrade = ConfigManager:getCfgByName("crystal_upgrade")
	local crystal = crystal_upgrade[self.m_data.clv]
	if crystal and crystal.display_level >= 500 then
		return true
	end
	return false
end

return M