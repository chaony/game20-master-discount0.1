------------ ConfigManager
local M = {}

function M:init()
	self.m_game_config_version = {}
	self.all_cfg = {}
	self.all_cfg_files = {}
end


-- 返回配置表信息
function M:getCfgByName(key)
	-- body
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
	return self.all_cfg[key]
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
	local file_name = "Battle.DataCenter.Config.".. load_cfg_name
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


function M:getHeroSkinCfg(id)
	local hero_skin_cfg = ConfigManager:getCfgByName("hero_skin")
	local hero_skin_cfg_item = hero_skin_cfg[checknumber(id)] or {}
	return hero_skin_cfg_item
end


function M:delete()
	self.all_cfg = nil
end

return M
