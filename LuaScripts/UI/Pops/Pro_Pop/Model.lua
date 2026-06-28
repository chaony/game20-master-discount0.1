local M = class("Pro_PopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_heroid = self.m_params.heroid
	self.m_look_model = self.m_params.look_model
	self.m_show_attr = self.m_params.attrs or {}
	self.m_pet_attr_list = self.m_params.pet_attr_list
	self.m_player_data = self.m_params.player_data
	self.m_prestige_attr_list = self.m_params.prestige_attr_list
	self.m_title_text = self.m_params.title_text or nil --扩展标题配置
	self.m_des_text = self.m_params.des_text or nil --扩展描述配置
	local hero_attr = {}
	if next(self.m_show_attr) ~= nil then
		hero_attr = self.m_show_attr
		local attrs = {}
		for k,v in pairs(self.m_show_attr) do
			local user_key = GameUtil:getAttrsKey(v[1])
			local num = v[2]
			if GameUtil:canPerAttrTransition(user_key) then
				num = num * 100
			end
			attrs[#attrs + 1] = {user_key, GameUtil:formatNum(num)}
		end
		self.m_attrs = attrs
	elseif self.m_pet_attr_list ~= nil and next(self.m_pet_attr_list) ~= nil then
		local attrs = {}
		local hero_attar_tab = ConfigManager:getCfgByName("hero_enumeration")
		for k,v in pairs(hero_attar_tab) do
			if v.pet_is_show and v.pet_is_show == 1 then
				local num = self:checkKeyOtherAdd(v.user_key, self.m_pet_attr_list)
				attrs[#attrs + 1] = {v.user_key, num}
			end
		end
		self.m_attrs = attrs
	elseif self.m_prestige_attr_list ~= nil and next(self.m_prestige_attr_list) ~= nil then
		local attrs = {}
		local hero_attar_tab = ConfigManager:getCfgByName("hero_enumeration")
		for k,v in pairs(hero_attar_tab) do
			if v.is_show and v.is_show == 1 then
				local num = self:checkKeyOtherAdd(v.user_key, self.m_prestige_attr_list)
				attrs[#attrs + 1] = {v.user_key, num,k}
			end
		end
		self.m_attrs = attrs
	else
		if self.m_look_model == 1 then
			local hero_data = self.m_params.hero_data
			local hero_cfg = self.m_params.hero_cfg
			hero_attr = UserDataManager:getHeroAttrsByData(hero_data, hero_cfg, nil, false, self.m_player_data)
		else
			hero_attr = UserDataManager:getHeroAttrsById(self.m_heroid)
		end
		local attrs = {}
		local hero_attar_tab = ConfigManager:getCfgByName("hero_enumeration")
		for k,v in pairs(hero_attar_tab) do
			if v.is_show and v.is_show == 1 then
				local num = self:checkKeyOtherAdd(v.user_key, hero_attr)
				if v.max and v.max ~= 0 then
					local max = v.max
					if v.is_percent == 1 then
						max = math.floor(max*1000 + 0.5)/10
					else
						max = math.floor(max + 0.5)
					end
					num = math.min(num,max)
				end
				attrs[#attrs + 1] = {v.user_key, num,k}
			end
		end
		self.m_attrs = attrs
	end
end

--检查属性的其他加成
function M:checkKeyOtherAdd(key, hero_attr)
	local hero_attar_tab = ConfigManager:getCfgByName("hero_enumeration")
	local cur_atr_num = hero_attr[key] or 0
	local add = false
	for k,v in pairs(hero_attar_tab) do
		if key ~= v.user_key then
			if self:checkGetKey2(v.key, key) == true and hero_attr[v.user_key] and not add then
				local group = v.group or 0
				add = group > 0 and true or false
				cur_atr_num = cur_atr_num + hero_attr[v.user_key]
			end
		end
	end
	return cur_atr_num
end

function M:checkGetKey2(key_tab, key)
	if key_tab == nil then
		return false
	end
	for k,v in pairs(key_tab) do
		if v == key then
			return true
		end
	end
	return false
end

return M
