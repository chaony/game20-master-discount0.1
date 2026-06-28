---@class DepositoryPopModel:OODataBase
local M = class("DepositoryPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_heroid = self.m_params.heroid
	self.m_pos = self.m_params.pos
	self.m_look_model = self.m_params.look_model

	self.m_c_hero = self.m_params.c_hero
	-- 看代码发现这个是配置的id
	self.m_id = self.m_params.mystic_data
	self.m_mode = self.m_params.mode or 1  -- 3、镶嵌秘籍查看
	self.m_other = self.m_params.other or false --查看其他玩家的秘籍

	if self.m_other then
		self.m_mystic_data=self.m_params.mystic
	else
		self.m_mystic_data = UserDataManager.mystic_data:getMysticDataById(self.m_params.oid)
	end
	self.m_cost = self.m_params.cost -- 秘籍购买
	self.m_ok_call_func = self.m_params.ok_call_func -- 秘籍购买

	self.star_lv=self.m_mystic_data.star or 0
	self.m_group_cfg = {}
	if self.m_mystic_data and self.m_id == nil then
		self.m_id = self.m_mystic_data.id
	end
	self.m_isToday = self.m_params.isToday
	self.m_today_text = self.m_params.today_text or Language:getTextByKey("new_str_0910")
	self.m_today_btn_value = self.m_params.today_btn_value
	self:initMysticGroup()
end

function M:getMysticData()
	local cfg = UserDataManager.mystic_data:getMysticConfigByCid(self.m_id)
	return cfg
end

function M:getMysticLvCfg()
	local lv=self.m_mystic_data.lv or 1
	local cfg=UserDataManager.mystic_data:getMysticLvCfg(self.m_id,lv)
	return cfg
end

function M:getMystic_Star_Cfg()
	local cfg=UserDataManager.mystic_data:getMysticStarConfigId(self.m_id,self.star_lv)
	return cfg
end

function M:initMysticGroup()
	--local cfg = self:getMystic_Star_Cfg()
	--if cfg and cfg.buff then
	--	for i, v in pairs(cfg.buff) do
	--		self.m_group_cfg[i] = mystic_buff_cfg[v]
	--	end
	--end
	self.m_group_cfg=self:getMysticBuffGroupById(self.m_id)
end

function M:getMysticGroup()
	return self.m_group_cfg
end

function M:getBaseAttr()
	local show_data = {}
	local mystic_cfg = self:getMysticData()
	show_data = mystic_cfg.attrs or {}
	return show_data
end

function M:getChannelAttr()
	local show_data = {}
	--local mystic_cfg = self:getMysticData()
	--local channel_lv = 0
	--local sigData = {} -- 经脉数据
	--if self.m_heroid then
	--	if self.m_other then
	--		sigData = self.m_c_hero.sig
	--	else
	--		sigData = UserDataManager.hero_data:getSigDataByHeroOid(self.m_heroid)
	--	end
	--end
	--
	--for i, v in pairs(mystic_cfg.meridian) do
	--	local channel = sigData[tostring(i)] -- i 是经脉类型 -- 1.冲、2：带、3：任、4：督
	--	channel_lv = channel and channel.lv or 0
	--	local activation = v.activation
	--	for m = 1, #activation do
	--		show_data[#show_data + 1] = {lv = activation[m],channel_lv = channel_lv, attr = v.attr[m], mystic_type = mystic_cfg.type, open = channel_lv >= activation[m], meridian_type = i }
	--	end
	--end
	return show_data
end

-- 获取格式化秘籍基础属性
function M:getFormatMysticBaseAttr()
	local cfg = self:getMysticLvCfg()
	if not cfg then return {} end
	local base_attrs = {} -- 基础属性
	local attr_list = {}
	local sort_attrs = {} -- 筛选为两两一组
	base_attrs = table.copy(cfg.attrs) or {}
	base_attrs = UserDataManager:appendAttrs(base_attrs) -- 属性id转换成key
	for i, v in pairs(base_attrs) do
		table.insert(attr_list, {i, v})
	end
	for i = 1, math.ceil(#attr_list/2) do
		table.insert(sort_attrs,{attr_list[i*2-1],attr_list[i*2]})
	end
	return sort_attrs
end

--是否是先天秘籍
function M:isInnateMystic()
	local cfg = UserDataManager.mystic_data:getMysticConfigByCid(self.m_id)
	return cfg.type==1
end

-- 获取格式化秘籍先天属性
function M:getFormatMysticInnateAttr()

	local cfg = self:getMystic_Star_Cfg()
	if not cfg then return {} end
	local base_attrs = {} -- 基础属性
	local attr_list = {}
	local sort_attrs = {} -- 筛选为两两一组
	if self:isInnateMystic() then
		base_attrs = table.copy(cfg.attrs) or {}
		--base_attrs = UserDataManager:appendAttrs(base_attrs) -- 属性id转换成key
		local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
		for i, v in pairs(base_attrs) do
			local id=v[1]
			if hero_enumeration[id].base_on_id~=nil then
				id=hero_enumeration[id].base_on_id
			end
			table.insert(attr_list,  v)
		end
		--for i = 1, math.ceil(#attr_list/2) do
		--	table.insert(sort_attrs,{attr_list[i*2-1],attr_list[i*2]})
		--end
		if table.nums(attr_list)<2 then
			table.insert(attr_list,  {})
		end
	end
	return attr_list
end

-- 通过秘籍id获取buff列表
function M:getMysticBuffGroupById(data_id)
	local buff_group_cfg = {}
	local cfg = self:getMysticData(data_id)
	if cfg then
		local mystic_buff_cfg = ConfigManager:getCfgByName("mystic_buff")
		local buff = UserDataManager.mystic_data:getMysticEfficientSkill(data_id,self.m_mystic_data)
		if buff then
			for i, v in pairs(buff) do
				buff_group_cfg[i] = mystic_buff_cfg[v]
			end
		end
	end
	return buff_group_cfg
end

--获取活动
function M:getHeroDatabyHeroId()
	if self.m_heroid then
		local data,cfg = UserDataManager.hero_data:getHeroDataById(self.m_heroid)
		return data,cfg
	end
end

-- 镶嵌属性
function M:getInsetAttr()
	local show_data = UserDataManager.mystic_data:getMysticInsetAllAttrs(self.m_id)
	return show_data
end

-- 奥义解放
function M:getInsetSkillAttr()
	local show_data = UserDataManager.mystic_data:getMysticInsetSkillEffect(self.m_id)
	return show_data
end

return M
