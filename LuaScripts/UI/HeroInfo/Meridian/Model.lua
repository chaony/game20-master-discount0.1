local M = class("MeridianModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.exclusive_lv = self.m_params.lv or -1
	self.m_heroid = self.m_params.hero_id
	self.m_eqp_cfg = self:getEquipData()
end

function M:getEquipData()
	local h_data, h_cfg = UserDataManager.hero_data:getHeroDataById(self.m_heroid)
	local tab = ConfigManager:getCfgByName("equip_heroes")
	local e_id = 0
	if h_cfg.equip_heroes_id == 0 then
		e_id = 1
	else
		e_id = h_cfg.equip_heroes_id	
	end
	local cur_eqp = tab[e_id]
	return cur_eqp
end

function M:checkCost()
	local cost_data = nil
	if self.exclusive_lv >= 0 then
		cost_data = self.m_eqp_cfg.level_up[self.exclusive_lv]
	else
		cost_data = self.m_eqp_cfg.level_up[1]	
	end
	return cost_data.levelup_cost
end

function M:activateAttrs()
	return self.m_eqp_cfg.level_up[1].attr
end

function M:checkhaveCfg()
	local h_data, h_cfg = UserDataManager.hero_data:getHeroDataById(self.m_heroid)
	if h_cfg.equip_heroes_id == nil or  h_cfg.equip_heroes_id == 0 then 
		return false
	end
	return true
end


return M
