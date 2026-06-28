------------ ConfigManager
local M = {}
M.CONFIG_PATH = "LuaScripts/DataCenter/Config/" -- 配置路径
M.BATTLE_CONFIG_PATH = "LuaScripts/Battle/DataCenter/Config/" -- 战斗配置路径
local __stage_battle_name = {"stage_battle", "stage_battle2", "stage_battle3"}
local __active_name = "active"
local __active_addition = {"active_season"}--active表的附加表
function M:init()
	local config_path = M.CONFIG_PATH
    local read_data = io.readfile(config_path .. "game_config_version.txt")
	if read_data then		
        self.m_game_config_version = Json.decode(read_data) or {};
    else
        self.m_game_config_version = {}
    end
	self.all_cfg = {}
	self.all_cfg_files = {}
	self.m_stage_battle2_merge = false --是否合并過stage_battle的标识
	self.m_cfg_ref_tab = {}
end

function M:retainCfgByName(key)
	if self.m_cfg_ref_tab[key] == nil then
		self.m_cfg_ref_tab[key] = 0
	end
	self.m_cfg_ref_tab[key] = self.m_cfg_ref_tab[key] + 1
end

function M:releaseCfgByName(key)
	if self.m_cfg_ref_tab[key] then
		self.m_cfg_ref_tab[key] = self.m_cfg_ref_tab[key] - 1
		if self.m_cfg_ref_tab[key] <= 0 then
			local find_cfg_keys = self:findCfgKeys(key)
			if #find_cfg_keys > 0 then
				for k,v in pairs(find_cfg_keys) do
					self:unloadCfg(v[1], v[2])
				end
			else
				self:unloadCfg(key, key)
			end
		end
	end
end

function M:getCfgStageBattle(id)
	if id == nil then
		return nil
	end
	local cfg_tab = self.all_cfg["stage_battle"]
	if cfg_tab ~= nil and cfg_tab[id] ~= nil then
		return cfg_tab[id]
	end
	for i = 1, #__stage_battle_name do
		local mapIndexStr = __stage_battle_name[i].."_mapping_index"
		local battle_map_index = self:getCfgByName(mapIndexStr)
		for k,v in pairs(battle_map_index) do
			if id >= v.min and id <= v.max then
				self:loadCfg("stage_battle", __stage_battle_name[i].."-"..k)
				local data = self.all_cfg["stage_battle"][id]
				if data ~= nil then
					return data
				end
			end
		end
	end


	return nil
end

-- 返回配置表信息
function M:getCfgByName(key, is_init_stage_battle)
	-- body
	if not(is_init_stage_battle) then
		for i = 1, #__stage_battle_name do
			if __stage_battle_name[i] == key then
				return self:getTotalStageBattleConfig()
			end
		end
	end
	if key == __active_name then --附加活动表
		return self:getTotalActiveConfig()
	end
	return self:baseGetCfgByName(key)
end

-- 返回配置表信息  最基本的加载配置，不去做其他处理
function M:baseGetCfgByName(key)
	if self.all_cfg[key] == nil then
		local find_cfg_keys = self:findCfgKeys(key)
		if #find_cfg_keys > 0 then
			for k,v in pairs(find_cfg_keys) do
				self:loadCfg(v[1], v[2])
			end
		else
			self:loadCfg(key, key)
		end
	end
	local cfg_tab = self.all_cfg[key]
	if cfg_tab == nil then
		Logger.logWarningAlways(key, " cfg not found , cfg name is : ")
	end
	return cfg_tab or {}
end

function M:getTotalStageBattleConfig()
	if self.all_cfg.stage_battle and self.m_stage_battle2_merge then
		return self.all_cfg.stage_battle
	end
	
	for i = 1, #__stage_battle_name do
		local stage_cfg_name = __stage_battle_name[i]
		local cur_stage_cfg = self:getCfgByName(stage_cfg_name, true)
		table.merge(self.all_cfg.stage_battle, cur_stage_cfg)
	end
	self.m_stage_battle2_merge = true
	return self.all_cfg.stage_battle
