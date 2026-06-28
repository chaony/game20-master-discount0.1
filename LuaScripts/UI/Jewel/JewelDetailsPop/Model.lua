local M = class("JewelDetailsPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_jewel = {id = self.m_params.id, evo = self.m_params.evo, awaken = self.m_params.awaken}
	self.m_jewel_cfg = UserDataManager.jewel_data:getDetailCfg(self.m_params.id)
end

function M:updateJewelEvo(id, evo)
	if evo then
		self.m_jewel.evo = evo
	end
end

function M:updateJewelAwaken(id, awaken)
	if awaken then
		self.m_jewel.awaken = awaken
	end
end

--返回当前属性，下级属性，状态(0可升星，1可觉醒，2已觉醒)
function M:getCfg(id, evo, awaken)
	local cur_cfg, next_cfg, state = UserDataManager.jewel_data:getAttrCfg(id, evo, awaken)
	return cur_cfg, next_cfg, state
	--[[if awaken == 1 then
		local awaken_cfg = self:getAwakenCfg(id)
		return awaken_cfg, nil, 2
	end
	local evo_cfg = self:getEvoCfg(id, evo)
	local next_evo_cfg = self:getEvoCfg(id, evo + 1)
	if next_evo_cfg == nil then
		local awaken_cfg = self:getAwakenCfg(id)
		return evo_cfg, awaken_cfg, 1
	end
	return evo_cfg, next_evo_cfg, 0]]--
end

--属性加成
function M:getAttrs(cur_attrs, next_attrs)
	local attrs = {} --attr_id, attr_value, attr_add_value
	if cur_attrs == nil then
		local temp_attrs = UserDataManager:newAppendAttrs(next_attrs)
		for i, v in pairs(temp_attrs) do
			table.insert(attrs, { id = i, value = 0, add_value = v})
		end
		return attrs
	end
	if next_attrs == nil then
		local temp_attrs = UserDataManager:newAppendAttrs(cur_attrs)
		for k, v in pairs(temp_attrs) do
			table.insert(attrs, { id = k, value = v, add_value = 0})
		end
		return attrs
	end
	local temp_attrs = UserDataManager:newAppendAttrs(cur_attrs)
	local temp_attrs2 = UserDataManager:newAppendAttrs(next_attrs)
	for k, v in pairs(temp_attrs) do
		local value = temp_attrs2[k] or 0
		if value == 0 then
			table.insert(attrs, { id = k, value = v, add_value = 0})
		else
			table.insert(attrs, { id = k, value = v, add_value = value})
			--table.insert(attrs, { id = k, value = v, add_value = value - v})
		end
	end
	--添加cur_attrs中没有，但next_attrs中有的属性
	for k, v in pairs(temp_attrs2) do
		local value = temp_attrs[k]
		if value == nil then
			table.insert(attrs, { id = k, value = 0, add_value = v})
		end
	end
	return attrs
end

--特权加成
function M:getPrivilege(cur_effect_id, next_effect_id)
	local effect_tab = ConfigManager:getCfgByName("jewel_effect")
	local cur_effect = effect_tab[cur_effect_id]
	if next_effect_id then
		local next_effect = effect_tab[next_effect_id]
		return cur_effect.icon, cur_effect.desc, next_effect.desc
	end
	return cur_effect.icon, cur_effect.desc, nil
end

--计算战力
function M:getCombat(cfg)
	local attrs = UserDataManager:appendAttrs(cfg.attrs)
	local value = UserDataManager:computeAttrsCombat(attrs)
	if cfg.combat then
		value = value + cfg.combat
	end
	value = math.ceil(value)
	return value
end

return M