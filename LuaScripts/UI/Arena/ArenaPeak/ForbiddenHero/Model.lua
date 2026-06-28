---@class ForbiddenHeroModel:OODataBase
local M = class("ForbiddenHeroModel", LikeOO.OODataBase)

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
		}
	}
	self.m_ban_num=self.m_params.ban_num
	if self.m_ban_num==2 then
		self.slot[2] = { hero_id = 0, finish = 0, race = 0 }
	end
	self.hero_detail = ConfigManager:getCfgByName("hero_detail");
	--祝福数据
	self.m_time = self.m_params.time or 0
	self:updateSlot(self.m_params.lock_hero_data or {});
	self.m_slot_cache = table.copy(self.slot)

	self.main_team=self.m_params.main_team
	self.mult_main_teams=self.m_params.mult_main_teams

	self.is_rta=self.m_params.is_rta
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
	--for i, v in ipairs(self.m_bless_data.wish_success) do
	--	if v == hero_id then
	--		return 1;
	--	end
	--end
	return 0;
end

--是否已经上阵
function M:isInTeam(h_id)
	local h_cfg = UserDataManager.hero_data:getHeroConfigByCid(h_id)
	for k, v in pairs(self.main_team) do
		if #v > 0 then
			local _, c_cfg =UserDataManager.hero_data:getHeroDataById(v)
			if h_cfg == c_cfg then
				return true
			end
		end
	end
	if self.mult_main_teams then
		for k, v in pairs(self.mult_main_teams) do
			for pos, hero_oid in pairs(v) do
				if #hero_oid > 0 then
					local _, c_cfg =UserDataManager.hero_data:getHeroDataById(hero_oid)
					if h_cfg == c_cfg then
						return true
					end
				end
			end
		end
	end

	return false
end


--更新栏位
function M:updateSlot( data )
	for i, v in ipairs(data) do
		if v > 0 then
			self.slot[i].hero_id = v;
			self.slot[i].finish = self:isFinishHero(v);
			local hero_data = self:getHero(v)
			if hero_data ~= nil then
				self.slot[i].race = hero_data.race;
			end
		else
			self.slot[i].hero_id = v;
		end
	end
end

function M:getForbiddenHeroIds()
	local ids={}
	for i, v in pairs(self.slot) do
		if v.hero_id~=0 then
			ids[#ids+1]=v.hero_id
		end
	end
	return ids
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
		self:sortHeroTabByGet(hero_list)
		return hero_list
	end
	local heros = {}
	for k,v in pairs(hero_list) do
		--获取英雄配置
		local hero_cfg = self:getHero(v.id)
		--如果种族一致就加入到列表中
		if race_id == hero_cfg.race then
			table.insert(heros, hero_cfg)
		end
	end
	self:sortHeroTabByGet(heros)
	--根据等级排序
	return heros
end

--以是否拥有为根据排序
function M:sortHeroTabByGet(tab)
	table.sort(tab, function(a, b) 
		local get_1 = self:hasHeros(a.id) and 1 or 0
		local get_2 = self:hasHeros(b.id) and 1 or 0
		return get_1 > get_2
	end)
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
		if v.is_visible2 and v.is_visible2 == 1 then
			table.insert(heros, v)
		end
	end
	return heros;
end

function M:seasonCheck(hero_item)
	local season = UserDataManager.m_season_data.season
	local season_day = UserDataManager:getCurSeasonDay()
	if hero_item.season and hero_item.season_day and ((hero_item.season < season) or (hero_item.season == season and ((hero_item.season_day == 0) or (hero_item.season_day ~= 0 and hero_item.season_day <= season_day) )) ) then
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
	if self:hasHeros(hero_id) == false then
		return 4
	end
	
	local index = -1
	for k,v in pairs(self.slot) do
		if v.hero_id == 0 then
			index = k
			break;
		end
	end
	if index >= 1 then
		local hero_data = self:getHero(hero_id)
		--for i, v in ipairs(self.slot) do
		--	if hero_data.race == v.race then
		--		--有相同的种族
		--		return 2, hero_data.race;
		--	end
		--end
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
		if #heros >0 then
			local combat = 1
			local oid
			local evo
			for i, v in pairs(heros) do
				local hero_data = UserDataManager.hero_data:getHeroDataById(v);
				if hero_data.combat > combat then
					combat = hero_data.combat;
					oid = hero_data.oid
					evo = hero_data.evo
				end
			end
			hero_data_config_copy.combat = combat;
			hero_data_config_copy.oid = oid
			hero_data_config_copy.evo = evo
		end
		return hero_data_config_copy;
	else
		return nil;
	end
end

function M:hasSlotChanged()
	for k, v in pairs(self.slot) do
		if v.hero_id ~= self.m_slot_cache[k].hero_id then
			return true
		end
	end
	return false
end


return M
