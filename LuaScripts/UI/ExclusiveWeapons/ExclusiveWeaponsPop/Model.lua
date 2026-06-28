local M = class("ExclusiveWeaponsPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"
	self:getData()
end

function M:onEnter()
	self.m_heroid = self.m_params.hero_id
	self.m_eqp_cfg = self:getEquipData()
	self.m_eqp_lv = self.hero_data.sig.lv or 0
end

function M:getEqpLv()
	
end

function M:getEquipData()
	self.hero_data, self.hero_cfg = UserDataManager.hero_data:getHeroDataById(self.m_heroid)
	self.exclusive_lv = self.hero_data.sig.lv or 0
	local tab = ConfigManager:getCfgByName("equip_heroes")
	local e_id = 0
	if self.hero_cfg.equip_heroes_id == 0 then
		e_id = 1
	else
		e_id = self.hero_cfg.equip_heroes_id	
	end
	local cur_eqp = tab[e_id]
	return cur_eqp
end



--战力
function M:getCombat()
	return 0
end

--属性
function M:getAttrs()
	return self.m_eqp_cfg.level_up[self.exclusive_lv].attr
end


--专属技能
function M:getExclusiveSkill()
	return {}
end

--专属装备描述
function M:getExclusiveDesc()
	return ""
end

return M
