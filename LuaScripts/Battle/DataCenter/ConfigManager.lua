------------ ConfigManager
local M = {}
M.CONFIG_PATH = "LuaScripts/DataCenter/Config/" -- 配置路径
M.BATTLE_CONFIG_PATH = "LuaScripts/Battle/DataCenter/Config/" -- 战斗配置路径

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
end

-- 返回配置表信息
function M:getCfgByName(key)
	-- body
	if self.all_cfg[key] == nil then
		local find_cfg_keys = self:findCfgKeys(key)
		if #find_cfg_keys > 0 then
			local cfg = {}
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


function M:analysisPreloadCfg()
	 -- 预加载配置
	local preload_cfg = {
		"stage",
		"stage_battle",
		"card_hero",
		"item",
		"skill_detail",
		"hero_detail",
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

function M:loadCfg(src_cfg_name, load_cfg_name)
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

function M:getTowerStageActiveCfgByVersion(version)
	local tower_stage = ConfigManager:getCfgByName("tower_stage_active")
	local active_tower_stage_item = tower_stage[version] or {}
	return active_tower_stage_item
end

function M:getTowerStageCfgActiveByVersionAndId(version, id)
	local is_max = false
	local active_tower_stage_item = self:getTowerStageActiveCfgByVersion(version)
	if id >= #active_tower_stage_item then
		is_max = true
	end
	local tower_stage_item = active_tower_stage_item[is_max and id or (id + 1)] or {}
	return tower_stage_item, is_max
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

function M:getHeroSkinCfg(id)
	local hero_skin_cfg = ConfigManager:getCfgByName("hero_skin")
	local hero_skin_cfg_item = hero_skin_cfg[checknumber(id)] or {}
	return hero_skin_cfg_item
end

--秘籍和位置对应关系
function M:getMysticTypeByPos(pos)
	--local position_types = self:getCommonValueById(368, {})
	--local mystic_type = position_types[pos]
	--return mystic_type
	return pos
end

--经脉开启条件
function M:getMeridianOpenEvoByPos(pos)
	local open_evos = self:getCommonValueById(369, {})
	local open_evo = open_evos[pos]
	return open_evo or 99
end

function M:delete()
	self.all_cfg = {}
end

return M