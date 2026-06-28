local M = class("AdvancedDetailsPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_hero = self.m_params.data[1]
	local heroData, cfg = UserDataManager.hero_data:getHeroDataById(self.m_hero)
	self.hero_cid = heroData.id
	self.m_martial = {}
	for hero_index, hero_id in pairs(self.m_params.data) do
		if hero_index > 1 then
			table.insert( self.m_martial, hero_id)
		end
	end
	self.m_slot_consume = self.m_params.slot_consume
	self.m_islink = false
	if cfg.islink > 0 then
		self.need_universal_num = self:checkCanUseUniversal(self.hero_cid, cfg.evo, cfg.race, cfg.islink)
	end
	-- if self.m_islink == true then
	-- 	self.m_link_type = self.m_params.link_type or 0 --结义加深/解除
	-- 	if self.m_link_type == 2 then
	-- 		self.m_martial = self:getLinkCost()
	-- 	elseif self.m_link_type == 3 then
	-- 		self.m_martial = self:getReturnConsume()
	-- 	elseif self.m_link_type == 1 then
	-- 		self.m_martial = {}
	-- 	end
	-- end
end

function M:getAllMartial()
	local num = 0
	local hero, cfg = UserDataManager.hero_data:getHeroDataById(self.m_hero)
	for i,v in pairs(hero.evo_hero or {}) do
		local one_cfg = UserDataManager.hero_data:getHeroConfigByCid(tonumber(i))
		if one_cfg.evo >= 5 then -- 大侠卡
			num = num + v*2 -- 记录的是紫+的数量，紫卡需要x2
		end
	end
	num = num - 8
	return num
end

--获取结义加深消耗
function M:getLinkCost()
	local exhero_evolution = ConfigManager:getCfgByName("exhero_evolution")
	local heroData, cfg = UserDataManager.hero_data:getHeroDataById(self.m_hero)
	local ex_hero_cfg = exhero_evolution[heroData.link_lv]
	local temp_tab = {}
	if ex_hero_cfg then
		local consumeData = ex_hero_cfg.consume[1]
		for i = 1, consumeData[2] do
			if consumeData[1] == 1 then
				local o_id = self:checkConsume(temp_tab, consumeData[3])
				temp_tab[o_id] = 1
			end
		end
	end
	local new_tab = {}
	for k,v in pairs(temp_tab) do
		table.insert(new_tab, k)
	end
	return new_tab
end

--查找消耗材料
function M:checkConsume(tab, evo)
	local hero_data_list = UserDataManager.hero_data:getHerosData()
	for k,v in pairs(hero_data_list) do
		if tab[k] == nil and self.hero_cid == v.id and k ~= self.m_hero and evo == v.evo then
			return k
		end
	end
	return 0
end

--结义下一阶段的品质
function M:getLinkNextLv()
	local exhero_evolution = ConfigManager:getCfgByName("exhero_evolution")
	local heroData, cfg = UserDataManager.hero_data:getHeroDataById(self.m_hero)
	local num = heroData.evo
	if heroData.link and heroData.link ~= "" then
		local ex_hero_cfg = exhero_evolution[heroData.link_lv+1]
		local link_heroData, link_cfg = UserDataManager.hero_data:getHeroDataById(heroData.link)
		local evo_max = ex_hero_cfg and ex_hero_cfg.evo_max or heroData.evo
		num = math.min(link_heroData.evo, evo_max)
	else
		local ex_hero_cfg = exhero_evolution[1]
		local evo_max = ex_hero_cfg and ex_hero_cfg.evo_max or heroData.evo
		num = evo_max
	end
	return num
end

--结义资源返还
function M:getReturnConsume()
	local heroData, cfg = UserDataManager.hero_data:getHeroDataById(self.m_hero)
	local max_num = 1
	local temp_tab = {}
	if heroData.link_lup and next(heroData.link_lup) ~= nil then
		for k,v in pairs(heroData.link_lup) do
			for i = 1,v do
				table.insert(temp_tab, tonumber(k))	
			end
		end
	end
	return temp_tab
end

--是否可以使用万能材料// 限定种族(race)、限定类型(islink)、限定品质(evo)
function M:checkCanUseUniversal(hero_id, evo, race, link_id)
	local exhero_evolution_cfg = ConfigManager:getCfgByName("exhero_evolution")
	local link_id = link_id or 1
	local type_table = exhero_evolution_cfg[link_id]
	local hero_evolution = type_table[hero_id] or type_table[0]
	local evo_data = hero_evolution[evo]
	local can_bl = false
	if evo_data.universal and evo_data.universal > 0 then
		for k,v in pairs(evo_data.consume) do
			if v[1] == 1 then
				can_bl = true
			end
		end
	end
	if can_bl == false then
		return 0 --替代万能材料数量
	end
	self.m_universal_id = evo_data.universal
	local reward_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM, evo_data.universal, 1 })
	local need_one_num = 0 --需要本体数量
	local have_one_num = 0
	for k,v in pairs(self.m_slot_consume) do
		if v[1] == 1 then
			if v[3] == 5 then
				need_one_num = need_one_num + 1
			elseif v[3] == 6 then
				need_one_num = need_one_num + 2	
			end
		end
	end
	for k, v in pairs(self.m_params.data) do
		if k > 1 then
			local temp_heroData, temp_cfg = UserDataManager.hero_data:getHeroDataById(v)
			if temp_cfg and temp_cfg.race == race and hero_id == temp_cfg.id then
				if temp_heroData.evo == 6 then
					have_one_num = have_one_num + 2
				else
					have_one_num = have_one_num + 1
				end
			end
		end
	end
	return (need_one_num-have_one_num) --替代万能材料数量
end

return M
