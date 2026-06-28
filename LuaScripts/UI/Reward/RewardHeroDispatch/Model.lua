local M = class("RewardHeroDispatchModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("auto_view")
end
--派遣的英雄列表 
local SEND_SLOT_TAB = {}

function M:onEnter()
	SEND_SLOT_TAB = {}
	self.self_hero = self.m_params.self_hero
	self.single_data = self.m_params.single_data
	self.m_master_uid = self.m_params.uid
	self.master_hero = self.m_params.master_hero
	self.master_hero = self.m_params.master_hero
	self.master_ids = {}
	for k,v in pairs(self.master_hero) do
		table.insert(self.master_ids, v.oid)
	end
	self.hero_list = self:getAllHero()
	self:initData()
end

function M:initData(data)
	if data then
		self.m_data = data
	end
	self.m_view_data = self.m_data.view_data or {}
	self.m_quest_list = {}
	self.m_quest_state = {}
	for k,v in pairs(self.m_view_data) do
		table.insert( self.m_quest_list, v.quest_id)
	end
	for i,v in ipairs(self.m_quest_list) do
		table.insert( self.m_quest_state, {id = v, state = true} )
	end
end

function M:checkQuestState(quest_id)
	for k,v in pairs(self.m_quest_state) do
		if quest_id == v.id then
			return v.state == true
		end
	end
	return false
end

function M:getToNetData()
	local quest = {}
	for k,v in pairs(self.m_quest_state) do
		if v.state == true then
			local quest_data = self:getQuestData(k)
			quest[tostring(v.id)] = quest_data
		end
	end
	return quest
end

function M:selectTaskItem(id)
	for k,v in pairs(self.m_quest_state) do
		if v.id == id then
			if v.state == true then
				v.state = false
			else
				v.state = true	
			end
		end
	end
end

function M:getQuestData(index)
	local self_hero = {}
    local team_hero = {}
	local master_hero = {}
	local quest = {}
	local quest_data = self.m_quest_state[index]
	if quest_data.state == true then
		local data = self:getBountyData(quest_data.id)
		for k,v in pairs(data.self_hero) do
			table.insert( self_hero, v)
		end
		for k,v in pairs(data.team_hero) do
			team_hero[tostring(k)] = v
		end
		for k,v in pairs(data.master_hero) do
			table.insert( master_hero, v)
		end
	else 
		return nil	
	end
	return {self_hero = self_hero, team_hero = team_hero, master_hero = master_hero }
end


function M:getSlot()
	return SEND_SLOT_TAB
end

function M:switchHeroList(race,is_Mercenary)
	local hero_list = self:filtrateHero(race,is_Mercenary,is_Mercenary)
	return hero_list
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
	local data = self.self_hero
	for k,v in pairs(data) do
		if id == v then
			return true
		end
	end
	return false
end

--根据种族筛选英雄
function M:getHeroByRace(race,m_type)
	if m_type == 1 or self.select_send_index == 1 then
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
		if l_hero_cfg ~= nil then
			if race == 0 or race == l_hero_cfg.race then
				table.insert(heros, v)
			end
		end
		
	end
	self.Filtrate_list = {}
	self.Filtrate_list = clone(heros)
	UserDataManager.hero_data:heroIdsSort(self.Filtrate_list,"default")
end

--过滤后的英雄列表
function M:filtrateHero(race_id,is_Mercenary)
	local hero_list = self:getAllHero()
	if race_id == 0 then
		return hero_list
	end
	local heros = {}
	for k,v in pairs(hero_list) do
		local l_hero_data, l_hero_cfg = self:getHero(v)
		if race_id == l_hero_cfg.race then
			table.insert(heros, v)
		end
	end
	UserDataManager.hero_data:heroIdsSort(heros, "lv")
	return heros
end

function M:getHeros(RACE_LIST)
	local data = {}
		for k,v in pairs(self.hero_list) do
			-- for k1,v1 in pairs(RACE_LIST) do
			-- 	local l_hero_data, l_hero_cfg = self:getHero(v)
			-- 	if l_hero_cfg ~= nil then
			-- 		if v1.race == l_hero_cfg.race then
						table.insert(data, v)
			-- 			break
			-- 		end
			-- 	end
			-- end
			end
	-- else 
	-- 	for k,v in pairs(self.master_ids) do
	-- 		-- for k1,v1 in pairs(RACE_LIST) do
	-- 		-- 	local l_hero_data, l_hero_cfg = self:getHero(v)
	-- 		-- 	if l_hero_cfg ~= nil then
	-- 		-- 		if v1.race == l_hero_cfg.race then
	-- 					table.insert(data, v)
	-- 		-- 			break
	-- 		-- 		end
	-- 		-- 	end
	-- 		-- end
	-- 	end
		
	-- end
	return data
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
function M:addHeroInSendSlot(id,m_task)
	if self.m_type ~= 1 then
		if self.select_send_index == 2 then
			SEND_SLOT_TAB[2] = id
		else
			SEND_SLOT_TAB[1] = id
		end
	else	
		local cur_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(self:getHero(id).id)
		for i = 1 , #m_task.race_condition do
			if cur_hero_cfg.race == m_task.race_condition[i]  then
				if SEND_SLOT_TAB[i] == nil then
					SEND_SLOT_TAB[i] = id
					return true
				end
			end
		end
		return false
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
	SEND_SLOT_TAB[index] = nil
	--table.remove(SEND_SLOT_TAB,index)
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
function M:getNeedEvo(m_task)
	return m_task.evo_condition[1]
end

--需要对应品质英雄的数量
function M:getNeedEvoNum(m_task)
	return m_task.evo_condition[2]
end

--当前对应品质的数量
function M:getCurEvoNum(m_task)
	local num = 0
	for k,v in pairs(SEND_SLOT_TAB) do
		if m_task.type ~= 1 and k == 2 then
			local data,cfg = self:getMasterHero(v)
			if data.evo >= self:getNeedEvo(m_task) then
				num = num +1
			end
		else
			local data,cfg = self:getHero(v)
			if data.evo >= self:getNeedEvo(m_task) then
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
function M:quckSend(need_evo,need_evo_num,m_task)
	local need_evo = need_evo --self:getNeedEvo()
	local need_evo_num =  need_evo_num --self:getNeedEvoNum()
	local m_type = m_task.type
	if table.nums(SEND_SLOT_TAB) >= #m_task.race_condition then
		return
	end
	SEND_SLOT_TAB = {}
	if m_type == 3 then
		for k,v in pairs(m_task.race_condition) do
			local need_race = v
			self.select_send_index = k
			if k == 1 then
				self:getMyHeroByRace(need_race)
				for kk,vv in pairs(self.Filtrate_list) do
					if need_evo_num > 0 then
						local data, cfg = self:getHero(vv)
						if data.evo >= need_evo and self:isInSlot(vv) == false then
							need_evo_num = need_evo_num - 1
							self:addHeroInSendSlot(vv,m_task) 
							break
						end
					else
						if self:isInSlot(vv) == false then
							self:addHeroInSendSlot(vv,m_task)
							break
						end
					end
				end
			elseif k ==2 then	
				self:getMasterHeroByRace(need_race,m_type)
				for kk,vv in pairs(self.Filtrate_list) do
					if need_evo_num > 0 then
						local data, cfg = self:getMasterHero(vv)
						if data.evo >= need_evo and self:isInSlot(vv) == false then
							need_evo_num = need_evo_num - 1
							self:addHeroInSendSlot(vv,m_task) 
							break
						end
					else
						if self:isInSlot(vv) == false then
							self:addHeroInSendSlot(vv,m_task)
							break
						end
					end
				end
			end
		end	
	else	
		for k,v in pairs(m_task.race_condition) do
			local need_race = v
			self:getHeroByRace(need_race,m_type)
			for kk,vv in pairs(self.Filtrate_list) do
				if need_evo_num > 0 then
					local data, cfg = self:getHero(vv)
					if data.evo >= need_evo and self:isInSlot(vv) == false then
						need_evo_num = need_evo_num - 1
						self:addHeroInSendSlot(vv,m_task) 
						break
					end
				else
					if self:isInSlot(vv) == false then
						self:addHeroInSendSlot(vv,m_task)
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

function M:getBountyCfg(id)
	local quest_main = ConfigManager:getCfgByName("bounty_quest")
	return quest_main[id]
end

function M:getOtherHero(bounty_id ,id)
	local bounty_data = self:getBountyData(bounty_id)
	for i,v in pairs(bounty_data.heros) do
		if id == v.oid then
			local cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id)
			return v, cfg
		end
	end
	return nil, nil
end

function M:getBountyData(id)
	for k,v in pairs(self.m_view_data) do
		if id == v.quest_id then
			return v
		end
	end
end

return M
