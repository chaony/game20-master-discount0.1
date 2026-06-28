---@class MeridianListModel:OODataBase
local M = class("MeridianListModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.is_replace=self.m_params.is_replace
	self.m_pos = self.m_params.pos --当前槽位索引
	self.m_heroid = self.m_params.heroid --当前英雄id
	self.m_herodata, self.herocfg =	self:getHero()
	self.m_eqp_data, self.m_eqp_cfg = self:getCurEquip()
	self.m_mystic_type = 0
	self.m_slot_type = self:meridianShowTypeByID(self.m_pos)
	if self.m_eqp_cfg then
		self.m_mystic_type = self.m_eqp_cfg.type
	end
	self.m_callback = self.m_params.callback
	self:initData()
end

function M:initData()
	self.m_show_equips = {}
	local equip_ids = UserDataManager.mystic_data:getMysticesId()
	local hero_ids = UserDataManager.hero_data:getHerosId()

	local mystic_data=nil
	--for k, v in pairs(hero_ids) do
	--	if v ~= self.m_heroid then
	--		local hero_data, hero_cfg = self:getHeroById(v)
	--		local mystics = hero_data.mystics or {}
	--		for m, id in pairs(mystics) do
	--			mystic_data=UserDataManager.mystic_data:getMysticDataById(id)
	--			mystic_data=table.copy(mystic_data)
	--			mystic_data.owner = v
	--			mystic_data.recommend = self:checkMysticBatterThenWear(id) == true and 1 or 0
	--			local cfg = UserDataManager.mystic_data:getMysticConfigByCid(id)
	--			if cfg and self.m_slot_type > 0 and cfg.type == self.m_slot_type then
	--				self:Add2Show_equips(mystic_data,true)
	--			elseif self.m_slot_type == 0 and cfg.type ~= 3 then
	--				self:Add2Show_equips(mystic_data,true)
	--			end
	--		end
	--	end
	--end
	
	local own_mystic = {} -- 已装备在当前英雄身上的秘籍配置id
	local hero_data, hero_cfg = self:getHeroById(self.m_heroid)
	local mystics = hero_data.mystics or {}
	for i, id in pairs(mystics) do
		own_mystic[id] = true
	end
	local mystic_tab = {}
	for i, v in pairs(equip_ids) do
		local data, cof = self:getEquipById(v)
		data.recommend = self:checkMysticBatterThenWear(data.id) == true and 1 or 0
		--if not own_mystic[data.id] then   -- 排除和自身装备相同配置id的秘籍
		--	mystic_tab[data.id] = data  -- 每个配置id的秘籍只留一本
		--end
		mystic_tab[data.id] = data
	end
	local equipedNum=0
	for i, v in pairs(mystic_tab) do
		if i==193005 then
			Logger.log("sdds")
		end
		if not self:isContainOwnHero(v.heros) then
			local data, cfg = UserDataManager.mystic_data:getMysticDataById(v.id)
			equipedNum=0
			if v.heros~=nil then
				equipedNum=table.nums(v.heros)
			end
			if i==193005 then
				Logger.log("sdds")
			end
			if self.m_slot_type > 0 and  cfg.type == self.m_slot_type then
				self:Add2Show_equips(v,equipedNum)
			elseif self.m_slot_type == 0 and cfg.type ~= 3 then
				self:Add2Show_equips(v,equipedNum)
			end
		end
	end
	self:sortAllMystic() -- 秘籍排序
end

function M:isContainOwnHero(heros)
	if heros then
		for i, hero_oid in pairs(heros) do
			if hero_oid==self.m_heroid  then
				return true
			end
		end
		return false
	else
		return false
	end
end

function M:Add2Show_equips(mysticData,equipedNum)
	if not self:judgeAdded(mysticData.id) then
		table.insert(self.m_show_equips, mysticData)
		mysticData.equipedNum=equipedNum
		mysticData.canEquipMax=self:getCanEquipCountByStarNum(mysticData.star)
	end
end

--判断是否已经装备过
function M:judgeAdded(id)
	local equips=self.m_show_equips
	for i, v in pairs(equips) do
		if v.id==id then
			return true
		end
	end

	return false
end

function M:sortAllMystic()
	local function sortFunc(data1, data2)
		local cfg1 = UserDataManager.mystic_data:getMysticConfigByCid(data1.id)
		local cfg2 = UserDataManager.mystic_data:getMysticConfigByCid(data2.id)
		if cfg1.quality == cfg2.quality then
			if data1.recommend == data2.recommend then
				--if data1.id == data2.id then
				--	return data1.oid < data2.oid
				--else
				--	return data1.id < data2.id
				--end
				return data1.id < data2.id
			else
				return data1.recommend > data2.recommend
			end
			
		else
			return cfg1.quality > cfg2.quality
		end
	end
	table.sort(self.m_show_equips, sortFunc)
end

function M:getShowEquipCount()
	return self.m_show_equips
end

function M:getCanEquipCountByStarNum(starNum)
	local common_cfg=ConfigManager:getCfgByName("common")
	local common_cfg_item=common_cfg[832]

	if starNum == nil then
		starNum=1
	else
		starNum=1+starNum
	end

	return common_cfg_item.value[starNum]
end

function M:getShowEquipDataByIndex(index)
	return self.m_show_equips[index]
end

function M:getCurEquip()
	local equips = self.m_herodata.mystics or {}
	local mystic_data_id = equips[tostring(self.m_pos)]

	local mystic_data=UserDataManager.mystic_data:getMysticDataById(mystic_data_id)
	if mystic_data then
		local cfg = UserDataManager.mystic_data:getMysticConfigByCid(mystic_data.id)
		return mystic_data, cfg
	end
	return nil, nil
end

function M:getCurSelectedMysticLvCfg()
	local equips = self.m_herodata.mystics or {}
	local mystic_data_id = equips[tostring(self.m_pos)]

	local mystic_data=UserDataManager.mystic_data:getMysticDataById(mystic_data_id)
	if mystic_data then
		local lv=mystic_data.lv or 1
		local cfg = UserDataManager.mystic_data:getMysticLvCfg(mystic_data.id,lv)
		return  cfg
	end
	return nil
end

function M:getEquipById(id)
	return UserDataManager.mystic_data:getMysticDataById(id)
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
	local attrs = UserDataManager:appendAttrs(UserDataManager:getOneMysticAttrs(data, cfg, self.m_herodata))
	local combat = UserDataManager:computeEquipCombat(attrs)
	return combat
end

-- 获取格式化秘籍经脉属性
function M:getFormatMysticSigAttr()
	if not self.m_eqp_cfg then return {} end
	local sig_attrs = {} -- 秘籍经脉属性
	local attr_list = {}
	local sort_attrs = {} -- 筛选为两两一组
	local meridian = table.copy(self.m_eqp_cfg.meridian) or {}
	for i, v in pairs(meridian) do
		table.insertto(sig_attrs, v.attr)
	end
	sig_attrs = UserDataManager:appendAttrs(sig_attrs) -- 属性id转换成key
	for i, v in pairs(sig_attrs) do
		table.insert(attr_list, {i, v})
	end
	for i = 1, math.ceil(#attr_list/2) do
		table.insert(sort_attrs,{attr_list[i*2-1],attr_list[i*2]})
	end
	return sort_attrs
end

-- 获取格式化秘籍基础属性
function M:getFormatMysticBaseAttr()
	local cur_mystic_lv_cfg=self:getCurSelectedMysticLvCfg()
	if not cur_mystic_lv_cfg then return {} end
	local base_attrs = {} -- 所有属性包括经脉属性顺序排列
	local attr_list = {}
	local sort_attrs = {} -- 筛选为两两一组
	base_attrs = table.copy(cur_mystic_lv_cfg.attrs) or {}
	base_attrs = UserDataManager:appendAttrs(base_attrs) -- 属性id转换成key
	for i, v in pairs(base_attrs) do
		table.insert(attr_list, {i, v})
	end
	for i = 1, math.ceil(#attr_list/2) do
		table.insert(sort_attrs,{attr_list[i*2-1],attr_list[i*2]})
	end
	return sort_attrs
end

-- 通过秘籍配置id获取秘籍详情
function M:getMysticData(m_oid)
	local cfg = UserDataManager.mystic_data:getMysticConfigByCid(m_oid)
	return cfg
end

function M:getMysticStarData(mystic_id)
	local cfg=UserDataManager.mystic_data:getMysticStarConfigId(mystic_id)
	return cfg
end

-- 通过秘籍id获取buff列表
function M:getMysticBuffGroupById(data_id,starLv)
	starLv=starLv or 0
	local buff_group_cfg = {}
	local cfg = self:getMysticStarData(data_id)
	if cfg then
		cfg=cfg[starLv]
		local mystic_buff_cfg = ConfigManager:getCfgByName("mystic_buff")
		for i, v in pairs(cfg.buff) do
			buff_group_cfg[i] = mystic_buff_cfg[v]
		end
	end
	return buff_group_cfg
end

-- 获取秘籍的所有属性,并组装
function M:getMysticAllAttr(item_cfg)
	local all_attrs = {} -- 所有属性包括经脉属性顺序排列
	local sort_attrs = {} -- 筛选为两两一组
	all_attrs = table.copy(item_cfg.attrs) or {}
	local meridian = table.copy(item_cfg.meridian) or {}
	for i, v in pairs(meridian) do
		table.insertto(all_attrs, v.attr)
	end
	all_attrs = UserDataManager:appendAttrs(all_attrs) -- 属性id转换成key
	local attr_list = {}
	for i, v in pairs(all_attrs) do
		table.insert(attr_list, {i, v})
	end
	for i = 1, math.ceil(#attr_list/2) do
		table.insert(sort_attrs,{attr_list[i*2-1],attr_list[i*2]})
	end
	return sort_attrs
end

-- 检查秘籍是否比身上穿的更好
function M:checkMysticBatterThenWear(data_id)
	local flag = false
	local eqp_cfg = self.m_eqp_cfg
	if eqp_cfg then
		local cfg = self:getMysticData(data_id)
		if cfg.quality > 5 and cfg.quality > eqp_cfg.quality and eqp_cfg.random_type == cfg.random_type then -- 1.背包里的秘籍品质要大于身上的 2.背包里的秘籍品质要大于紫 3.random_type是同一系列
			flag = true
		end
	end
	return flag
end


--秘籍槽位限制秘籍类型
function M:meridianShowTypeByID(index)
	local common_cfg=ConfigManager:getCfgByName("common")
	local common_cfg_item=common_cfg[831]
	return common_cfg_item.value[index]
end

function M:destroy()
	self.m_show_equips=nil
end

return M
