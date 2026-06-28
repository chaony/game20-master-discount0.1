local M = class("RewardSendModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"
	self.self_hero = self.m_params.self_hero
	self.m_master_uid = self.m_params.uid
	self.index = self.m_params.index
	self.master_hero = self.m_params.master_hero
	self.m_reward = self.m_params.reward
	local quest_main = ConfigManager:getCfgByName("bounty_quest")
	self.m_task_id = self.m_params.id
	self.m_task = quest_main[self.m_task_id]
	self.evo_condition = self.m_params.evo_condition
	self.m_type = self.m_task.type --1 单人悬赏 3 师徒悬赏
	self.master_ids = {}
	self.mercenarys_ids = {}
	self.m_cur_race = 0
	self.select_send_index =  1
	self.selectType_index = 1
	for k,v in pairs(self.master_hero) do
		table.insert(self.master_ids, v.oid)
	end
	if self.m_type == 2 then
		self:getData("get_mercenarys")
	else
		self:getData()
	end
end

--派遣的英雄列表 
local SEND_SLOT_TAB = {}

function M:onEnter()
	SEND_SLOT_TAB = {}
	self.hero_list = self:getAllHero()
	if self.m_type == 2 and self.m_data.mercenarys and next(self.m_data.mercenarys) ~= nil then
		self.mercenarys_hero = self.m_data.mercenarys
		for i,v in pairs(self.m_data.mercenarys) do
			table.insert(self.mercenarys_ids, v.hero_info.oid)
		end
	end
end

function M:getSlot()
	return SEND_SLOT_TAB
end

function M:switchHeroList(race,is_Mercenary)
	self.m_cur_race = race
	local hero_list = {}
	if self.m_type == 1 or self:checkMerceSort() == false then
		hero_list = self:filtrateHero(race,is_Mercenary,is_Mercenary)
	elseif self.m_type == 2 and self:checkMerceSort() == true then
		hero_list = self:filtrateOtherHero(race)
	end
	return hero_list
end

--筛选出已上阵的英雄
function M:getAllHero(is_Mercenary)
	local heros = table.copy(UserDataManager.hero_data:getHerosId())
	local i, m = 1, #heros
	while i <= m do
		local c_d = heros[i]
		if self:checkIsSelfHero(c_d,is_Mercenary) then
			table.remove(heros, i)
			i = i -1
			m = m -1
		end
		i = i +1
	end	
	return heros
end

function M:checkIsSelfHero(id,is_Mercenary)
	local data = self.self_hero
	if is_Mercenary == true then
		data = self.master_ids
	end
	for k,v in pairs(data) do
		if id == v then
			return true
		end
	end
	return false
end

--根据种族筛选英雄
function M:getHeroByRace(race)
	if self.m_type == 1 or self:checkMerceSort() == false then
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

function M:filtrateOtherHero(race_id)
	if race_id == 0 then
		return self.mercenarys_ids
	end
	local hero_list = table.copy(self.mercenarys_ids)
	local heros = {}
	for i,v in pairs(hero_list) do
		local l_hero_data, l_hero_cfg = self:getMercenaryHero(v)
		if race_id == l_hero_cfg.race then
			table.insert(heros, v)
		end
	end
	return heros
end

function M:function_name( )
	
end

function M:getHeros()
	if self.m_cur_race and self.m_cur_race > 0 then
		return self:switchHeroList(self.m_cur_race)
	end
	local data = {}
	for k,v in pairs(self.hero_list) do
		table.insert(data, v)
	end
	if self.m_type == 2 and self:checkMerceSort() == true then
		return self.mercenarys_ids
	elseif self.m_type == 3 and self:checkMerceSort() == true then
		return self.master_ids
	end
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

function M:getMercenarysHeroByRace(race)
	if race == 0 then
		self.Filtrate_list = {}
		self.Filtrate_list = clone(self.master_ids)
		return
	end
	local heros = {}
	for k,v in pairs(self.mercenarys_ids) do
		local l_hero_data, l_hero_cfg = self:getMercenaryHero(v)
		if race == 0 or race == l_hero_cfg.race then
			table.insert(heros, v)
		end
	end
	self.Filtrate_list = {}
	self.Filtrate_list = clone(heros)
end

function M:getShowHeroById(id)
	if self.m_type == 1 or self:checkMerceSort() == false  then
		return self:getHero(id)
	elseif self.m_type == 2 and self:checkMerceSort() == true then
		return self:getMercenaryHero(id)
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

function M:getMercenaryHero(id)
	for k,v in pairs(self.mercenarys_hero) do
		if v.hero_info.oid == id then
			local data = v.hero_info
			local cfg = self:getHeroCfg(data.id)
			return data, cfg
		end
	end
end

function M:getMercenaryUser(id)
	for k,v in pairs(self.mercenarys_hero) do
		if v.hero_info.oid == id then
			return v.user_info
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

function M:checkMerceSort()
	if self.select_send_index == table.nums(self.m_task.race_condition) then
		return true
	else
		return false	
	end
end

function M:getSendSlot()
	return SEND_SLOT_TAB
end

--向槽位中添加一个英雄
function M:addHeroInSendSlot(id)
	if self.m_type ~= 1 then
		local num = table.nums(self.m_task.race_condition)
		if self:checkMerceSort() == true then
			local l_hero_data, l_hero_cfg = self:getMercenaryHero(id)
			if l_hero_cfg.race == self.m_task.race_condition[num] then
				SEND_SLOT_TAB[num] = id
				return true
			end
			return false
		else
			for i = 1 , num-1 do
				if SEND_SLOT_TAB[i] == nil then
					local cur_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(self:getHero(id).id)
					if cur_hero_cfg.race == self.m_task.race_condition[i]  then
						SEND_SLOT_TAB[i] = id
						return true
					end
					return false
				end
			end
		end
	else	
		local cur_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(self:getHero(id).id)
		for i = 1 , #self.m_task.race_condition do
			if cur_hero_cfg.race == 7 or cur_hero_cfg.race == self.m_task.race_condition[i] or self.m_task.race_condition[i] == 0 then
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
function M:getNeedEvo()
	return self.evo_condition[1]
end

--需要对应品质英雄的数量
function M:getNeedEvoNum()
	return self.evo_condition[2]
end

--当前对应品质的数量
function M:getCurEvoNum()
	local num = 0
	for k,v in pairs(SEND_SLOT_TAB) do
		if self.m_type == 2 and k == table.nums(self.m_task.race_condition) then
			local data,cfg = self:getMercenaryHero(v)
			if data.evo >= self:getNeedEvo() then
				num = num +1
			end
		elseif self.m_type == 3 and k == table.nums(self.m_task.race_condition) then
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

function M:auto_viewData(data)
	SEND_SLOT_TAB = {}
	for k,v in pairs(data) do
		if v.quest_id == self.m_task_id then
			for kk,vv in pairs(v.self_hero) do
				SEND_SLOT_TAB[kk] = vv
			end
			if self.m_type ==2 then
				if  table.nums(v.team_hero) > 0 then
					for tk,tv in pairs(v.team_hero) do
						table.insert( SEND_SLOT_TAB, tv)
					end
				end
			elseif self.m_type ==2 then
				if table.nums(v.heros) > 0 then
					for hk,hv in pairs(v.heros) do
						table.insert( SEND_SLOT_TAB, hk)
					end
				end
			end
		end
	end
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
	elseif self.m_type == 2 then
		for k,v in pairs(self.m_task.race_condition) do
			local need_race = v
			self.select_send_index = k
			if k ~= table.nums(self.m_task.race_condition) then
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
			elseif k == table.nums(self.m_task.race_condition) then	
				self:getMercenarysHeroByRace(need_race)
				for kk,vv in pairs(self.Filtrate_list) do
					if need_evo_num > 0 then
						local data, cfg = self:getMercenaryHero(vv)
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
		local race_tab = table.copy(self.m_task.race_condition)
		for k,v in pairs(race_tab) do
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
		if need_evo_num == 0 and self:isHaveNull() == true then
			for k,v in pairs(self.m_task.race_condition) do
				if self:checkRaceInSlot(v) == false then
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
	end
end
	
function M:checkRaceInSlot(race)
	for k,v in pairs(SEND_SLOT_TAB) do
		local data, cfg = self:getHero(v)
		if race == cfg.race then
			return true
		end
	end
	return false
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
