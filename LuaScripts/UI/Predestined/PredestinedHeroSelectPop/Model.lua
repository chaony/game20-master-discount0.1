local M = class("PredestinedHeroSelectPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_index = 1
	self.m_martial = {1,2,3,4,5,6,7}
	self.m_gacha_id_tab = {7,7,7,7,9,9,10}
	self.m_arm_hero = self.m_params.arm_hero
	self.guarantee_times = self.m_params.times-- or 100
	--是否是SP
	self.m_is_sp = self.m_params.is_sp
	--if self.m_is_sp then
	--	self:initHeroListForSP()
	--else
	--	self:initHeroList()
	--end
	self:initHeroListNew(1)
	self:updateGachaId()
	if self.m_arm_hero == nil or self.m_arm_hero <= 0 then
		self.m_arm_hero = self.m_heros[1]
	end
end

function M:setHero(id)
	self.m_arm_hero = id
	self:updateGachaId()
end

function M:updateGachaId()
	if self.m_is_sp then
		self.m_gacha_id = GlobalConfig.GACHA_SP_ID
	else
		if self.m_arm_hero and self.m_arm_hero > 0 then
			local cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_arm_hero)
			if cfg.is_sp == 0 then
				self.m_gacha_id = self.m_gacha_id_tab[cfg.race]
			else
				self.m_gacha_id = GlobalConfig.GACHA_YUAN_ID
			end
		end
	end
	self:setTimes()
end

function M:setTimes()
	if self.m_gacha_id then
		local index = 1
		if self.m_gacha_id == 7 then
			index = 1
		elseif self.m_gacha_id == 9 then
			index = 2
		elseif self.m_gacha_id == 10 then	
			index = 3
		elseif self.m_gacha_id == GlobalConfig.GACHA_SP_ID then
			index = 4
		end
		local total_times = ConfigManager:getCommonValueById(357, { 100,100,120,70 })[index]
		self.m_times = total_times - self.guarantee_times[tostring(self.m_gacha_id)]
	else
		self.m_times = 100
	end
end

function M:isInTime(high_gacha_time)
	local is_in = false
	local gacha_time_tab = string.split(high_gacha_time,"~")
	local start_time = gacha_time_tab[1] or ""
	local end_time = gacha_time_tab[2] or ""
	if start_time ~= "" and end_time ~= "" then
		local start_ts = type(start_time) == "number" and start_time or GameUtil:stringToTimesTamp(start_time)
		local end_ts = type(end_time) == "number" and end_time or GameUtil:stringToTimesTamp(end_time)
		local cur_time = UserDataManager:getServerTime()
		if cur_time >= start_ts and cur_time < end_ts then
			is_in = true
		end
	end
	return is_in
end

function M:initHeroList()
	local heros = {}
	local heros_data = UserDataManager.hero_data.hero_collect
	local martial = nil
	if self.m_index > 1 then
		martial = self.m_martial[self.m_index -1]
	end
	for k,v in pairs(heros_data) do
		local cfg = UserDataManager.hero_data:getHeroConfigByCid(tonumber(k))
		if cfg and cfg.evo > 4 and cfg.is_sp == 0 then
			local is_in_time = true
			if cfg.high_gacha_time and cfg.high_gacha_time ~= "" then
				is_in_time = self:isInTime(cfg.high_gacha_time)
			end
			if is_in_time then
				if martial then
					if martial == cfg.race then
						heros[#heros + 1] = tonumber(k)
					end
				else
					heros[#heros + 1] = tonumber(k)
				end
			end
		end
	end
	
	local race_sort = {3,4,5,6,7,1,2} -- 阴阳放到前面
	local function sortFunc(d1,d2)
		local cfg1 = UserDataManager.hero_data:getHeroConfigByCid(d1)
		local cfg2 = UserDataManager.hero_data:getHeroConfigByCid(d2)
		local race_sort1 = race_sort[cfg1.race]
		local race_sort2 = race_sort[cfg2.race]
		if race_sort1 == race_sort2 then
			if cfg1.Ex_hero == cfg2.Ex_hero then
				return cfg1.id < cfg2.id
			end
			return cfg1.Ex_hero > cfg2.Ex_hero
		else
			return race_sort1 < race_sort2
		end
	end
	table.sort(heros, sortFunc)
	self.m_heros = heros
end

function M:setMartial(index)
	self.m_index = index
	self:initHeroListNew(self.m_index)
end

-- SP侠客列表，所有sp卡不论获得与否，都可抽
function M:initHeroListForSP()
	local heroes = {}
	local all_hero_cfg = ConfigManager:getCfgByName("hero_detail")
	for k,v in pairs(all_hero_cfg) do
		if v.evo > 4 and v.is_sp == 1 then
			heroes[#heroes + 1] = tonumber(k)
		end
	end

--[[
	local heroes_data = UserDataManager.hero_data.hero_collect
	for k,v in pairs(heroes_data) do
		local cfg = UserDataManager.hero_data:getHeroConfigByCid(tonumber(k))
		if cfg and cfg.evo > 4 and cfg.is_sp == 1 then
			local is_in_time = true
			if cfg.high_gacha_time and cfg.high_gacha_time ~= "" then
				is_in_time = self:isInTime(cfg.high_gacha_time)
			end
			if is_in_time then
				heroes[#heroes + 1] = tonumber(k)
			end
		end
	end
	]]--

	local function sortFunc(d1,d2)
		local cfg1 = UserDataManager.hero_data:getHeroConfigByCid(d1)
		local cfg2 = UserDataManager.hero_data:getHeroConfigByCid(d2)
		if cfg1.Ex_hero == cfg2.Ex_hero then
			return cfg1.id < cfg2.id
		end
		return cfg1.Ex_hero > cfg2.Ex_hero
	end
	table.sort(heroes, sortFunc)

	self.m_heros = heroes
end

--根据配置的时间设置侠客
function M:initHeroListNew(index)
	local heroes = {}
	local all_cfg = ConfigManager:getCfgByName("high_gacha_aim")
	local cur_time = UserDataManager:getServerTime()

	local insertFunc=function(value)
		local ret=table.indexof(heroes,value)
		if ret==false then
			heroes[#heroes + 1] = value
		end
	end

	for k,v in pairs(all_cfg) do
		local start_time = v.start_time
		local end_time = v.end_time
		if cur_time >= start_time and cur_time < end_time then
			if index == 1 then
				for k,v in pairs(v.aim_heroes) do
					--heroes[#heroes + 1] = v
					insertFunc(v)
				end
			else
				for k,v in pairs(v.aim_heroes) do
					local cfg = UserDataManager.hero_data:getHeroConfigByCid(v)
					if self.m_martial[index - 1] == cfg.race then
						--heroes[#heroes + 1] = v
						insertFunc(v)
					end
				end
			end
		end
	end
	self.m_heros = heroes
end

return M