end

function M:getTotalActiveConfig()
	if self.all_cfg.active and self.m_active_merge then
		return self.all_cfg.active
	end
	self:baseGetCfgByName(__active_name)
	for i = 1, #__active_addition do
		local active_cfg_name = __active_addition[i]
		local cur_stage_cfg = self:baseGetCfgByName(active_cfg_name)
		table.merge(self.all_cfg.active, cur_stage_cfg)
	end
	self.m_active_merge = true
	return self.all_cfg.active
end


function M:analysisPreloadCfg()
	 -- 预加载配置
	local preload_cfg = {
		"stage",
		"stage_battle",
		"card_hero",
		"item",
		"skill_detail",
		"hero_detail",
		"book",
		"equip_heroes",
		"hero_upgrade",
		"hero_enumeration",
		"hero_quality",
		"hero_rank",
		"equip_throne_level",
		"equip_throne_inherit",
		"equip_throne_evo",
		"equip_affix",
		"hero_friend",
		"equip_throne",
		"fetters_level",
		"treasure_config",
		"hero_evolution",
		"fate_common",
		"fate_star",
		"hero_fetters",
		"random_disposition",
	}
	local all_preload_cfg = {}
	for k, v in pairs(preload_cfg) do
		local find_cfg_keys = self:findCfgKeys(v)
		if #find_cfg_keys > 0 then
			table.insertto(all_preload_cfg, find_cfg_keys)
		else
			table.insert(all_preload_cfg, {v, v})
		end
	end
	return all_preload_cfg
end

function M:findCfgKeys(cfg_key)
	local find_cfg_keys = {}
	local find_str1 = cfg_key .. "%-"
	local find_str2 = cfg_key .. "%~"
	for k,v in pairs(self.m_game_config_version) do
		local start_idx, _ = string.find(k, find_str1)
		if start_idx == 1 then
			table.insert(find_cfg_keys, {cfg_key, k})
		else
			local start_idx2, _ = string.find(k, find_str2)
			if start_idx2 == 1 then
				table.insert(find_cfg_keys, {cfg_key, k})
			end
		end
	end
	return find_cfg_keys
end 

function M:getCfgPath(load_cfg_name)
	local md5 = self.m_game_config_version[load_cfg_name]
	local path_name = nil
	local file_name = nil
	if Battle.BattleGlobalConfig.BattleConfigName[load_cfg_name] ~= nil then
		if md5 then
			path_name = self.BATTLE_CONFIG_PATH .. load_cfg_name .. "__" .. md5 ..".lua"
			file_name = "Battle.DataCenter.Config.".. load_cfg_name .. "__" .. md5
			if not io.exists(path_name) then
				Logger.logWarningAlways(path_name, "battle cfg md5 file not found : ")
				path_name = self.BATTLE_CONFIG_PATH .. load_cfg_name ..".lua"
				file_name = "Battle.DataCenter.Config.".. load_cfg_name
			end
		else
			path_name = self.BATTLE_CONFIG_PATH .. load_cfg_name ..".lua"
			file_name = "Battle.DataCenter.Config.".. load_cfg_name
		end
	else
		if md5 then
			path_name = self.CONFIG_PATH .. load_cfg_name .. "__" .. md5 ..".lua"
			file_name = "DataCenter.Config.".. load_cfg_name .. "__" .. md5
			if not io.exists(path_name) then
				Logger.logWarningAlways(path_name, "cfg md5 file not found : ")
				path_name = self.CONFIG_PATH .. load_cfg_name ..".lua"
				file_name = "DataCenter.Config.".. load_cfg_name
			end
		else
			path_name = self.CONFIG_PATH .. load_cfg_name ..".lua"
			file_name = "DataCenter.Config.".. load_cfg_name
		end
	end
	return path_name, file_name
end

