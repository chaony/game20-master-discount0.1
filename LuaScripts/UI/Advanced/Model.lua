local M = class("AdvancedPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("hero_select_evolution_hero")
end
M.detail_data_tab = {
	{common_cfg_id = 468, max_evo = 5, default_evo = 5},
	{common_cfg_id = 469, max_evo = 5, default_evo = 5},
	{common_cfg_id = 470, max_evo = 5, default_evo = 5},
	{common_cfg_id = 689, max_evo = 5, default_evo = 5},
	{common_cfg_id = 690, max_evo = 5, default_evo = 5},
}
function M:onEnter()
	self.m_martial = {1,2,3,4,5,6,7}
	self.is_link = false --当前选中联动英雄
	self.m_make_heros = UserDataManager.hero_data:getHeroDataMakeRace()
	self.m_index = 1
	self.m_select = {}
	self.m_need_count = 0
	self.m_hero_id = 0
	self.m_need_race = 0
	self.m_isfresh_list = true
	self.m_is_show_detail = false --是否展示进阶配方
	self.m_detail_index = 1 --进阶配方索引 1 五行，2阴 3阳, 4元
	self.m_evo_num = 0
	self.m_adv_num = 0
	self.m_hero_detail_cfg = ConfigManager:getCfgByName("hero_detail")
	self:updateOneKeyData(self.m_data)
	self:updateList()
	if self.m_params.oid then
		self:AddHero(self.m_params.oid)
	end
	self.m_default_select_oid = self.m_params.select_oid 
	self.m_max_ex_hero_lv = self:maxExHeroEvoLv()
end

function M:reset()
	self.m_make_heros = UserDataManager.hero_data:getHeroDataMakeRace()
	self.m_select = {}
	self.m_need_count = 0
	self.m_hero_id = 0
	self.m_need_race = 0
	self.m_slot_consume = nil
	self.m_has_own_consume = false
	
	-- self:evoHeroCheck()
	-- if self.m_evo_num < 2 then -- 进化英雄不够两个去查找进阶
		-- self:avdHeroCheck()
	-- end
	self:updateList()
end

function M:updateList()
	local heros = {}
	if self.m_index == 1 then
		heros = table.copy(UserDataManager.hero_data:getHerosId())
	else
		local martial = self.m_martial[self.m_index-1]
		heros = table.copy(self.m_make_heros[martial] or {})
	end
	self.m_red_point_card_ids = {}
	local canUpHeros = {}
	local maxUpHeros = {}
	local limitHeros = {}
	local notCondition = {}
	local same_id_heros = {}--本卡材料卡
	for i=#heros,1,-1 do
		local heroData, cfg = UserDataManager.hero_data:getHeroDataById(heros[i])
		local flag = true
		local temp_martial_index = 1
		if cfg.race == 5 then
			temp_martial_index = 3
		elseif cfg.race == 6 then
			temp_martial_index = 2
		elseif cfg.race == 7 then
			temp_martial_index = 4
		end
		if heroData.evo > self.detail_data_tab[temp_martial_index].max_evo then
			self.detail_data_tab[temp_martial_index].max_evo = heroData.evo
			if temp_martial_index == 4 then 
				self.detail_data_tab[5].max_evo = heroData.evo
			end
		end
		if cfg.evo == cfg.max_evo then
			--notCondition[#notCondition + 1] = heros[i]
			table.remove(heros,i)
			flag = false
		elseif #self.m_select > 0  and self.m_select[1] ~= heros[i] then
			local consume = false
			local is_self_martial = false
			for i,v in ipairs(self.m_consume or {}) do
				if v[1] == 1 then -- 吃自己
					if self.m_hero_id == cfg.id and heroData.evo == v[3] then
						consume = true
						is_self_martial = true
						break
					end
				elseif v[1] == 2 then -- 吃本族
					if heroData.evo == v[3] and cfg.race == self.m_need_race then
						consume = true
						break
					end
				elseif v[1] == 3 then --吃特定族
					if heroData.evo == v[3] and cfg.race == v[4] then
						consume = true
						break
					end
				end
			end
			if is_self_martial then
				same_id_heros[#same_id_heros + 1] = heros[i]
				table.remove(heros,i)
				flag = false
			elseif consume == false then
				notCondition[#notCondition + 1] = heros[i]
				table.remove(heros,i)
				flag = false
			end
		end

		if flag then
			local is_advanced, status = RedPointUtil:isHeroAdvanced(heros[i])
			if is_advanced then
				canUpHeros[#canUpHeros + 1] = heros[i]
				self.m_red_point_card_ids[heros[i]] = 1
				table.remove(heros,i)
			elseif heroData.evo >= cfg.max_evo then
				maxUpHeros[#maxUpHeros + 1] = heros[i]
				table.remove(heros,i)
			elseif status == 2 then
				limitHeros[#limitHeros + 1] = heros[i]
			end
		end
	end

	local function sortTable(oid1,oid2)
		local heroData1, cfg1 = UserDataManager.hero_data:getHeroDataById(oid1)
		local heroData2, cfg2 = UserDataManager.hero_data:getHeroDataById(oid2)
		heroData1.ctime = heroData1.ctime or 0
		heroData2.ctime = heroData2.ctime or 0
		
		if self.m_select[1] then
			if oid1 == self.m_select[1] then
				return true
			elseif oid2 == self.m_select[1] then
				return false
			end
			if self.m_has_own_consume and cfg1.id ~= cfg2.id then -- 有本卡材料
				if cfg1.id == self.m_hero_id then
					return true
				elseif cfg2.id == self.m_hero_id then
					return false	
				end
			end
		end
		if cfg1.evo == cfg2.evo then
			return heroData1.lv < heroData2.lv
		else
			return cfg1.evo < cfg2.evo
		end
	end

	local function sortTable2(oid1,oid2)
		local heroData1, cfg1 = UserDataManager.hero_data:getHeroDataById(oid1)
		local heroData2, cfg2 = UserDataManager.hero_data:getHeroDataById(oid2)
		heroData1.ctime = heroData1.ctime or 0
		heroData2.ctime = heroData2.ctime or 0
		
		if heroData1.evo == heroData2.evo then
			if heroData1.lv == heroData2.lv then
				if heroData1.id == heroData2.id then
					return heroData1.ctime < heroData2.ctime
				else
					return heroData1.id < heroData2.id
				end
			else
				return heroData1.lv > heroData2.lv
			end
		else
			return heroData1.evo > heroData2.evo
		end
	end

	if self.m_select[1] then
		table.sort( same_id_heros, sortTable )
		table.sort( heros, sortTable )
		table.sort( canUpHeros, sortTable )
	else
		table.sort( same_id_heros, sortTable2 )
		table.sort( heros, sortTable2 )
		table.sort( canUpHeros, sortTable2 )
	end
	table.sort( maxUpHeros, sortTable2 )
	table.sort( notCondition, sortTable2 )

	if self:isHeroFirst() then
		self.m_list_data = same_id_heros
		for i,v in ipairs(canUpHeros) do
			self.m_list_data[#self.m_list_data + 1] = v
		end
		for i,v in ipairs(heros) do
			self.m_list_data[#self.m_list_data + 1] = v
		end
	else
		self.m_list_data = canUpHeros
		for i,v in ipairs(heros) do
			self.m_list_data[#self.m_list_data + 1] = v
		end
		for i,v in ipairs(same_id_heros) do
			self.m_list_data[#self.m_list_data + 1] = v
		end
	end
	
	self.m_not_list = notCondition
	self.m_limitHeros = limitHeros

	for i,v in ipairs(maxUpHeros) do
		self.m_list_data[#self.m_list_data + 1] = v
	end
	for i,v in ipairs(notCondition) do
		self.m_list_data[#self.m_list_data + 1] = v
	end
end


function M:getHeroDataByIndex(index)
	return self.m_list_data[index]
end

function M:setMartial(index)
	self.m_isfresh_list = true
	self.m_index = index
	self:updateList()
end

function M:getDetailShowData()
	local common = ConfigManager:getCfgByName("common")
	local common_cfg_id = self.detail_data_tab[self.m_detail_index].common_cfg_id
	local show_id = common[common_cfg_id] and common[common_cfg_id].value or 0
	local show_evo_data_tab = {}
	local show_evo_tab = {}
	if show_id ~= 0 then
		show_evo_tab, show_evo_data_tab = self:getDetailShowConsume(show_id)
	end
	return show_id, show_evo_tab, show_evo_data_tab
end

function M:getDetailShowConsume(show_id)
	local cur_evo = self.detail_data_tab[self.m_detail_index].max_evo
	local default_evo = self.detail_data_tab[self.m_detail_index].default_evo
	local show_evo_data_tab = {}
	local show_evo = {}
	local hero_cfg =  self.m_hero_detail_cfg[show_id]
	if cur_evo >= hero_cfg.max_evo - 5 then
		cur_evo = hero_cfg.max_evo - 5
	end
	local hero_evolution = ConfigManager:getCfgByName("hero_evolution")
	if hero_cfg.islink and hero_cfg.islink > 0 then 
		local exhero_evolution_cfg = ConfigManager:getCfgByName("exhero_evolution")
		local type_table = exhero_evolution_cfg[hero_cfg.islink or 0]
		hero_evolution = type_table[show_id] or type_table[0]
	end
	local function insertData(i, evo)
		local temp_evo  = evo + i - 1
		table.insert(show_evo, temp_evo )
		--show_evo[i] = temp_evo
		local evo_data = hero_evolution[temp_evo].consume
		if not hero_cfg.islink or hero_cfg.islink == 0 then
			if hero_cfg.race == 5 then -- 阳
				evo_data = hero_evolution[temp_evo].consume_self5
			elseif hero_cfg.race == 6 then -- 阴
				evo_data = hero_evolution[temp_evo].consume_self6
			elseif hero_cfg.race == 7 then -- 元
				evo_data = hero_evolution[temp_evo].consume_self7
			end
		end
		table.insert(show_evo_data_tab, evo_data )
	end
	for i = 1, cur_evo - default_evo do
		insertData(i, default_evo)
	end
	for i = 1, 5 do
		insertData(i, cur_evo)
	end

	return show_evo, show_evo_data_tab
	
end

function M:AddHero(oid)
	local heroData, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	if #self.m_select == 0 then
		if heroData.evo >= cfg.max_evo then
			return 3 -- 已达到最高阶
		end
		if self:islimitHeros(oid) then
			return 5 -- 已有更高品质相同英雄
		end
		local exhero_evolution = ConfigManager:getCfgByName("exhero_evolution")
		local hero_evolution = ConfigManager:getCfgByName("hero_evolution")
		if cfg.islink and cfg.islink > 0 then
			local type_tab = exhero_evolution[cfg.islink or 0]
			hero_evolution = type_tab[heroData.id] or type_tab[0]
		end

		local evo_data = hero_evolution[heroData.evo].consume
		if not cfg.islink or cfg.islink == 0 then
			if cfg.race == 5 then -- 阳
				evo_data = hero_evolution[heroData.evo].consume_self5
			elseif cfg.race == 6 then -- 阴
				evo_data = hero_evolution[heroData.evo].consume_self6
			elseif cfg.race == 7 then -- 阴
				evo_data = hero_evolution[heroData.evo].consume_self7
			end
		end
		
		if next(evo_data) == nil then
			Logger.log(heroData.evo,"--------- do not evo -----------")
			return -1
		end
		self.m_consume = evo_data
		self.m_need_count = 1
		self.m_slot_consume = {}
		self.m_has_own_consume = false
		for i,v in ipairs(self.m_consume or {}) do
			for ii=1, v[2] do
				local data = table.copy(v)
				data[2] = 1
				self.m_slot_consume[#self.m_slot_consume + 1] = data
			end
			if v[1] == 1 then
				self.m_has_own_consume = true
			end
		end
		
		for i,v in ipairs(evo_data) do
			self.m_need_count = self.m_need_count + v[2]
		end

		self.m_hero_id = cfg.id
		self.m_need_race = cfg.race
		self.m_select[1] = oid
		self:updateList()
		return 0, 1
	else
		if heroData.lock == true then
			return 4 -- 以上锁
		end
		local consume_log, index = self:consumeCheck(oid)
		if consume_log == 0 then
			self.m_select[index] = oid
			self:updateList()
		end
		return consume_log, index
	end
end

--重新排序材料卡，进阶卡牌需要本卡做材料且未选中本卡材料卡时，将本卡材料卡放在最前面
function M:isHeroFirst()
	local first = true
	for i = 2, 3 do
		if self.m_select[i] and self.m_select[i] ~= "" then
			local heroData, cfg = UserDataManager.hero_data:getHeroDataById(self.m_select[i])
			local consume = self.m_slot_consume[i - 1]
			if consume then
				if consume[1] == 1 then --已经选了一个本身的材料卡
					if self.m_hero_id == cfg.id  then
						return false
					end
				end
			end
		end
	end
	return first and self.m_select[1] and self.m_has_own_consume
end

function M:consumeCheck(oid)
	local heroData, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	local consume_log = 2 -- 材料满
	for i = 2, 5 do
		if self.m_select[i] == nil then
			local consume = self.m_slot_consume[i - 1]
			if consume then
				if consume[1] == 1 then -- 吃自己
					if self.m_hero_id == cfg.id and consume[3] == heroData.evo then
						return 0, i
					else
						consume_log = 1 -- 不是材料
					end
				elseif consume[1] == 2 then -- 吃同族
					if self.m_need_race == cfg.race and consume[3] == heroData.evo then
						return 0, i
					else
						consume_log = 1 -- 不是材料
					end
				elseif consume[1] == 3 then -- 吃特定族
					if consume[4] == cfg.race and consume[3] == heroData.evo then
						return 0, i
					else
						consume_log = 1 -- 不是材料
					end
				end
			end
		end
	end
	return consume_log
end

function M:isSelectedByIndex(oid)
	for i,v in pairs(self.m_select) do
		if v == oid then
			return true
		end
	end
	return false
end

function M:removeHero(oid)
	for i=1,self.m_need_count do
		if self.m_select[i] == oid then
			if i == 1 then
				self:reset()
			else
				self.m_select[i] = nil
			end
			return i
		end
	end
end

function M:updateOneKeyData(data)
	self.m_oneKey_data = data
	self.m_evo_num = #data.onekey
	self.m_adv_num = #data.intellect
end

function M:getRedPointByHeroId(oid)
	return self.m_red_point_card_ids[oid] == 1
end

function M:islimitHeros(oid)
	local heroData, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	if cfg.islink == 1 then
		return false
	end
	if table.keyof(self.m_limitHeros or {},oid) then
		return true
	end
	return false
end

function M:isConsume(oid)
	local heroData, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	for i,v in ipairs(self.m_consume or {}) do
		if v[1] == 1 then -- 吃自己
			if self.m_hero_id == cfg.id and v[3] == heroData.evo then
				return true
			end
		elseif  v[1] == 2 then -- 吃同族
			if self.m_need_race == cfg.race and v[3] == heroData.evo then
				return true
			end
		elseif v[1] == 3 then -- 吃特定族
			if v[4] == cfg.race and v[3] == heroData.evo then
				return true
			end
		end
	end
	return false
end

--是否可以使用万能材料// 限定种族(race)、限定类型(islink)、限定品质(evo)
function M:checkCanUseUniversal()
	if next(self.m_select) == nil then
		return {}
	end
	
	local oid = self.m_select[1]
	local heroData, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	if cfg.islink and cfg.islink > 0 then
		if cfg.universal and cfg.universal > 0 then
			if cfg.high_gacha_time and cfg.high_gacha_time ~= "" then
				local high_gacha_time = string.split(cfg.high_gacha_time,"~")
				local start_time = high_gacha_time[1] or ""
				local end_time = high_gacha_time[2] or ""
				if start_time ~= "" and end_time ~= "" then
					local start_ts = GameUtil:stringToTimesTamp(start_time)
					local end_ts = GameUtil:stringToTimesTamp(end_time)
					local cur_time = UserDataManager:getServerTime()
					if cur_time < start_ts or cur_time > end_ts then
						local exhero_evolution_cfg = ConfigManager:getCfgByName("exhero_evolution")
						local type_table = exhero_evolution_cfg[cfg.islink or 0]
						local hero_evolution = type_table[heroData.id] or type_table[0]
						local evo_data = hero_evolution[heroData.evo]
						for k,v in pairs(evo_data.consume) do
							if v[1] == 1 then
								return self:computerUniversal() -- 需要的数量
							end
						end
					end
				end
			end
		end
	end
	return {}
end

-- 计算需要的万能材料
function M:computerUniversal()
	if next(self.m_select) == nil then
		return {}
	end
	local universal_tab = {}
	local sel_oid = self.m_select[1]
	local sel_heroData, sel_cfg = UserDataManager.hero_data:getHeroDataById(sel_oid)
	for i, v in ipairs(self.m_slot_consume) do
		if v[1] == 1 then
			if self.m_select[i+1] == nil or  self.m_select[i+1] == "" then
				local heros = UserDataManager.hero_data:getHerosId()
				for ii, oid in ipairs(heros) do
					local is_Selected = self:isSelectedByIndex(oid)
					if not is_Selected then
						local heroData, cfg = UserDataManager.hero_data:getHeroDataById(oid)
						if sel_heroData.id == heroData.id and heroData.evo == v[3] then
							return universal_tab
						end
					end
				end
				local num = 0
				if  v[3] == 5 then
					num = 1
				elseif v[3] == 6 then
					num = 2
				end
				universal_tab[i+1] = num
			end
		end
	end
	return universal_tab
end

--万能材料是否足够
function M:checkHaveUniversal()
	if next(self.m_select) == nil then
		return false
	end
	local oid = self.m_select[1]
	local heroData, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	if cfg.islink and cfg.islink > 0 then
		local exhero_evolution_cfg = ConfigManager:getCfgByName("exhero_evolution")
		local type_table = exhero_evolution_cfg[cfg.islink or 0]
		local hero_evolution = type_table[heroData.id] or type_table[0]
		local evo_data = hero_evolution[heroData.evo]
		local reward_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM, cfg.universal, 1 })
		local need_one_num = 0 --需要本体数量
		local need_other_num = 0 --需要其他数量
		local have_one_num = 0 --拥有本体数量 
		local have_other_num = 0
		for k,v in pairs(self.m_slot_consume) do
			if v[1] == 1 then
				if v[3] == 5 then
					need_one_num = need_one_num + 1
				elseif v[3] == 6 then
					need_one_num = need_one_num + 2	
				end
			else
				need_other_num = need_other_num + 1	
			end
		end
		for k, v in pairs(self.m_select) do
			if k > 1 then
				local temp_heroData, temp_cfg = UserDataManager.hero_data:getHeroDataById(v)
				if temp_cfg then
					if temp_cfg.race == cfg.race and cfg.id == temp_cfg.id then
						if temp_heroData.evo == 6 then
							have_one_num = have_one_num + 2
						else
							have_one_num = have_one_num + 1
						end
					else
						have_other_num = have_other_num + 1
					end
				end
			end
		end
		
		if reward_data.user_num >= (need_one_num-have_one_num) and have_other_num >= need_other_num then
			return true
		end
	end
	return false
end

--使用万能材料数量
function M:checkUseUniversalNum()
	if next(self.m_select) == nil then
		return 0
	end
	local oid = self.m_select[1]
	local heroData, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	if cfg.islink and cfg.islink > 0 then
		local exhero_evolution_cfg = ConfigManager:getCfgByName("exhero_evolution")
		local type_table = exhero_evolution_cfg[cfg.islink or 0]
		local hero_evolution = type_table[heroData.id] or type_table[0]
		local evo_data = hero_evolution[heroData.evo]
		local reward_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM, cfg.universal, 1 })
		local need_one_num = 0 --需要本体数量
		local have_one_num = 0
		for k,v in pairs(self.m_slot_consume) do
			if v[1] == 1 then
				if v[3] == 5 then
					need_one_num = need_one_num + 1
				elseif v[3] == 6 then
					need_one_num = need_one_num + 2	
				end
			end
		end
		for hero_index, hero_id in pairs(self.m_select) do
			if hero_index > 1 then
				local temp_heroData, temp_cfg = UserDataManager.hero_data:getHeroDataById(hero_id)
				if temp_cfg and temp_cfg.race == cfg.race and cfg.id == temp_cfg.id then
					if temp_heroData.evo == 6 then
						have_one_num = have_one_num + 2
					else
						have_one_num = have_one_num + 1
					end
				end
			end
		end
		return (need_one_num-have_one_num)
	end
	return 0
end

--万能卡插入列表
function M:getLutionConsData()
	local cons_data = {}
	local oid = self.m_select[1]
	local heroData, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	for i,v in ipairs(self.m_slot_consume) do
		local race = cfg.race 
		if v[1] == 3 then
			race = v[4]
		end
		cons_data[i] = 0
		
		for hero_index, hero_id in pairs(self.m_select) do
			if hero_index > 1 then
				local temp_heroData, temp_cfg = UserDataManager.hero_data:getHeroDataById(hero_id)
				if temp_cfg and self:checkInTab(hero_id,cons_data) == false then
					if v[1] == 1 and temp_cfg.id == cfg.id then
						cons_data[i] = hero_id
					elseif v[1] ~= 1 and race == temp_cfg.race then
						cons_data[i] = hero_id
					end
				end
			end
		end
	end
	return cons_data
end

function M:checkInTab(oid, tab)
	for k,v in pairs(tab) do
		if v == oid then
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------

-- 一键进化查找
function M:evoHeroCheck()
	-- local heros = UserDataManager.hero_data:getHerosData()
	-- local make_heros = {}
	-- for k,v in pairs(heros) do
	-- 	if make_heros[v.evo] == nil then
	-- 		make_heros[v.evo] = {}
	-- 	end
	-- 	if make_heros[v.evo][v.id] == nil then
	-- 		make_heros[v.evo][v.id] = {}
	-- 	end
	-- 	table.insert(make_heros[v.evo][v.id],v.oid)
	-- end

	-- local function sortTable(oid1,oid2)
	-- 	local heroData1 = UserDataManager.hero_data:getHeroDataById(oid1)
	-- 	local heroData2 = UserDataManager.hero_data:getHeroDataById(oid2)
	-- 	return heroData1.lv > heroData2.lv
	-- end

	-- for k,v in pairs(make_heros) do
	-- 	for kk,vv in pairs(v) do
	-- 		table.sort(vv,sortTable)
	-- 	end
	-- end

	-- local eov_table = {}
	-- local sign_table = {}
	-- local evo_num = 0
	-- local hero_evolution = ConfigManager:getCfgByName("hero_evolution")
	-- for evo=1,#hero_evolution do  -- 从低品质开始
	-- 	local evo_cfg = hero_evolution[evo]
	-- 	if next(evo_cfg.consume) and evo_cfg.consume[1] == 1 then
	-- 		local heros = make_heros[evo]
	-- 		for k,v in pairs(heros or {}) do
	-- 			if evo == evo_cfg.consume[3] then
	-- 				local table_head = 1
	-- 				local table_end = #v

	-- 				while(table_end - table_head >= evo_cfg.consume[2]) do
	-- 					eov_table[v[table_head]] = {}
	-- 					for j=1,evo_cfg.consume[2] do
	-- 						table.insert(eov_table[v[table_head]],v[table_end])
	-- 						table_end = table_end -1
	-- 					end
	-- 					table_head = table_head + 1
	-- 					evo_num = evo_num + 1
	-- 				end
	-- 			else
	-- 				local material_table = make_heros[evo_cfg.consume[3]]
	-- 				if material_table then
	-- 					local material = material_table[k] or {}
	-- 					local table_end = #material
	-- 					for ii,vv in ipairs(v) do
	-- 						if table_end >= evo_cfg.consume[2] then
	-- 							eov_table[vv] = {}
	-- 							for j=1,evo_cfg.consume[2] do
	-- 								table.insert(eov_table[vv],material[table_end])
	-- 								table.remove(material, table_end)
	-- 								table_end = table_end -1
	-- 							end
	-- 							evo_num = evo_num + 1
	-- 							table.remove(v,ii)
	-- 						end
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- self.m_evo_table = eov_table
	-- self.m_evo_num = evo_num
	-- Logger.log(self.m_evo_num,"m_evo_num ====")
	-- Logger.log(self.m_evo_table,"m_evo_table ====")
end

-- 一键进阶查找
function M:avdHeroCheck()
	-- local heros = UserDataManager.hero_data:getHerosData()
	-- local make_heros = {}
	-- for k,v in pairs(heros) do
	-- 	if make_heros[v.evo] == nil then
	-- 		make_heros[v.evo] = {}
	-- 	end
	-- 	local cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id)
	-- 	if make_heros[v.evo][cfg.race] == nil then
	-- 		make_heros[v.evo][cfg.race] = {}
	-- 	end
	-- 	table.insert(make_heros[v.evo][cfg.race],v.oid)
	-- end

	-- local function sortTable(oid1,oid2)
	-- 	local heroData1 = UserDataManager.hero_data:getHeroDataById(oid1)
	-- 	local heroData2 = UserDataManager.hero_data:getHeroDataById(oid2)
	-- 	return heroData1.lv > heroData2.lv
	-- end

	-- for k,v in pairs(make_heros) do
	-- 	for kk,vv in pairs(v) do
	-- 		table.sort(vv,sortTable)
	-- 	end
	-- end

	-- local adv_table = {}
	-- local sign_table = {}
	-- local adv_num = 0
	-- local hero_evolution = ConfigManager:getCfgByName("hero_evolution")
	-- for i=1,#hero_evolution do  -- 从低品质开始
	-- 	local evo_cfg = hero_evolution[i]
	-- 	if next(evo_cfg.consume) and evo_cfg.consume[1] == 2 then
	-- 		local heros = make_heros[i]
	-- 		local material_table = make_heros[evo_cfg.consume[3]]
	-- 		if material_table then
	-- 			for k,v in pairs(heros or {}) do
	-- 				local material = material_table[k]
	-- 				if material then
	-- 					for j,m in ipairs(v) do
	-- 						if not sign_table[m] then
	-- 							local key = m
	-- 							local value = {}
	-- 							for jj,mm in ipairs(material) do
	-- 								if mm ~= key and not sign_table[mm] then
	-- 									table.insert(value,mm)
	-- 								end
	-- 								if #value == evo_cfg.consume[2] then
	-- 									adv_table[key] = value
	-- 									adv_num = adv_num + 1
	-- 									sign_table[key] = true
	-- 									for x,y in ipairs(value) do
	-- 										sign_table[y] = true
	-- 									end
	-- 									break
	-- 								end
	-- 							end
	-- 						end
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end

	-- self.m_adv_table = adv_table
	-- self.m_adv_num = adv_num
	-- Logger.log(self.m_adv_num,"m_adv_num ====")
	-- Logger.log(self.m_adv_table,"m_adv_table ====")
end

--最大结义等级上限
function M:maxExHeroEvoLv()
	-- local exhero_evolution = ConfigManager:getCfgByName("exhero_evolution")
	-- return #exhero_evolution
	return 0
end


return M
