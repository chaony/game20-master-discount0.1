local M = class("DestinyStarModel",LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.current_mode = 1 --天命、化星模式
	self.select_hero_id = self.m_params.id or 0 --要特定显示oid
	self.m_fate_building_cfg = ConfigManager:getCfgByName("fate_building") or {}
	self.m_fates = UserDataManager:getFatesInfo()
	self:initHeroData()
	self.material = {} --消耗材料卡
	--Logger.logError(self.m_data.fates,"服务端数据")
	self.currentHeroIndex = 1
	self.hero_table = self:getHeroData()
end


--更新选中英雄
function M:updateCurrentHeroData(data)
	self.current_hero_data = data.data.data
	self.current_hero_cfg = data.data.cfg
	self.current_hero_index = data.index
end

--更新数据
function M:netData(data, tag)
	self.m_fates = UserDataManager:getFatesInfo()
end

--初始化英雄选择
function M:initHeroData()
	local hero_data = self:getHeroData()
	if hero_data ~= nil and hero_data[1] ~= nil then
		self.current_hero_data = hero_data[1].data
		self.current_hero_cfg = hero_data[1].cfg
	end
end

--获取领悟诗----已领悟状态
function M:getPoetry(hero_id)
	local poetry_data = ConfigManager:getCfgByName("fate_common")
	if poetry_data ~= nil then
		return poetry_data[hero_id]
		--for i, v in pairs(poetry_data) do
		--	if i == hero_id then
		--		return v
		--	end
		--end
	end
	return {}
end

-----------------------------------------------------------英雄可领悟条件

--英雄最大等级
function M:heroMaxExo(hero_id)
	local hero_detail = ConfigManager:getCfgByName("hero_detail")
	local hero_evolution = ConfigManager:getCfgByName("hero_evolution")
	local max_evo = 0 --最高品质
	for i, v in pairs(hero_detail) do
		if v.id == hero_id then
			max_evo = v.max_evo
		end
	end
	for i, v in pairs(hero_evolution) do
		if i == max_evo then
			return v.level_max
		end
	end
	return 0
end

--判断筋脉是否最大
function M:heroIsSig(hero_sig,sig_deep)
	if hero_sig ~= nil and hero_sig["1"] ~= nil and hero_sig["2"] ~= nil and hero_sig["3"] ~= nil and hero_sig["4"] ~= nil then
		--local meridians_cultivation = ConfigManager:getCfgByName("meridians_cultivation") --废弃判断是否点到最大等级
		--local sig_lv = meridians_cultivation[sig_deep].lower_level
		local deep_1 = hero_sig["1"].deep or 0
		local deep_2 =  hero_sig["2"].deep or 0
		local deep_3 =  hero_sig["3"].deep or 0
		local deep_4 =  hero_sig["4"].deep or 0
		local sig_1 = deep_1 >= sig_deep
		local sig_2 = deep_2 >= sig_deep
		local sig_3 = deep_3 >= sig_deep
		local sig_4 = deep_4 >= sig_deep
		if sig_1 and sig_2 and sig_3 and sig_4 then
			return true
		end
	end
	return false
end

--获取最大好感度等级
function M:getFetters()
	local fetters_level = ConfigManager:getCfgByName("fetters_level")
	if fetters_level[1] ~= nil then
		return #fetters_level[1],fetters_level[1].upgrade
	end
	return 0
end

--获取英雄最大好感度
function M:getHeroMaxFriendLiness(hero_id)
	local friendliness = UserDataManager:getFriendliness()
	return friendliness[tostring(hero_id)] or {}
end

--判断好感度是否最大
function M:heroIsFriendLiness(hero_id,friend)
	local max_friendLiness = self:getHeroMaxFriendLiness(hero_id)
	local max_lv = max_friendLiness.lv or 0
	if max_lv >= friend then
		return true
	end
	return false
end

---------------------------------------------------------------获取英雄

--获取所有英雄
function M:getAllHeroIds()
	local ids = table.copy(UserDataManager.hero_data:getHerosId())
	UserDataManager.hero_data:heroIdsSort(ids, "team")
	return ids
end

--获取所有英雄信息
function M:getHeroData()
	local all_hero = self:getAllHeroIds()
	local hero_data = {}
	for i, v in pairs(all_hero) do
		local data, cfg = UserDataManager.hero_data:getHeroDataById(v)
		local poetry_data = self:getPoetry(cfg.id) or {}
		local is_has_star = poetry_data.fate_open or 999 --开启赛季
		local start_pre_stage = poetry_data.unlock_condition_param3 or 0 --超前开启
		local server_unlock_season = 0
		local season_data = UserDataManager.m_season_data or {}
		if season_data and next(season_data) and season_data.season then
			server_unlock_season = season_data.season
		end
		local cur_stage = UserDataManager:getCurStage()
		if server_unlock_season >= is_has_star or (start_pre_stage ~= 0 and cur_stage >= start_pre_stage) then
			local is_insert,insert_id = self:isInsert(hero_data,data)
			if not is_insert then --没大于
				if insert_id > 0 then --有英雄但等级小于当前英雄值
					table.remove (hero_data,insert_id)
				end
				local data = {data = data,cfg = cfg,ids = v,id = data.id,evo = data.evo}
				local hero_is_state = self:filtrateHero(data)
				data.hero_state = hero_is_state
				table.insert(hero_data,data)
			end
		end
	end
	table.sort(hero_data,function(data1,data2)
		if data1.hero_state == data2.hero_state then
			return data1.hero_state > data2.hero_state
		else
			return data1.hero_state < data2.hero_state
		end
	end)
	return hero_data
end

--英雄列表中是否有改英雄
function M:isInsert(hero_data,data)
	for i, v in pairs(hero_data) do
		if v.id == data.id then
			if v.evo >= data.evo then
				return true,i
			else
				return false,i
			end
		end
	end
	return false,0
end

--判断英雄是否可领悟
function M:filtrateHero(hero_data)
	if self:heroIsLight(hero_data.data.oid) then
		return 2
	end
	local hero_maxlv = self:heroEvoIsOk(hero_data.data.evo) --英雄最大等级
	local hero_sig = self:heroSigIsOk(hero_data.data.sig) --英雄是否点亮全部经脉
	local hero_friendliness = self:heroFriendIsOk(hero_data.data.id) --英雄是否好感度最大等级
	if hero_maxlv and hero_sig and hero_friendliness then --判断等级、经脉、好感度,消耗侠客，材料是否满
		for i, v in pairs(self.m_fates) do
			for heros_i, heros_v in pairs(v.heros) do
				if heros_i == tostring(hero_data.data.id) then
					return 2 --已领悟
				end
			end
		end
		local same_id_heros, universal = self:getEvoSixHeroList(hero_data.data.id) --符合消耗的侠客
		local fate_cost = self:getFateCost(hero_data.data.id)
		local itemData = RewardUtil:getProcessRewardData(fate_cost[1]) --材料数据
		if itemData.user_num >= itemData.data_num then
			if universal then
				if #same_id_heros >= 2 or universal.user_num >= (2 - #same_id_heros) * universal.data_num then
					return 0 --可以领悟
				end
			else
				if #same_id_heros >= 2 then
					return 0 --可以领悟
				end
			end
		end
	end
	return 1 --不可领悟
end

--判断英雄经脉是否达到要求
function M:heroSigIsOk(hero_sig)
	if self.m_cfg628_value == nil then
		self.m_cfg628_value = ConfigManager:getCommonValueById(628, 3)
	end
	local sig = self.m_cfg628_value
	--local common = ConfigManager:getCfgByName("common")
	--local sig =  3
	--if common[628] ~= nil and common[628].value ~= nil then
	--	sig = common[628].value
	--end
	local sig_isok = self:heroIsSig(hero_sig,sig)
	return sig_isok
end

--判断英雄等级是否达到要求
function M:heroEvoIsOk(hero_evo)
	if self.m_cfg627_value == nil then
		self.m_cfg627_value = ConfigManager:getCommonValueById(627, 24)
	end
	--local common = ConfigManager:getCfgByName("common")
	--local ask = 24
	--if common[627] ~= nil and common[627].value ~= nil then
	--	ask = common[627].value
	--end
	local ask = self.m_cfg627_value
	return hero_evo >= ask
end

--判断英雄好感度是否达到要求
function M:heroFriendIsOk(hero_id)
	if self.m_cfg629_value == nil then
		self.m_cfg629_value = ConfigManager:getCommonValueById(629, 20)
	end
	--local common = ConfigManager:getCfgByName("common")
	--local friend = 20
	--if common[629] ~= nil and common[629].value ~= nil then
	--	friend = common[629].value
	--end
	local friend = self.m_cfg629_value
	local friend_isok = self:heroIsFriendLiness(hero_id,friend)
	return friend_isok
end

--判断英雄是否领悟
function M:heroIsLight(hero_oid)
	for i, v in pairs(self.m_fates) do
		--local index = table.keyof(v.heros, hero_oid)
		--if index and index > 0 then
		--	return true
		--end
		for hero_i, hero_v in pairs(v.heros) do
			if hero_v == hero_oid then
				return true
			end
		end
	end
	return false
end

---------------------------------------------------------------获取化星信息
--获取化星信息
function M:getStarInfo()
	local starInfo = {}
	local fate_star = ConfigManager:getCfgByName("fate_star")
	for i, v in pairs(fate_star) do
		table.insert(starInfo,{cfg = v,star_id = i})
	end
	table.sort(starInfo,function(data1,data2) 
		return data1.star_id < data2.star_id
	end)
	return starInfo
end

--获取点亮数量
function M:getStarLightNumber(star_id)
	for i, v in pairs(self.m_fates) do
		if i == tostring(star_id) then
			local heros = v.heros or {}
			local hero_lenght = 0
			for i, v in pairs(heros) do
				hero_lenght = hero_lenght + 1
			end
			return hero_lenght
		end
	end
	return 0
end

--获取当前点亮英雄数组
function M:getStarData(star_id)
	for i, v in pairs(self.m_fates) do
		if tonumber(i) == star_id then
			return v
		end
	end
	return {}
end

--获取材料卡消耗本卡
function M:getEvoSixHeroList(hero_id)
	local evo_isSix_hero = {}
	local all_hero = self:getAllHeroIds()
	for i, v in pairs(all_hero) do
		local data, cfg = UserDataManager.hero_data:getHeroDataById(v)
		if data.evo == 6 and data.id == hero_id then
			table.insert(evo_isSix_hero,{data = data,cfg = cfg})
		end
	end
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
	local universal = nil
	if hero_cfg then
		if hero_cfg.islink and hero_cfg.islink > 0 then
			if hero_cfg.universal and hero_cfg.universal > 0 then
				if hero_cfg.high_gacha_time and hero_cfg.high_gacha_time ~= "" then
					local high_gacha_time = string.split(hero_cfg.high_gacha_time,"~")
					local start_time = high_gacha_time[1] or ""
					local end_time = high_gacha_time[2] or ""
					if start_time ~= "" and end_time ~= "" then
						local start_ts = GameUtil:stringToTimesTamp(start_time)
						local end_ts = GameUtil:stringToTimesTamp(end_time)
						local cur_time = UserDataManager:getServerTime()
						if cur_time < start_ts or cur_time > end_ts then
							universal = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM, hero_cfg.universal, 2})
						end
					end
				end
			end
		end
	end
	return evo_isSix_hero, universal
