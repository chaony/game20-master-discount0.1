---@class CoachPopModel:OODataBase
local M = class("CoachPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_martial = {1,2,3,4,5,6,7}
	self.m_make_heros = UserDataManager.hero_data:getHeroDataMakeRace()
	self.m_delete_evo = ConfigManager:getCommonValueById(20,1)
	self.m_tab_index = self.m_params.tab_index or 1
	self.m_martial_index = 1
	self.m_net_refresh_bl = false --跨天刷新标识
	self.m_select_max = 12
	self.m_select_heros = {}
	self.m_reset_items = {}
	self:updateList()
	if self.m_params.oid then
		self:AddHero(self.m_params.oid)
	end
end

function M:reset()
	self.m_make_heros = UserDataManager.hero_data:getHeroDataMakeRace()
	--self.m_martial_index = 1
	self.m_select_heros = {}
	self.m_reset_items = {}
	self:updateList()
end

function M:setTabIndex(index)
	self.m_tab_index = index
	self:reset()
end

function M:setGachaDelete(isDelete)
	self.m_gacha_delete = isDelete
end

function M:setMartial(index)
	self.m_martial_index = index
	self:updateList()
end

function M:updateList()
	local temp_table = {}
	if self.m_martial_index == 1 then
		temp_table = UserDataManager.hero_data:getHerosId()
	else
		local martial = self.m_martial[self.m_martial_index-1]
		temp_table = self.m_make_heros[martial] or {}
	end
	local limit_evo = ConfigManager:getCommonValueById(328,{7,8})
	self.m_list_data = {}
	for i,v in ipairs(temp_table) do
		local data, cfg = UserDataManager.hero_data:getHeroDataById(v)
		if self.m_tab_index == 1 then -- 回退
			if data.evo >= limit_evo[1] and data.evo <= limit_evo[2] and data.evo_hero and next(data.evo_hero)  then
				self.m_list_data[#self.m_list_data + 1] = v
			end
		elseif self.m_tab_index == 2 then -- 遣散
			if data.evo <= self.m_delete_evo then
				self.m_list_data[#self.m_list_data + 1] = v
			end
		elseif self.m_tab_index == 3 then -- 重置
			if data.lv > 1 then
				self.m_list_data[#self.m_list_data + 1] = v
			end
		elseif self.m_tab_index == 4 then -- 图鉴升级重置
			local roleUpGradeLv = ConfigManager:getCommonValueById(602,0)
			if data.evo >= tonumber(roleUpGradeLv) and data.book and data.book.lv > 0 then
				self.m_list_data[#self.m_list_data + 1] = v
			end
		end
	end
	UserDataManager.hero_data:heroIdsSort(self.m_list_data)
end

function M:getHeroDataByIndex(index)
	return self.m_list_data[index]
end

function M:AddHero(oid)
	for i,v in ipairs(self.m_select_heros) do
		if v == oid then
			table.remove(self.m_select_heros,i)
			if self.m_tab_index == 3 then
				self.m_reset_items = {}
			end
			return true
		end
	end

	if self.m_tab_index == 1 or self.m_tab_index == 3 or self.m_tab_index == 4 then
		-- if #self.m_select_heros < 1 then
			self.m_select_heros[1] = oid
			self:getResetBackResource()
			return true
		-- else
			
		-- end
	else
		if #self.m_select_heros < self.m_select_max then
			self.m_select_heros[#self.m_select_heros + 1] = oid
			return true
		else
			Logger.log("----------- select one hero num is max ------------")
		end
	end
end

function M:oneKeyAddHero()
	self.m_select_heros = {}
	local temp_table = UserDataManager.hero_data:getHerosId()
	for i,v in ipairs(temp_table) do
		local data, cfg = UserDataManager.hero_data:getHeroDataById(v)
		if data.evo <= self.m_delete_evo then
			self.m_select_heros[#self.m_select_heros + 1] = v
		end
		if #self.m_select_heros >= self.m_select_max then
			break
		end
	end
end

function M:getSelectHeroDataByIndex(index)
	return self.m_select_heros[index]
end

function M:getBackTimes()
	local total_times =  ConfigManager:getCommonValueById(386  , 30)
	local has_times = total_times - UserDataManager.reset_times
	return has_times
end

function M:getResetItemDataByIndex(index)
	return self.m_reset_items[index]
end

function M:getDeleteReturnData()
	local data = {}
	local disband_cfg = ConfigManager:getCfgByName("hero_evolution")
	local exhero_evolution = ConfigManager:getCfgByName("exhero_evolution")

	for i,v in ipairs(self.m_select_heros) do
		local hero,cfg = UserDataManager.hero_data:getHeroDataById(v)
		for i,v in pairs(hero.equips) do
			table.insert(data, {RewardUtil.REWARD_TYPE_KEYS.EQUIPS, v.id,v.race ,equip_num = 1})
		end

		local temp = self:getGradeBackResource(hero)
		for i,v in ipairs(temp) do
			local flag = true
			for m,n in ipairs(data) do
				if n[1] == v[1] and n[2] == v[2] then
					n[3] = n[3] + v[3]
					flag = false
					break
				end
			end
			if flag then
				data[#data + 1] = table.copy(v)
			end
		end	
		if hero.race == 7 then
			local type_tab = exhero_evolution[cfg.islink or 0]
			disband_cfg = type_tab[hero.id] or type_tab[0]
		end
		for ii,vv in ipairs(disband_cfg[hero.evo].disband or {}) do
			local flag = true
			for m,n in ipairs(data) do
				if n[1] == vv[1] and n[2] == vv[2] then
					n[3] = n[3] + vv[3]
					flag = false
					break
				end
			end
			if flag then
				data[#data + 1] = table.copy(vv)
			end
		end
	end
	-- Logger.log(data,"getDeleteReturnData data ==")
	return data
end

function M:isSelect(oid)
	for i,v in ipairs(self.m_select_heros) do
		if v == oid then
			return true



		end
	end
	return false
end

function M:getResetBackResource()
	local hero_oid = self.m_select_heros[1]
	local data, cfg = UserDataManager.hero_data:getHeroDataById(hero_oid)
	-- Logger.log(grade_tab,"grade_tab ====")
	local res_tab = {{RewardUtil.REWARD_TYPE_KEYS.HEROS, cfg.id, 1, hero_oid = hero_oid}}
	if self.m_tab_index == 1 then
		local martial_evo = data.evo - 1
		local quality = ConfigManager:getCommonValueById(336,6)
		local ievo = data.ievo or quality
		res_tab[1][4] = nil
		res_tab[1].quality = math.max(ievo, quality)
		local hero_evolution = ConfigManager:getCfgByName("hero_evolution")
		local exhero_evolution = ConfigManager:getCfgByName("exhero_evolution")
		if cfg.islink and cfg.islink > 0 then
			local type_tab = exhero_evolution[cfg.islink or 0]
			hero_evolution = type_tab[data.id] or type_tab[0]
		end
		local evolution_cfg = hero_evolution[martial_evo]
		--Logger.log(evolution_cfg,"evolution_cfg ====")
		local consume = evolution_cfg.consume
		if not cfg.islink or cfg.islink == 0 then
			if cfg.race == 5 then
				consume = evolution_cfg.consume_self5
			elseif cfg.race == 6 then
				consume = evolution_cfg.consume_self6
			elseif cfg.race == 7 then
				consume = evolution_cfg.consume_self7
			end
		end
		
		if type(consume[1]) == "table" then
			consume = consume[1]
		end
		-- id:count 结构
		for id,count in pairs(data.evo_hero or {}) do
			local hero_id = tonumber(id)
			for i = 1, count do
				table.insert(res_tab,{RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_id, 1, quality = consume[3]})
			end
		end
		for id,count in pairs(data.evo_item or {}) do
			local item_id = tonumber(id)
			table.insert(res_tab,{RewardUtil.REWARD_TYPE_KEYS.ITEM, item_id, count})
		end
	end
	if self.m_tab_index == 4 then
		-- id:count 结构
		if data.book then
			for id,count in pairs(data.book.lup or {}) do
				local hero_id = tonumber(id)
				for i = 1, count do
					local heroRoleCfg, evo, role_level, costQuality = self:getHeroRoleCfg(nil,hero_id)
					table.insert(res_tab,{RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_id, 1, quality = costQuality})
				end
			end
			for id,count in pairs(data.book.lup_item or {}) do
				local item_id = tonumber(id)
				table.insert(res_tab,{RewardUtil.REWARD_TYPE_KEYS.ITEM, item_id, count})
			end
			local itemList = self:getResetRoleCostItem(cfg.id)
			for i, v in pairs(itemList) do
				table.insert(res_tab, v)
			end
		end
		
	else
		local temp = self:getGradeBackResource(data)
		for i,v in ipairs(temp) do
			table.insert(res_tab, v)
		end
	end
	self.m_reset_items = res_tab
end

function M:getGradeBackResource(heroData)
	local grade_tab = GameUtil:getHeroUpGrade(heroData.lv-1,1)
	local res_tab = {}
	for k,v in pairs(grade_tab or {}) do
		if k == "coin" and v > 0 then
			table.insert(res_tab, {RewardUtil.REWARD_TYPE_KEYS.COIN, 0, v})
		elseif k == "special_num" and v > 0 then
			table.insert(res_tab, {RewardUtil.REWARD_TYPE_KEYS.DUST, 0, v})
		elseif k == "exp" and v > 0 then
			table.insert(res_tab, {RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, v})
		end
	end
	return res_tab
end

function M:getSpinePos(hero_data,cfg)
	if cfg == nil then
		return Vector3(0,0,0)
	end
	local id = cfg.id
	local hero_tab = ConfigManager:getCfgByName("hero_detail")
	local data_pos = hero_tab[id]["spine_position"]
	local data_scale = hero_tab[id]["hero_scale"] or 1
	return data_pos, data_scale
end

function M:getRollBackTimes()
	local roll_back_times = UserDataManager.m_rollback_buy_times or 0
	return roll_back_times
end

function M:isMaxTime()
	local max_times = self:getMaxTimes()
	local cur_times = self.getRollBackTimes()
	local is_max_time = false
	if max_times == 0 then
	elseif cur_times >= max_times then
		is_max_time = true
	end
	return is_max_time
end

function M:getMaxTimes()
	local max_times = ConfigManager:getCommonValueById(450,0)
	return max_times
end

-- 获取职业等级配置信息
function M:getHeroRoleCfg( level , cid)
	local heroRoleCfg, consume_item = {}, {}
	local role_level, num, costQuality = 0
	local evo, heroId = UserDataManager.hero_data:getHeroHighEvoByCid(cid)
	local heroCfg = UserDataManager.hero_data:getHeroConfigByCid(cid)
	local cur_season = UserDataManager:getCurSeason() -- 当前赛季
	if heroId and heroId~=0 then
		role_level = UserDataManager.hero_data:getHeroRoleLevelById(heroId) -- 职业等级
		if level then role_level = level end -- 消耗要读下一级
		if role_level and heroCfg then
			local role_type = heroCfg.role_type or 0
			if role_type ~= 0 then
				local herorole = ConfigManager:getCfgByName("herorole")
				local heroRoleItem = herorole[role_type] or {}
				local seasonHeroRoleCfg = heroRoleItem[role_level] or {}
				if seasonHeroRoleCfg.season and seasonHeroRoleCfg.season <= cur_season then -- 根据赛季取配置
					heroRoleCfg = seasonHeroRoleCfg
					if heroRoleCfg and _G.next(heroRoleCfg) then
						local consume_hero = heroRoleCfg.consume_hero
						num = consume_hero[1][2]
						costQuality = consume_hero[1][3]
						consume_item = heroRoleCfg.consume_item
					end
				end
			end
		end
	end
	return heroRoleCfg, evo, role_level, costQuality
end
-- 获取图鉴重置资源
function M:getResetRoleCostItem(cid)
	local heroRoleCfg, consume_item = {}, {}
	local role_level = 0
	local evo, heroId = UserDataManager.hero_data:getHeroHighEvoByCid(cid)
	local heroCfg = UserDataManager.hero_data:getHeroConfigByCid(cid)
	if heroId and heroId~=0 then
		role_level = UserDataManager.hero_data:getHeroRoleLevelById(heroId) -- 职业等级
		if role_level and heroCfg then
			local role_type = heroCfg.role_type or 0
			if role_type ~= 0 then
				local herorole = ConfigManager:getCfgByName("herorole")
				local heroRoleItem = herorole[role_type] or {}
				for i = role_level, 1, -1 do
					heroRoleCfg = heroRoleItem[i] or {}
					if heroRoleCfg and _G.next(heroRoleCfg) then
						for m, n in pairs(heroRoleCfg.consume_item) do
							table.insert(consume_item, n)
						end
					end
				end
			end
		end
	end
	local tempList = {}
	for i, v in ipairs(consume_item) do
		if #tempList == 0 then
			tempList[#tempList+1] = table.copy(v)
		else
			for m, n in ipairs(tempList) do
				if v[1] == n[1] and v[2] == n[2] then
					n[3] = n[3] + v[3]
				else
					tempList[#tempList+1] = table.copy(v)
				end
			end
		end
	end
	return tempList, consume_item
end

return M