function M:loadCfg(src_cfg_name, load_cfg_name)
	local md5 = self.m_game_config_version[load_cfg_name]
	local path_name, file_name = self:getCfgPath(load_cfg_name)
	if io.exists(path_name) then
		local cfg_tab = require(file_name)
		table.insert(self.all_cfg_files, file_name)
		if src_cfg_name == load_cfg_name then
			self.all_cfg[src_cfg_name] = cfg_tab or {}
		else
			if self.all_cfg[src_cfg_name] == nil then
				self.all_cfg[src_cfg_name] = {}
			end
			table.merge(self.all_cfg[src_cfg_name], cfg_tab or {})
		end
	else
		Logger.logWarning(md5, "load_cfg_name not found : " .. tostring(load_cfg_name))
	end
end

function M:unloadCfg(src_cfg_name, load_cfg_name)
	local _, file_name = self:getCfgPath(load_cfg_name)
	self.all_cfg[src_cfg_name] = nil
	package.loaded[file_name] = nil
end

function M:resetCfg()
	self.all_cfg = {}
	for k,v in pairs(self.all_cfg_files) do
		package.loaded[v] = nil	
	end
	self.all_cfg_files = {}
	self:init()
end


function M:getBattleCommonValueById(id, default_value, isFix)
	local common = self:getCfgByName("battle_common")
	local common_item = common[id] or {}
	local value = common_item.value or default_value
	if isFix then
		return common_item.value_fix or default_value;
	end
	return value
end


function M:getCommonValueById(id, default_value)
	local common = self:getCfgByName("common")
	local common_item = common[id] or {}
	local value = common_item.value or default_value
	return value
end

function M:getVipValueByKey(key, default_value)
	local vip = self:getCfgByName("vip")
	local vip_lv = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
	local vip_item = vip[vip_lv] or {}
	local value = vip_item[key] or default_value
	return value
end

function M:getQuestLockFlag(stage_id)
	local lock_flag = false
	local lock_text = ""
	local stage = ConfigManager:getCfgByName("stage")
	local cur_stage = UserDataManager:getCurStage()
	stage_id = stage_id or 0
	if cur_stage < stage_id then
    	local stage_item = stage[stage_id]
    	if stage_item then
    		lock_flag = true
			local map_point_name = stage_item.map_point_name or ""
			local name = Language:getTextByKey(map_point_name)
	    	lock_text = Language:getTextByKey("new_str_0059", name)
    	end
	end
	return lock_flag, lock_text
end

function M:getSystemCostValueById(id)
    local system_cost = ConfigManager:getCfgByName("system_cost")
    local system_cost_item = system_cost[id] or {}
    return system_cost_item.cost or {}
end

function M:getTowerStageCfgByRaceAndId(race, id)
	local is_max = false
	local race_tower_stage_item = self:getTowerStageCfgByRace(race)
	if id >= #race_tower_stage_item then
		is_max = true
	end
	local tower_stage_item = race_tower_stage_item[is_max and id or (id + 1)] or {}
	return tower_stage_item, is_max
end

function M:getTowerStageCfgByRace(race)
	local tower_stage = ConfigManager:getCfgByName("tower_stage")
	local race_tower_stage_item = tower_stage[race] or {}
	return race_tower_stage_item
end

function M:getHighArenaCfgByRank(rank)
	rank = rank or -1
	local high_arena = ConfigManager:getCfgByName("high_arena")
	for k, v in pairs(high_arena) do
		if rank >= k and rank <= v.rank_min then
			return v
		end
	end
	return {}
end

function M:getHighArenaCfgByRankMark(rank_mark)
	rank_mark = rank_mark or -1
	local high_arena = ConfigManager:getCfgByName("high_arena")
	for k, v in pairs(high_arena) do
		if (rank_mark ~= 56 and rank_mark == v.rank_mark) or (rank_mark == 56 and k == 100)  then
			return v
		end
	end
	return {}
end