end

--获取化星消耗
function M:getFateCost(hero_id)
	local fate_common = ConfigManager:getCfgByName("fate_common")
	return fate_common[hero_id].fate_cost or {}
end

--设定显示指定英雄
function M:showSelectHero(hero_id,hero_data)
	for i, v in pairs(hero_data) do
		if v.data.id == hero_id then
			self.currentHeroIndex = i
			self.current_data = v --有指定英雄时设定指定英雄信息
			self.current_hero_data = v.data
			self.current_hero_cfg = v.cfg
		end
	end
end

--获取皮肤信息
function M:getHeroSkin(skin_id)
	local hero_skin = ConfigManager:getCfgByName("hero_skin")
	return hero_skin[skin_id].hero_spine
end

--获取星辰icon
function M:getStarIcon(hero_id)
	local fate_star = ConfigManager:getCfgByName("fate_star")
	for i, v in pairs(fate_star) do
		for hero_group_i, hero_group_v in pairs(v.hero_group) do
			if hero_group_v == hero_id then
				return v.star_icon
			end
		end
	end
	return 0
end

function M:getFateUnlockNums()
	local unlock_nums = ConfigManager:getCommonValueById(723, 4)
	return unlock_nums
end

function M:getFateNums()
	local fate_nums = 0
	for i, v in pairs(self.m_fates) do
		fate_nums = table.nums(v.heros) + fate_nums
	end
	return fate_nums
