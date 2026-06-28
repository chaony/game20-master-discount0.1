---@class SelectSupportHeroModel:OODataBase
local M = class("SelectSupportHeroModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.selectedHeros=self.m_params.selectedHeros
	self.m_cur_race_id=self.m_params.race_id
	self.m_cur_support_oid =self.m_params.support_oid
	self.m_selected_support_oid =self.m_params.support_oid

	if self.m_cur_support_oid then
		local data,cfg=UserDataManager.hero_data:getHeroDataById(self.m_cur_support_oid)
		self.m_cur_support_id =data.id
	end

	local key=nil
	for k, selectedHero in pairs(self.selectedHeros) do
		if selectedHero==self.m_cur_support_oid then
			key=k
		end
	end
	if key~=nil then
		self.selectedHeros[key]=nil
	end

	self:update_all_ids()
	self.hero_detail=ConfigManager:getCfgByName("hero_detail")
end

function M:update_all_ids()
	self.m_all_ids={}
	for i, hero_oid in pairs(self.selectedHeros) do
		local data,_=UserDataManager.hero_data:getHeroDataById(hero_oid)
		if not table.indexof(self.m_all_ids,data.id) then
			table.insert(self.m_all_ids,data.id)
		end
	end
	Logger.log(table.nums(self.m_all_ids))
end


function M:hasHeros( id )
	local heros = UserDataManager.hero_data:getHeroIdsByCid( id )
	if #heros >0 then
		return true;
	end
	return false;
end


--切换英雄列表
function M:switchHeroList(race)
	self.m_cur_race = race
	local hero_list = {}
	hero_list = self:filtrateHero(race)
	return hero_list
end


--获取英雄数据
function M:getHeroData(hero_data)
	--local hero_cfg = self:getHero(hero_data);
	--获取道具人物头像数据
	local itemData = RewardUtil:getHeroConfigData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 1})
	itemData.quality = hero_data.evo;
	itemData.oid = hero_data.oid
	return itemData;
end


--过滤 全部英雄列表
function M:filtrateHero(race_id)
	--获取全部英雄列表
	local hero_list = self:getAllHero()

	local heros = {}
	for oid ,hero_data in pairs(hero_list) do
		--获取英雄配置
		--local hero_cfg = self:getHero(v.id)
		local _,hero_cfg =UserDataManager.hero_data:getHeroDataById(oid)
		--local hero={}
		--hero=table.copy(hero_cfg)
		--hero.oid=oid
		--如果种族一致就加入到列表中
		if race_id == hero_cfg.race then
			table.insert(heros, hero_data)
		end
	end
	self:sortHeroTabByGet(heros)
	--根据等级排序
	return heros
end

--以是否拥有为根据排序
function M:sortHeroTabByGet(tab)
	table.sort(tab, function(a, b) 
		local evo_1 = a.evo or 0
		local evo_2 = b.evo or 0
		return evo_1 > evo_2
	end)
end

--是否是已选中的
function M:isInSelected()

end


--筛选出已上阵的英雄
function M:getAllHero()

	local heros = table.copy(UserDataManager.hero_data:getHerosData())

	return heros;
end

function M:getAllHeroIds()
	local oids = table.copy(UserDataManager.hero_data:getHerosId())
	return oids
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

function M:setSupportOid(oid)
	--local key=table.keyof(self.selectedHeros,self.m_selected_support_oid)
	--if oid==nil or (oid~=self.m_selected_support_oid and self.m_selected_support_oid~=nil) then
	--	if key then
	--		self.selectedHeros[key]=nil
	--	end
	--	if self.m_selected_support_oid~=nil then
	--		local len=table.nums(self.selectedHeros)
	--		self.selectedHeros[tostring(len+1)]=oid
	--	end
	--else
	--	local len=table.nums(self.selectedHeros)
	--	self.selectedHeros[tostring(len+1)]=oid
	--end
	--self:update_all_ids()
	self.m_selected_support_oid =oid
end


function M:destroy()
	self.m_all_ids={}
end



return M
