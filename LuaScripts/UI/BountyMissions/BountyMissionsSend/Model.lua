local M = class("BountyMissionsSendModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"
	self.self_hero = self.m_params.self_hero
	self.m_master_uid = self.m_params.uid
	self.master_hero = self.m_params.master_hero
	self.m_reward = self.m_params.reward
	local quest_main = ConfigManager:getCfgByName("bounty_quest")
	self.m_task_id = self.m_params.id
	self.m_task = quest_main[self.m_task_id]
	self.m_type = self.m_task.type --1 单人悬赏 3 师徒悬赏
	self.master_ids = {}
	self.select_send_index =  0
	for k,v in pairs(self.master_hero) do
		table.insert(self.master_ids, v.oid)
	end
	self:getData()
end
--派遣的英雄列表 
local SEND_SLOT_TAB = {}

function M:onEnter()
	SEND_SLOT_TAB = {}
	self.hero_list = self:getAllHero()
end

function M:getSlot()
	return SEND_SLOT_TAB
end

--筛选出已上阵的英雄
function M:getAllHero()
	local heros = table.copy(UserDataManager.hero_data:getHerosId())
	local i, m = 1, #heros
	while i <= m do
		local c_d = heros[i]
		if self:checkIsSelfHero(c_d) then
			table.remove(heros, i)
			i = i -1
			m = m -1
		end
		i = i +1
	end	
	return heros
end

function M:checkIsSelfHero(id)
	for k,v in pairs(self.self_hero) do
		if id == v then
			return true
		end
	end
	return false
end

--根据种族筛选英雄
function M:getHeroByRace(race)
	if self.m_type == 1 or self.select_send_index == 1 then
		self:getMyHeroByRace(race)
	else	
		self:getMasterHeroByRace(race)
	end
end

function M:getMyHeroByRace(race)
	if race == 0 then
		self.Filtrate_list = {}
		self.Filtrate_list = clone(self.hero_list)
		return
	end
	local heros = {}
	for k,v in pairs(self.hero_list) do
		local l_hero_data, l_hero_cfg = self:getHero(v)
		if race == 0 or race == l_hero_cfg.race then
			table.insert(heros, v)
		end
	end
	self.Filtrate_list = {}
	self.Filtrate_list = clone(heros)
	UserDataManager.hero_data:heroIdsSort(self.Filtrate_list,"default")
end

function M:getMasterHeroByRace(race)
	if race == 0 then
		self.Filtrate_list = {}
		self.Filtrate_list = clone(self.master_ids)
		return
	end
	local heros = {}
	for k,v in pairs(self.master_ids) do
		local l_hero_data, l_hero_cfg = self:getMasterHero(v)
		if race == 0 or race == l_hero_cfg.race then
			table.insert(heros, v)
		end
	end
	self.Filtrate_list = {}
	self.Filtrate_list = clone(heros)
end

function M:getShowHeroById(id)
	if self.m_type == 1 or self.select_send_index == 1  then
		return self:getHero(id)
	else	
		return self:getMasterHero(id)
	end
end

--根据id获得英雄数据
function M:getHero(id)
	return UserDataManager.hero_data:getHeroDataById(id)
end

function M:getMasterHero(id)
	for k,v in pairs(self.master_hero) do
		if v.oid == id then
			local data = v
			local cfg = self:getHeroCfg(data.id)
			return data, cfg
		end
	end
end

--根据id获得英雄本地数据
function M:getHeroCfg(id)
	return UserDataManager.hero_data:getHeroConfigByCid(id)
end

--需要的种族
function M:getNeedRace()
	return self.m_task.race_condition
end

function M:getSendSlot()
	return SEND_SLOT_TAB
end

--向槽位中添加一个英雄
function M:addHeroInSendSlot(id)
	if self.m_type ~= 1 then
		if self.select_send_index == 2 then
			SEND_SLOT_TAB[2] = id
		else
			SEND_SLOT_TAB[1] = id
		end
	else	
		for i = 1 , #self.m_task.race_condition do
			if SEND_SLOT_TAB[i] == nil then
				SEND_SLOT_TAB[i] = id
				break
			end
		end
	end
end

--从槽位中移除一个英雄
function M:removeHeroInSendSlot(id)
	local index = 1
	for k,v in pairs(SEND_SLOT_TAB) do
		if v == id then
			index = k
		end
	end
	table.remove(SEND_SLOT_TAB,index)
end

--检查该英雄是否在列表中
function M:isInSlot(id)
	for k,v in pairs(SEND_SLOT_TAB) do
		if id == v then
			return true
		end
	end
	return false
end

--检查某个槽位是不是有英雄
function M:isHaveHero(index)
	if SEND_SLOT_TAB[index] == nil then
		return false
	else
		return true
	end
end

function M:removeByIndex(index)
	if SEND_SLOT_TAB[index] ~= nil then
		SEND_SLOT_TAB[index] = nil
		--table.remove(SEND_SLOT_TAB,index)
	end
end

function M:getHeroByIndex(index)
	if SEND_SLOT_TAB[index] ~=nil then
		if self.m_type ~= 1 and index == 2 then
			return self:getMasterHero(SEND_SLOT_TAB[index])
		else
			return self:getHero(SEND_SLOT_TAB[index])	
		end
		
	end
	return nil
end

--是否有空位
function M:isHaveNull()
	if #SEND_SLOT_TAB >= #self.m_task.race_condition then
		for i = 1, #SEND_SLOT_TAB do
			if SEND_SLOT_TAB[i] == nil then
				return true
			end
		end
		return false
	else
		return true
	end
end

--品质要求
function M:getNeedEvo()
	return self.m_task.evo_condition[1]
end

--需要对应品质英雄的数量
function M:getNeedEvoNum()
	return self.m_task.evo_condition[2]
end

--当前对应品质的数量
function M:getCurEvoNum()
	local num = 0
	for k,v in pairs(SEND_SLOT_TAB) do
		if self.m_type ~= 1 and k == 2 then
			local data,cfg = self:getMasterHero(v)
			if data.evo >= self:getNeedEvo() then
				num = num +1
			end
		else
			local data,cfg = self:getHero(v)
			if data.evo >= self:getNeedEvo() then
				num = num +1
			end	
		end
	end
	return num
end

--数量条件是否完成
function M:checkNumCondition()
	return self:getCurEvoNum() >= self:getNeedEvoNum()
end

--一键上阵
function M:quckSend()
	local need_evo = self:getNeedEvo()
	local need_evo_num = self:getNeedEvoNum()
	if table.nums(SEND_SLOT_TAB) >= #self.m_task.race_condition then
		return
	end
	SEND_SLOT_TAB = {}
	if self.m_type == 3 then
		for k,v in pairs(self.m_task.race_condition) do
			local need_race = v
			self.select_send_index = k
			if k == 1 then
				self:getMyHeroByRace(need_race)
				for kk,vv in pairs(self.Filtrate_list) do
					if need_evo_num > 0 then
						local data, cfg = self:getHero(vv)
						if data.evo >= need_evo and self:isInSlot(vv) == false then
							need_evo_num = need_evo_num - 1
							self:addHeroInSendSlot(vv) 
							break
						end
					else
						if self:isInSlot(vv) == false then
							self:addHeroInSendSlot(vv)
							break
						end
					end
				end
			elseif k ==2 then	
				self:getMasterHeroByRace(need_race)
				for kk,vv in pairs(self.Filtrate_list) do
					if need_evo_num > 0 then
						local data, cfg = self:getMasterHero(vv)
						if data.evo >= need_evo and self:isInSlot(vv) == false then
							need_evo_num = need_evo_num - 1
							self:addHeroInSendSlot(vv) 
							break
						end
					else
						if self:isInSlot(vv) == false then
							self:addHeroInSendSlot(vv)
							break
						end
					end
				end
			end
		end	
	else	
		for k,v in pairs(self.m_task.race_condition) do
			local need_race = v
			self:getHeroByRace(need_race)
			for kk,vv in pairs(self.Filtrate_list) do
				if need_evo_num > 0 then
					local data, cfg = self:getHero(vv)
					if data.evo >= need_evo and self:isInSlot(vv) == false then
						need_evo_num = need_evo_num - 1
						self:addHeroInSendSlot(vv) 
						break
					end
				else
					if self:isInSlot(vv) == false then
						self:addHeroInSendSlot(vv)
						break
					end
				end
			end
		end
	end
end

		
--格子数量
function M:getHeroGrideNum()
    local num = 100 + UserDataManager.extra_hero_grid
    return num
end

function M:getHeroBigAnim(o_id)
	local data,cfg = self:getShowHeroById(o_id)
	if cfg then
		return cfg.hero_spine
	else
		return "hero_0003_SkeletonData"	
	end
end

function M:getSpinePos(o_id)
	local data,cfg = self:getShowHeroById(o_id)
	local id = data.id
	local hero_tab = ConfigManager:getCfgByName("hero_detail")
	local data_pos = hero_tab[id]["spine_position"]
	return data_pos
end

return M