end

function M:canFateBuilding()
	return self:getFateNums() >= self:getFateUnlockNums()
end

function M:getCurFateBuildingCfgByFloor(floor_id)
	if self.m_fate_building_cfg[floor_id] then
		return self.m_fate_building_cfg[floor_id]
	end
	return nil
end

function M:getFateBuildAttrByCurFloor(cur_floor)
	if cur_floor and cur_floor > 0 then
		local cur_build_cfg = self:getCurFateBuildingCfgByFloor(cur_floor)
		if cur_build_cfg and cur_build_cfg.attr then
			return cur_build_cfg.attr
		end
	end
	return {}
end

function M:getMasterNodeIsLock()
	local node_status = {}
	local building_data =  UserDataManager.m_fate_building
	local cur_floor = building_data.lv or 0
	local fate_master_cfg = ConfigManager:getCfgByName("fate_master") or {}
	for i = 1, #fate_master_cfg do
		local break_value = fate_master_cfg[i]["break"]
		node_status[i] = cur_floor >= break_value and 0 or break_value
	end
	return node_status
end

function M:transHeroData(h_data, h_cfg)
	local data = nil
	if h_data and h_cfg then
		data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, h_data.id, 0})
		data.quality = h_data.evo
		data.card_id = h_data.id
		data.hero_data = h_data
	end
	return data
end

function M:getMasterSlotNumsByIndex(index)
	local fate_master_cfg = ConfigManager:getCfgByName("fate_master") or {}
	local cur_cfg = fate_master_cfg[index] or {}
	local slot = cur_cfg["slot"] or 1
	return slot
end

function M:getMasterSlotAddNumsByIndex(index, is_same_role_type)
	local fate_master_cfg = ConfigManager:getCfgByName("fate_master") or {}
	local cur_cfg = fate_master_cfg[index] or {}
	local add_nums = 0
	if is_same_role_type then
		add_nums = cur_cfg.master_attr1 or 0
	else
		add_nums = cur_cfg.master_attr2 or 0
	end
	return math.floor(add_nums * 100) 
end

function M:getHeroDataById(hero_data, hero_cfg)
	local itemData = RewardUtil:getHeroConfigData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_cfg.id, 1})
	itemData.quality = hero_data.evo
	itemData.oid = hero_data.oid
	return itemData
end

return M
