local M = class("SeasonChangeHeroPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_show_data = self.m_params.show_data or nil
	self.m_normal_cfg_num = ConfigManager:getCommonValueById(730,8)
	self.m_core_cfg_num = ConfigManager:getCommonValueById(731,8)
	self.m_is_check = false
	self.m_total_hero = self:getHeroData()
	self.m_cur_select_hero_tab = {}
	self.m_normal_hero_nums = 0
	self.m_core_hero_nums = 0
end

function M:setCheckStatus()
	self.m_is_check = not self.m_is_check 
end

function M:updateSelectHeroTab(hero_data)
	local hero_oid = hero_data.oid
	local h_data, hero_cfg =  UserDataManager.hero_data:getHeroDataById(hero_oid)
	local is_add = 0
	local tips_des = ""
	if self.m_cur_select_hero_tab[hero_oid] then
		self.m_cur_select_hero_tab[hero_oid] = nil
		is_add = -1
	else
		if table.nums(self.m_cur_select_hero_tab) < self.m_normal_cfg_num + self.m_core_cfg_num then
			if  hero_cfg.Ex_hero ~= 1 and self.m_normal_hero_nums >= self.m_normal_cfg_num then
				tips_des = "season_change_hero_text_004"
			else
				self.m_cur_select_hero_tab[hero_oid] = 1
				is_add = 1
			end
		else
			tips_des = "season_change_hero_text_006"
		end
	end
	if is_add ~= 0 then
		if hero_cfg.Ex_hero == 1 then
			self.m_core_hero_nums = math.max(self.m_core_hero_nums + 1 * is_add, 0)
		else
			self.m_normal_hero_nums = math.max(self.m_normal_hero_nums + 1 * is_add, 0)
		end
	end
	return tips_des
end

function M:getCurNormalNums()
	local nums = 0
	local core_nums = (self.m_core_hero_nums - self.m_core_cfg_num) 
	nums = self.m_normal_hero_nums + (core_nums > 0 and core_nums or 0 )
	return nums
end

function M:isSelectHero(hero_data)
	local hero_oid = hero_data.oid 
	return self.m_cur_select_hero_tab[hero_oid]
end

function M:getTargetHeroData()
	if self.m_show_data and self.m_show_data.item_cfg and self.m_show_data.item_cfg.effect then
		local hero_id = self.m_show_data.item_cfg.effect
		local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_id, 0})
		data.quality = 19
		data.oid = hero_id;
		return data 
	end
	return nil
end

--切换英雄列表
function M:switchHeroList(race)
	self.m_cur_race = race
	local hero_list = {}
	hero_list = self:filtrateHero(race)
	return hero_list
end

--获取所有英雄信息
function M:getHeroData()
	local all_hero =  UserDataManager.hero_data:getHerosData()
	local hero_data = {}
	for i, v in pairs(all_hero) do
		local hero_cfg =  UserDataManager.hero_data:getHeroConfigByCid(v.id)
		if  hero_cfg.evo > 4 and v.evo == 6  then
			table.insert(hero_data,v)
		end
	end
	table.sort(hero_data,function(data1,data2)
		if data1.id == data2.id then
			if data1.level == data2.level then
				return data1.evo < data2.evo
			else
				return data1.level < data2.level
			end
		else
			return data1.id < data2.id
		end
	end)
	return hero_data
end


--过滤 全部英雄列表
function M:filtrateHero(race_id, is_ex)
	--获取全部英雄列表
	local hero_list = self.m_total_hero
	--如果种族是 0 表示 不筛选
	
	local heros = {}
	for k,v in pairs(hero_list) do
		--获取英雄配置
		local h_data, hero_cfg =  UserDataManager.hero_data:getHeroDataById(v.oid)
		--如果种族一致就加入到列表中
		if race_id == 0 and hero_cfg.race < 5 and (not self.m_is_check or hero_cfg.Ex_hero == 1) then
			table.insert(heros, h_data)
		elseif race_id == hero_cfg.race and (not self.m_is_check or hero_cfg.Ex_hero == 1) then
			table.insert(heros, h_data)
		end
	end
	--根据等级排序
	table.sort(heros,function(data1,data2)
		if data1.combat == data2.combat then
			if data1.level == data2.level then
				return data1.evo > data2.evo
			else
				return data1.level > data2.level
			end
		else
			return data1.combat > data2.combat
		end

		--if data1.hero_state == data2.hero_state then
		--	return data1.hero_state > data2.hero_state
		--else
		--	return data1.hero_state < data2.hero_state
		--end
	end)
	return heros
end

function M:isCanChange()
	local is_can = table.nums(self.m_cur_select_hero_tab) >= (self.m_normal_cfg_num + self.m_core_cfg_num)
	return is_can
end

function M:getHeroDataById(hero_data)
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
	local itemData = RewardUtil:getHeroConfigData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_cfg.id, 1})
	itemData.quality = hero_data.evo;
	itemData.oid = hero_data.oid;
	return itemData;
end

return M
