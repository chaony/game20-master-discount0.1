local M = class("EquipmentPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_look_model = self.m_params.look_model or 0
	self.m_pos = self.m_params.pos or 1 --当前槽位索引
	self.m_callback = self.m_params.callback
	self.m_is_show_smelt_btn = false
	if self.m_look_model == 1 then -- 查看其他人
		self.m_equip_data = self.m_params.equip_data
		self.c_hero = self.m_params.c_hero 
	elseif self.m_look_model == 2 then -- 装备购买
		self.m_equip_cfg_id = self.m_params.equip_cfg_id
		self.m_hero_ids = self.m_params.hero_ids
		self.m_cost = self.m_params.cost
		self.m_ok_call_func = self.m_params.ok_call_func
		local cfg = UserDataManager.equip_data:getEquipConfigByCid(self.m_equip_cfg_id)
		self.m_pos = cfg.pos or 1 
		self.m_race = self.m_params.race or 0
	elseif self.m_look_model == 3 then -- 查看不处理
		if self.m_params.affix and self.m_params.affix == true then --新类型-带词缀装备
			self.m_equip_data = self.m_params.equip_cfg
			self.m_pos = self.m_equip_data.item_cfg.pos or 1 
			self.m_equip_cfg_id = self.m_params.equip_cfg.equip_id
		else
			self.m_equip_cfg_id = self.m_params.equip_cfg_id
			local cfg = UserDataManager.equip_data:getEquipConfigByCid(self.m_equip_cfg_id)
			self.m_pos = cfg.pos or 1 
		end
	    self.m_race = self.m_params.race or 0
	else
		self.m_heroid = self.m_params.heroid
		local cfg = nil
		if self.m_heroid then
			self.m_herodata, self.herocfg =	self:getHeroById()	--当前英雄
			local equips = self.m_herodata.equips
			self.m_equip_data = equips[tostring(self.m_pos)]
			self.m_eqp_id = self.m_equip_data.oid
			cfg =  UserDataManager.equip_data:getEquipConfigByCid(self.m_equip_data.id)
		else
			self.m_eqp_id = self.m_params.equip_id 
			self.m_equip_data, cfg = UserDataManager.equip_data:getEquipDataById(self.m_eqp_id)
			self.m_look_model = 3
			self.m_equip_cfg_id = self.m_equip_data.id
			self.m_pos = cfg.pos or 1 
		end
		local quality = cfg.quality
		local need_quality = ConfigManager:getCommonValueById(513,8)
		if quality >= need_quality then
			self.m_is_show_smelt_btn = true
		end
	end
	self.m_show_buy_btn = self.m_params.show_buy_btn
	if self.m_show_buy_btn == nil then
		self.m_show_buy_btn = true
	end
	if self.m_params.hide_btns == nil then
		self.m_hide_btns = true
	else
		self.m_hide_btns = self.m_params.hide_btns
	end

	self.m_isToday = self.m_params.isToday
	self.m_today_text = self.m_params.today_text or Language:getTextByKey("new_str_0910")
	self.m_today_btn_value = self.m_params.today_btn_value
end

function M:updateCurEquip()
	if self.m_heroid then
		self.m_herodata, self.herocfg =	self:getHeroById()	--当前英雄
		local equips = self.m_herodata.equips
		self.m_equip_data = equips[tostring(self.m_pos)]
		self.m_eqp_id = self.m_equip_data.oid
	else
		self.m_eqp_id = self.m_params.equip_id
	end
end

function M:getEquipData()
	if self.m_look_model == 1 then
		local cfg = UserDataManager.equip_data:getEquipConfigByCid(self.m_equip_data.id)
		return self.m_equip_data, cfg
	elseif self.m_look_model == 2 or self.m_look_model == 3 then
		local cfg = UserDataManager.equip_data:getEquipConfigByCid(self.m_equip_cfg_id)
		return nil, cfg
	else
		if self.m_equip_data then
			local cfg = UserDataManager.equip_data:getEquipConfigByCid(self.m_equip_data.id)
			return self.m_equip_data, cfg
		else
			return UserDataManager.equip_data:getEquipDataById(self.m_eqp_id) 
		end
	end
end

function M:getHerosLookData()
	local show_data = {}
	for i,v in ipairs(self.m_hero_ids or {}) do
		local data = UserDataManager.hero_data:getHeroDataById(v)
		table.insert(show_data, {RewardUtil.REWARD_TYPE_KEYS.HEROS, data.id, 1, v})
	end
	return show_data
end

--获取英雄信息
function M:getHeroById()
	if self.m_look_model == 1 then
		if self.c_hero then
			local c_cfg = UserDataManager.hero_data:getHeroConfigByCid(self.c_hero.id)
			return self.c_hero, c_cfg
		else
			return nil, nil	
		end
	end
	return UserDataManager.hero_data:getHeroDataById(self.m_heroid)
end

--是否激活种族
function M:activateRace()
	local data, cfg = self:getEquipData()
	if self.herocfg and data and self.herocfg.race == data.race then
		return true
	end
	return false
end

--加成数据 -- 种族+强化
function M:getRaceNum(num,attr_key)
	local race_add = ConfigManager:getCommonValueById(45)
	local book_rate = self:equipBookAttrRatioById(attr_key)
	local data, cfg = self:getEquipData()
	local lv_growth_rate = cfg.lv_growth_rate or 0
	local equip_lv
	local god_add_value = 0
	local attr_id = GameUtil:getAttrsId(attr_key)
	if cfg.quality >= 12 then
		equip_lv = 0
		--神兵从配置的属性上，根据强化等级增加
		for k,v in pairs(cfg.attr) do
			if attr_id == v[1] then
				god_add_value = lv_growth_rate*(data.lv)/100 * v[2]
				if attr_id == 908 or attr_id == 909 then  --特殊处理  没有一个可靠的配置去确定
					god_add_value = god_add_value * 100
				end
			end
		end
	else
		equip_lv = data.lv or 0
	end
	local sum_rate = (lv_growth_rate*(equip_lv)/100 + (race_add/100)+ (book_rate/100))
	local add_num = (num ) * sum_rate +god_add_value
	add_num = math.floor(add_num * 10 + 0.5)/10
	return GameUtil:formatNum(add_num)
end

--加成数据 -- 强化
function M:getLvUpNum(num,attr_key)
	local data, cfg = self:getEquipData()
	if data == nil then
		return 0
	end
	local book_rate = self:equipBookAttrRatioById(attr_key)
	local lv_growth_rate = cfg.lv_growth_rate or 0
	local equip_lv
	local god_add_value = 0
	local attr_id = GameUtil:getAttrsId(attr_key)
	if cfg.quality >= 12 then
		equip_lv = 0
		for k,v in pairs(cfg.attr) do
			if attr_id == v[1] then
				god_add_value = lv_growth_rate*(data.lv)/100 * v[2]
				if attr_id == 908 or attr_id == 909 then
					god_add_value = god_add_value * 100 	
				end
			end
		end
	else
		equip_lv = data.lv or 0
	end
	local sum_rate = (lv_growth_rate*(equip_lv)/100+ (book_rate/100))
	local add_num = (num) * sum_rate
	add_num = math.floor(add_num * 10 + 0.5)/10 + god_add_value
	return GameUtil:formatNum(add_num)
end

function M:getAllHero()
	return UserDataManager.hero_data:getHerosData()
end

function M:getEquipLevelUpRedPoint()
	local red_flag = false
	local eq_data, eq_cfg = self:getEquipData()
	if eq_data and eq_cfg then
		local ids = UserDataManager.equip_data:getEquipsId()
		local all_exp = 0
		for k,v in pairs(ids) do
			local data, cfg = UserDataManager.equip_data:getEquipDataById(v)
			all_exp = all_exp + cfg.add_exp
		end
		if eq_data.lv < eq_cfg.lv_limit then
			local need_exp =  GameUtil:getEquipUpGrade(eq_cfg.quality,eq_data.lv, eq_cfg.pos)--本次升级需要的经验
			red_flag = all_exp >= need_exp
		end
	end
	return red_flag
end

function M:canRec()
	if self.m_look_model == 0 and  self.m_equip_data then
		local cfg = UserDataManager.equip_data:getEquipConfigByCid(self.m_equip_data.id)
		--if cfg.quality >= 9 then
			if self:isRace() == true or self:canLevelUp() == true then
				return true
			end
		--end 
	end
	return false
end

function M:isRace()
	if self.m_look_model == 0 and  self.m_equip_data then
		if self.m_equip_data.race > 0 then
			return true
		end 
	end
	return false
end

function M:canLevelUp()
	local eq_data, eq_cfg = self:getEquipData()
	if next(eq_cfg.evolution_cost) ~= nil then
		return true
	else
		return false
	end	
end

function M:getPolishedAttrs()
	local e_data,e_cfg = self:getEquipData()
	if self.m_look_model == 3 and self.m_params.affix == true then -- 查看不处理
		e_data = {affix = {{id = self.m_equip_data.affix_id}}}
	end
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	local affix_attrs = {} --洗练属性
	local affix_ts = nil --专属属性
	if e_data and e_data.affix then
		for k,v in pairs(e_data.affix) do
			local affix_cfg = equip_affix_tab[v.id]
			if affix_cfg == nil then
				break
			end
			if affix_cfg.unique == 1 then
				affix_ts = {data = v, cfg = affix_cfg} 
			else
				local parm = {}
				parm.data = v
				parm.index = tonumber(k)
				if e_cfg.quality == 8 then
					parm.cfg = affix_cfg.effect[1].random_value[0]
				elseif 	e_cfg.quality >= 9 and e_cfg.quality <= 12 then
					parm.cfg = affix_cfg.effect[1].random_value[e_cfg.quality]
				else
					parm.cfg = affix_cfg.effect[1].random_value[0]	
				end
				table.insert(affix_attrs, parm)
			end
		end
	end
	return affix_attrs,affix_ts
end

function M:activateUniqueHero()
	local e_data,e_cfg = self:getEquipData()
	local active_hero_id = 0
	if self.m_look_model == 1 and self.c_hero then
		active_hero_id = self.c_hero.id
	elseif self.herocfg then
		active_hero_id = self.herocfg.id
	end
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	if e_data and e_data.affix then
		for k,v in pairs(e_data.affix) do
			local affix_cfg = equip_affix_tab[v.id]
			if affix_cfg.unique == 1 then
				if active_hero_id == affix_cfg.unique_hero or affix_cfg.unique_hero == 0 then
					return true
				end
			end
		end
	end
	return false
end

--装备图鉴基础属性
function M:equipBookAttrById(attr_key)
	if self.m_look_model == 1 then -- 查看其他人
		return 0
	elseif self.m_look_model == 2 then -- 装备购买
		return 0
	elseif self.m_look_model == 3 then -- 查看
		return 0
	else
		if self.m_heroid then 
			local eqp_data, eqp_cfg = self:getEquipData()
			local attr_id = GameUtil:getAttrsId(attr_key)
			return UserDataManager:equipBookAttrById(eqp_cfg,attr_id,true)
		end	
	end
	return 0
end

----装备图鉴加成属性比例
function M:equipBookAttrRatioById(attr_key) 
	if self.m_look_model == 1 then -- 查看其他人
		return 0
	elseif self.m_look_model == 2 then -- 装备购买
		return 0
	elseif self.m_look_model == 3 then -- 查看
		return 0
	else
		if self.m_heroid then 
			local eqp_data, eqp_cfg = self:getEquipData()
			local attr_id = GameUtil:getAttrsId(attr_key)
			return UserDataManager:equipBookAttrRatioById(eqp_cfg,attr_id,true) + UserDataManager:equipweaponAttrRatioById(eqp_cfg,attr_id,true)
		end	
	end
	return 0
end

--获取装备的基础属性
function M:getEquipBaseAttrs(equip_data, equip_cfg, hero_race)
	if self.m_look_model == 1 then -- 查看其他人
		return UserDataManager:getEquipAttrsByData(equip_data, equip_cfg,hero_race)
	elseif self.m_look_model == 2 then -- 装备购买
		return UserDataManager:getEquipAttrsByData(equip_data, equip_cfg,hero_race)
	elseif self.m_look_model == 3 then -- 查看
		return UserDataManager:getEquipAttrsByData(equip_data, equip_cfg,hero_race)
	else
		if self.m_heroid then 
			local attrs = {}
			if equip_data and equip_cfg then
				local equip_lv = equip_data.lv or 0
				local lv_growth_rate = equip_cfg.lv_growth_rate or 0
				local race = equip_data.race or 0
				local race_value = ConfigManager:getCommonValueById(45, 0)
				local race_rate = 0
				if hero_race == race then
					race_rate = race > 0 and race_value or 0
				end
				local equip_attrs = UserDataManager:getEquipBookAttrNum(equip_cfg, true, true)
				--local equipweapon_attrs = UserDataManager:getEquipWeaponAttrNum(equip_cfg, true, true)
				local attr = equip_cfg.attr or {}
				local merge_attr = UserDataManager:AttrMergeFoEquip(attr, equip_attrs)
				--local merge_attr = UserDataManager:AttrMergeFoEquip(merge_attr1, equipweapon_attrs)
				for attr_k,attr_v in pairs(merge_attr) do
					local attr_index = attr_v[1] or 0
					local attr_value = attr_v[2] or 0
					table.insert(attrs,{attr_index, (attr_value)})
				end
			end
			return attrs
		else
			return UserDataManager:getEquipAttrsByData(equip_data, equip_cfg,hero_race)
		end	
	end

end

return M
