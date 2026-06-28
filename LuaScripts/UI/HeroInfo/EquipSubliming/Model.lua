local M = class("EquipSublimingModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.hero_id = self.m_params.hero_oid
	self.m_pos =  self.m_params.pos
end

function M:getEqpData()
	local h_data, h_cfg =  UserDataManager.hero_data:getHeroDataById(self.hero_id)
	local equips = h_data.equips
	self.m_equip_data = equips[tostring(self.m_pos)]
	local cfg =	UserDataManager.equip_data:getEquipConfigByCid(self.m_equip_data.id) 
	return self.m_equip_data, cfg
end

function M:activateRace()
	local h_data, h_cfg =  UserDataManager.hero_data:getHeroDataById(self.hero_id)
	local e_data, e_cfg = self:getEqpData()
	if h_cfg and e_data and h_cfg.race == e_data.race then
		return true
	end
	return false
end

function M:getAttr()
	local cur_data, cur_cfg = self:getEqpData()
	local cur_attr = UserDataManager:getEquipAttrsByData({lv = 0, race = 0}, cur_cfg, 0)
	return cur_attr
end

function M:getNextAttr(kk)
	local cur_data, cur_cfg = self:getEqpData()
	local cfg =	UserDataManager.equip_data:getEquipConfigByCid(cur_cfg.evolution_id) 
	local next_attr = UserDataManager:getEquipAttrsByData({lv = 0, race = 0}, cfg, 0)
	for k,v in pairs(next_attr) do
		if v[1] == kk then
			return v
		end
	end
	return {0}
end

function M:getCombat()
	local cur_data, cur_cfg = self:getEqpData()
	local cur_attr = UserDataManager:getEquipAttrsByData({lv = 0, race = 0}, cur_cfg, 0)
	local next_cfg =	UserDataManager.equip_data:getEquipConfigByCid(cur_cfg.evolution_id) 
	local next_attr = UserDataManager:getEquipAttrsByData({lv = 0, race = 0}, next_cfg, 0)
	local data1 = {}
	local data2 = {}
	for i,v in ipairs(cur_attr) do
		local key = GameUtil:getAttrsKey(v[1])
		data1[key] = v[2]
	end
	for i,v in ipairs(next_attr) do
		local key = GameUtil:getAttrsKey(v[1])
		data2[key] = v[2]
	end
	local cur_comb = UserDataManager:computeEquipCombat(data1)
	local next_comb = UserDataManager:computeEquipCombat(data2)
	return cur_comb, next_comb
end

--升阶消耗
function M:getConsume()
	local c_id = self.m_equip_data.id
	local tab = ConfigManager:getCfgByName("equip_detail")
	local next_id = tab[c_id].evolution_id
	local next_cons = tab[c_id].evolution_cost
	return next_cons
end




return M
