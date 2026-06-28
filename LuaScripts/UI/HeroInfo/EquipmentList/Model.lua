local M = class("EquipmentListModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_pos = self.m_params.pos --当前槽位索引
	self.m_heroid = self.m_params.heroid --当前英雄id
	self.m_herodata, self.herocfg =	self:getHero()
	self.m_eqp_data, self.m_eqp_cfg = self:getCurEquip()
	self.m_callback = self.m_params.callback
	self:initData()
end

function M:initData()
	self.m_show_equips = {}
	local equip_ids = UserDataManager.equip_data:getEquipsId()
	local hero_ids = UserDataManager.hero_data:getHerosId()
	for k, v in pairs(hero_ids) do
		if v ~= self.m_heroid then
			local hero_data, hero_cfg = self:getHeroById(v)
			local equips = hero_data.equips or {}
			local equip_data = equips[tostring(self.m_pos)]
			if equip_data then
				local equip_cfg = UserDataManager.equip_data:getEquipConfigByCid(equip_data.id)
				if equip_cfg.type == 0 or equip_cfg.type == self.herocfg.type then
					equip_data.owner = v
					table.insert(self.m_show_equips, equip_data)
				end
			end
		end
	end
	--获取当前槽位对应的装备列表 （剔除不同职业不同槽位以及自己）
	for k, v in pairs(equip_ids) do
		local data, cof = self:getEquipById(v)
		if cof.pos == self.m_pos and data.oid ~= self.m_cur_eqp_id then 
			if cof.type == 0 or cof.type == self.herocfg.type then
				table.insert(self.m_show_equips, data)	
			end
		end
	end
end

function M:getShowEquipCount()
	return self.m_show_equips
end

function M:getShowEquipDataByIndex(index)
	return self.m_show_equips[index]
end

function M:getCurEquip()
	if not self.m_herodata then
		Logger.logErrorAlways(string.format("hero_id == %s , pos == %s hero_data==nil",tostring(self.m_heroid),tostring(self.m_pos)))
		return nil, nil
	end
	local equips = self.m_herodata.equips
	self.m_equip_data = equips[tostring(self.m_pos)]
	if self.m_equip_data then
		local cfg =	UserDataManager.equip_data:getEquipConfigByCid(self.m_equip_data.id) 
		return self.m_equip_data, cfg
	end
	return nil, nil
end

function M:getEquipById(id)
	return UserDataManager.equip_data:getEquipDataById(id)
end

--获取英雄信息
function M:getHero()
	return self:getHeroById(self.m_heroid)
end

function M:getHeroById(id)
	return UserDataManager.hero_data:getHeroDataById(id)
end

function M:getImgById(id)
	local data, cfg = self:getHeroById(id)
	return data
end

function M:checkHeroRace()
	if self.herocfg then
		return self.herocfg.race
	end
	return 0
end

function M:getCurEqpCombat()
	local data, cfg = self:getCurEquip()
	local attrs = UserDataManager:appendAttrs(UserDataManager:getEquipAttrsByData(data, cfg, self.herocfg.race))
	local combat = UserDataManager:computeEquipCombat(attrs)
	local affix_combat = math.ceil(UserDataManager:getEquipAffixCombat(data)) 
	return combat + affix_combat
end

--装备专属词缀需要的英雄
function M:checkAffixAttr(equip_data)
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	for k,v in pairs(equip_data.affix) do
		local affix_cfg = equip_affix_tab[v.id]
		if affix_cfg.unique == 1 then
			return affix_cfg.unique_hero
		end
	end
	return 0
end

function M:getAffixCombat(equip_data)
	
end

function M:getHeroNameByCid(id)
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
	if hero_cfg then
		return Language:getTextByKey(hero_cfg.name)		
	end
	return id
end

return M
