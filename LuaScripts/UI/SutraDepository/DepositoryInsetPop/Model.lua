local M = class("MeridianListModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_id = self.m_params.id
	self.m_mystic_data = self.m_params.mystic_data
	self.m_pos = self.m_params.pos
	self.m_sel_tab_index = self.m_params.open_tab_index or 1 -- 1 全部 2 先天 3 绝学
	if self.m_mystic_data then
		self.m_oid = self.m_mystic_data.oid
		self.m_mystic_cfg = UserDataManager.mystic_data:getMysticConfigByCid(self.m_mystic_data.id)
	end
	
	self.m_mystic_type = 0
	if self.m_mystic_cfg then
		self.m_mystic_type = self.m_mystic_cfg.type
	end
	self.m_callback = self.m_params.callback
	self:initData()
end

function M:initData()
	self.m_show_list = {}
	local ids = UserDataManager.mystic_data:getMysticesId()
	local hero_ids = UserDataManager.hero_data:getHerosId()
	local main_mystic_cfg = UserDataManager.mystic_data:getMysticConfigByCid(self.m_id)
	for k, v in pairs(hero_ids) do
		local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
		local mystics = hero_data.mystics or {}
		for m, n in pairs(mystics) do
			n.owner = v
			local mystic_cfg = UserDataManager.mystic_data:getMysticConfigByCid(n.id)
			if mystic_cfg and mystic_cfg.quality >= 12 then
				local sort_id = 3
				if self.m_id == n.id then
					sort_id = 1
				elseif main_mystic_cfg.type == mystic_cfg.type then
					sort_id = 2
				end
				table.insert(self.m_show_list, {mystic = n, owner = v, sort_id = sort_id})
			end
		end
	end
	Logger.log(self.m_show_list,"self.m_show_list ==")
	for i, v in pairs(ids) do
		local data, cfg = UserDataManager.mystic_data:getMysticDataById(v)
		if cfg and cfg.quality >= 12 then
			local sort_id = 3
			if self.m_id == v then
				sort_id = 1
			elseif main_mystic_cfg.type == cfg.type then
				sort_id = 2
			end
			table.insert(self.m_show_list, {mystic = data, sort_id = sort_id})
		end
	end

	self:sortAllMystic() -- 秘籍排序
end

function M:sortAllMystic()
	local function sortFunc(data1, data2)
		if data1.sort_id == data2.sort_id then
			return data1.mystic.id < data2.mystic.id
		else
			return data1.sort_id < data2.sort_id
		end
	end
	table.sort(self.m_show_list, sortFunc)
end

function M:getShowList()
	if self.m_sel_tab_index == 1 then
		return self.m_show_list
	elseif self.m_sel_tab_index == 2 then
		local list = {}
		for i,v in ipairs(self.m_show_list) do
			local cfg = UserDataManager.mystic_data:getMysticConfigByCid(v.mystic.id)
			if cfg.type == 1 then
				table.insert(list, v)
			end
		end
		return list
	elseif self.m_sel_tab_index == 3 then
		local list = {}
		for i,v in ipairs(self.m_show_list) do
			local cfg = UserDataManager.mystic_data:getMysticConfigByCid(v.mystic.id)
			if cfg.type == 2 then
				table.insert(list, v)
			end
		end
		return list
	elseif self.m_sel_tab_index == 4 then
		local list = {}
		for i,v in ipairs(self.m_show_list) do
			local cfg = UserDataManager.mystic_data:getMysticConfigByCid(v.mystic.id)
			if cfg.type == 3 then
				table.insert(list, v)
			end
		end
		return list
	end
	return self.m_show_list
end

function M:getCurEqpCombat()
	local data, cfg = self:getCurEquip()
	local attrs = UserDataManager:appendAttrs(UserDataManager:getOneMysticAttrs(data, cfg, self.m_herodata))
	local combat = UserDataManager:computeEquipCombat(attrs)
	return combat
end

-- 获取格式化秘籍经脉属性
function M:getFormatMysticSigAttr()
	if not self.m_mystic_cfg then return {} end
	local sig_attrs = {} -- 秘籍经脉属性
	local attr_list = {}
	local sort_attrs = {} -- 筛选为两两一组
	local meridian = table.copy(self.m_mystic_cfg.meridian) or {}
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
	if not self.m_mystic_cfg then return {} end
	local base_attrs = {} -- 所有属性包括经脉属性顺序排列
	local attr_list = {}
	local sort_attrs = {} -- 筛选为两两一组
	base_attrs = table.copy(self.m_mystic_cfg.attrs) or {}
	base_attrs = UserDataManager:appendAttrs(base_attrs) -- 属性id转换成key
	for i, v in pairs(base_attrs) do
		table.insert(attr_list, {i, v})
	end
	for i = 1, math.ceil(#attr_list/2) do
		table.insert(sort_attrs,{attr_list[i*2-1],attr_list[i*2]})
	end
	return sort_attrs
end

-- 通过秘籍id获取buff列表
function M:getMysticBuffGroupById(data_id)
	local buff_group_cfg = {}
	local cfg = UserDataManager.mystic_data:getMysticConfigByCid(data_id)
	if cfg then
		local mystic_buff_cfg = ConfigManager:getCfgByName("mystic_buff")
		local buff = UserDataManager.mystic_data:getMysticEfficientSkill(data_id)
		for i, v in pairs(buff) do
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

return M