function M:getHuaShanCfgByRankAndVsn(rank, vsn)
	rank = rank or -1
	local high_arena_hslj = ConfigManager:getCfgByName("high_arena_hslj") or {}
	local cur_cfg = high_arena_hslj[vsn] or {}
	for k, v in pairs(cur_cfg) do
		if rank >= k and rank <= v.rank_min then
			return v
		end
	end
	return {}
end

function M:getHuaShanCfgCfgByRankMarkAndVsn(rank_mark, vsn)
	rank_mark = rank_mark or -1
	local high_arena_hslj = ConfigManager:getCfgByName("high_arena_hslj") or {}
	local cur_cfg = high_arena_hslj[vsn] or {}
	for k, v in pairs(cur_cfg) do
		if (rank_mark ~= 56 and rank_mark == v.rank_mark) or (rank_mark == 56 and k == 100)  then
			return v
		end
	end
	return {}
end

function M:getHeroEnumerationUserKeys()
	if self.all_cfg["hero_enumeration_user_keys"] == nil then
		local user_keys = {}
		local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
		for k, v in pairs(hero_enumeration) do
			v.id = k
			user_keys[v.user_key] = v
		end
		self.all_cfg["hero_enumeration_user_keys"] = user_keys
	end
	return self.all_cfg["hero_enumeration_user_keys"]
end

function M:getHeroMaxlv(id)
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
	local tab_ = ConfigManager:getCfgByName("hero_evolution")
	local max_lv = tab_[cfg.max_evo]["level_max"]
	return max_lv
end

function M:getBoxSpecialCfg(id)
	local box_special = ConfigManager:getCfgByName("box_special")
	local box_special_items = box_special[id] or {}
	return box_special_items
end

function M:getPlayerPictureCfg(id)
	local player_picture = ConfigManager:getCfgByName("player_picture")
	local player_picture_item = player_picture[checknumber(id)] or {}
	return player_picture_item
end

function M:getPlayerFrameCfg(id)
	local player_frame = ConfigManager:getCfgByName("player_frame")
	local player_frame_item = player_frame[checknumber(id)] or {}
	return player_frame_item
end

function M:getHeroSkinCfg(id)
	local hero_skin_cfg = ConfigManager:getCfgByName("hero_skin")
	local hero_skin_cfg_item = hero_skin_cfg[checknumber(id)] or {}
	return hero_skin_cfg_item
end

function M:getHeirloomCfg(id)
	local heirloom_cfg = ConfigManager:getCfgByName("heirloom")
	local heirloom_cfg_item = heirloom_cfg[checknumber(id)] or {}
	return heirloom_cfg_item
end

--秘籍和位置对应关系
function M:getMysticTypeByPos(pos)
	return pos
	--local position_types = self:getCommonValueById(368, {})
	--local mystic_type = position_types[pos]
	--return mystic_type
end

--经脉开启条件
function M:getMeridianOpenEvoByPos(pos)
	local open_evos = self:getCommonValueById(369, {})
	local open_evo = open_evos[pos]
	return open_evo or 99
end

--根据当前赛季获取对应的cfg_name表中的cfg_season_key字段数据
function M:getSeasonCfgData(cfg_name, cfg_season_key, default_value)
	local cfg = self:getCfgByName(cfg_name)
	local cur_season = UserDataManager:getCurSeason()
	for i = cur_season, 0, -1 do
		local cur_season_key = tonumber(i)
		if cfg_season_key then
			cur_season_key = cfg_season_key .. cur_season_key
		end
		if cfg and cfg[cur_season_key] then
			return cfg[cur_season_key]
		end
	end
	return default_value and default_value or {}
end

function M:getMedalCfgById(medal_id)
	local cfg = self:getCfgByName("medal") or {}
	if cfg[tonumber(medal_id)] then
		return cfg[tonumber(medal_id)]
	else
		Logger.logError(medal_id, "not found this id in config of medal")
	end
	return nil
end

function M:delete()
	self.all_cfg = {} -- GMP issue_id: afaac04ad9ab57b7324c1b4083beb535
end

return M