local M = class("WishRaceHerosPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	--槽位
	self.slot = {
		[1] = {
			hero_id = 0,
			finish = 0,
			race = 0;
		},
		[2] = {
			hero_id = 0,
			finish = 0,
			race = 0;
		},
		[3] = {
			hero_id = 0,
			finish = 0,
			race = 0;
		},
	}
	
	self.hero_detail = ConfigManager:getCfgByName("hero_detail");
	--祝福数据
	self.m_bless_data = self.m_params.data;
	self.m_time = self.m_params.time;
	self:updateSlot(self.m_bless_data.hero_wish_list);
end


--我的数据中是否有这个id
function M:hasHeros( id )
	local heros = UserDataManager.hero_data:getHeroIdsByCid( id )
	if #heros >0 then
		return true;
	end
	return false;
end


--是否是已经实现的英雄
function M:isFinishHero( hero_id )
	for i, v in ipairs(self.m_bless_data.wish_success) do
		if v == hero_id then
			return 1;
		end
	end
	return 0;
end


--更新栏位
function M:updateSlot( data )
	for i, v in ipairs(data) do
		self.slot[i].hero_id = v;
		self.slot[i].finish = self:isFinishHero(v);
		local hero_data = self:getHero(v)
		if hero_data ~= nil then
			self.slot[i].race = hero_data.race;
		end
	end
end

--切换英雄列表
function M:switchHeroList(race)
	self.m_cur_race = race
	local hero_list = {}
	hero_list = self:filtrateHero(race)
	return hero_list
end


function M:getSendSlot()
	return self.slot;
end


--获取英雄数据
function M:getHeroData(hero_id)
	local hero_cfg = self:getHero(hero_id);
	--获取道具人物头像数据
	local itemData = RewardUtil:getHeroConfigData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_cfg.id, 1})
	itemData.quality = hero_cfg.evo;
	itemData.oid = hero_cfg.oid
	return itemData;
end


--过滤 全部英雄列表
function M:filtrateHero(race_id)
	--获取全部英雄列表
	local hero_list = self:getAllHero()
	--如果种族是 0 表示 不筛选
	if race_id == 0 then
		return hero_list
	end
	local heros = {}
	for k,v in pairs(hero_list) do
		--获取英雄配置
		local hero_cfg = self:getHero(v)
		--如果种族一致就加入到列表中
		if race_id == hero_cfg.race then
			table.insert(heros, v)
		end
	end
	--根据等级排序
	return heros
end

--当前英雄是否在槽位上
function M:isInSlot( heroId )
	for i, v in pairs(self.slot) do
		if v.hero_id == heroId then
			return true;
		end
	end
	return false;
end

function M:getSlotInfo( heroId )
	for i, v in pairs(self.slot) do
		if v.hero_id == heroId then
			return v;
		end
	end
	return nil;
end

--筛选出已上阵的英雄
function M:getAllHero()
	--得到我的所有英雄
	local heros = {}
	local season = UserDataManager.m_season_data.season
	for i, v in pairs(self.hero_detail) do
		if v.evo == 5 and v.is_visible and v.is_visible == 1 and self:seasonCheck(v) then
			table.insert(heros, i)
		end
	end
	return heros;
end

function M:seasonCheck(hero_item)
	local season = UserDataManager.m_season_data.season
	local season_day = UserDataManager:getCurSeasonDay()
	if hero_item.season and hero_item.season_day 
			and ((hero_item.season < season) or (hero_item.season == season and ((hero_item.season_day == 0) or (hero_item.season_day ~= 0 and hero_item.season_day <= season_day) )) ) then
		return true
	end
	return false
end

--把英雄从槽位上删除
function M:removeHeroInSendSlot( hero_id )
	local index = 1
	for k,v in pairs(self.slot) do
		if v.hero_id == hero_id then
			index = k
		end
	end
	self.slot[index].hero_id = 0;
	self.slot[index].finish = 0;
	self.slot[index].race = 0;
end


--加入到英雄栏位中
function M:addHeroInSendSlot(hero_id)
	local index = -1
	for k,v in pairs(self.slot) do
		if v.hero_id == 0 then
			index = k
			break;
		end
	end
	if index >= 1 then
		local hero_data = self:getHero(hero_id)
		for i, v in ipairs(self.slot) do
			if hero_data.race == v.race then
				--有相同的种族
				return 2, hero_data.race;
			end
		end
		self.slot[index].hero_id = hero_id;
		self.slot[index].race = hero_data.race;
		return 1;
	end
	return 0;
end


--根据id获得英雄数据
function M:getHero(id)
	local hero_data_config = self.hero_detail[id];
	if hero_data_config ~= nil then
		local hero_data_config_copy = table.copy(hero_data_config)
		--得到当前英雄id的我拥有的所有英雄
		local heros = UserDataManager.hero_data:getHeroIdsByCid( id )
		local oid = nil
		if #heros >0 then
			local max_evo = 1;
			for i, v in pairs(heros) do
				local hero_data = UserDataManager.hero_data:getHeroDataById(v);
				if hero_data.evo > max_evo then
					max_evo = hero_data.evo;
					oid = hero_data.oid
				end
			end
			hero_data_config_copy.evo = max_evo;
			hero_data_config_copy.oid = oid
		end
		return hero_data_config_copy;
	else
		return nil;
	end
end


return M
