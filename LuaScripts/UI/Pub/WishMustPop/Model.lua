---@class WishMustPopModel:OODataBase
local M = class("WishMustPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_bless_data = self.m_params.data
	self.m_hero_id = self.m_bless_data.bless_hero
	--槽位
	self.slot = {
		[1] = self.m_hero_id,
	}
	self.hero_detail = ConfigManager:getCfgByName("hero_detail")
	self.m_vip_cfg = ConfigManager:getCfgByName("vip")
	self.m_is_yinyang = false
	self:updateMaxValue();
end

function M:getGachaHyperbless()
	local gacha_hyperbless = ConfigManager:getVipValueByKey("gacha_hyperbless", 0)
	return gacha_hyperbless
end

function M:getYinYangTimes()
	local yinyang_times =  ConfigManager:getCommonValueById(516, 0)
	return yinyang_times
end

function M:getOpenYinYang() 
	return BtnOpenUtil:isBtnOpen(191)
end

function M:getBlessTimes()
    local bless_success = nil --self.m_bless_data.bless_success
	bless_success = self.m_bless_data.bless_received and self.m_bless_data.bless_received or {}
	local yinyang_success_times = 0
	local success_times = 0
	for k, v in pairs(bless_success) do
		if tonumber(k) > 4 then
			yinyang_success_times = yinyang_success_times + bless_success[k]
		elseif tonumber(k) <= 4  then
			success_times = success_times + bless_success[k]
		end
	end
    return yinyang_success_times, success_times
end

function M:updateMaxValue()
	--龙庭（青龙）金--race_id 1
	--草莽（朱雀）火--race_id 2
	--世族（玄武）木--race_id 3
	--异族（白虎) 水--race_id 4
	--阳--race_id 5
	--阴--race_id 6
	self.m_is_yinyang = false
	local hero_cfg = ConfigManager:getCfgByName("hero_detail")[self.m_bless_data.bless_hero]
	if hero_cfg == nil then
		self.maxValue = 100
		return
		--local value_list = { 100 }
		--if hero_cfg.race == 5 or hero_cfg.race == 6 then
		--	value_list = ConfigManager:getCommonValueById(429)
		--	self.m_is_yinyang = true
		--else
		--	value_list = ConfigManager:getCommonValueById(428)
		--end
		--local yinyang_success_times, success_times = self:getBlessTimes()
		--local index = self.m_is_yinyang and yinyang_success_times or success_times
		--local value_len = #value_list;
		--self.maxValue = value_list[index+1] or value_list[value_len]
	end
	local index = hero_cfg["gacha_bless_cost_id"]
	index = index + 1 --对应0开始的下标
	local value_list = ConfigManager:getCommonValueById(428)
	self.maxValue = value_list[index]
end

--切换英雄列表
function M:switchHeroList(race)
	self.m_cur_race = race
	local hero_list = {}
	--if self:checkSortFull() == false then
	hero_list = self:filtrateHero(race)
	--end
	return hero_list
end

function M:getSendSlot()
	return self.slot
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
		local index = hero_cfg["gacha_bless_cost_id"]
		--如果种族一致就加入到列表中
		if race_id == hero_cfg.race and index ~= 0 and self:hasBless(v) == false then
			table.insert(heros, v)
		end
	end
	--根据等级排序
	return heros
end

--获取英雄数据
function M:getHeroData(hero_id)
	local hero_cfg = self:getHero(hero_id)
	--获取道具人物头像数据
	local itemData = RewardUtil:getHeroConfigData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_cfg.id, 1})
	itemData.quality = hero_cfg.evo
	itemData.oid = hero_cfg.oid
	return itemData
end

--初始
function M:hasHeroInSlot()
	if self.slot[1] == 0 then
		return false
	end
	return true
end

--当前英雄是否在槽位上
function M:isInSlot(heroId)
	if self.slot[1] == heroId then
		return true
	end
	return false
end

--筛选出已上阵的英雄
function M:getAllHero()
	--得到我的所有英雄
	local heros = {}
	for i, v in pairs(self.hero_detail) do
		if v.evo == 5 and v.is_visible and v.is_visible == 1 and self:seasonCheck(v) == true then
			table.insert(heros, i)
		end
	end
	return heros
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

--我的数据中是否有这个id
function M:hasHeros(id)
	local heros = UserDataManager.hero_data:getHeroIdsByCid( id )
	if #heros > 0 then
		return true
	end
	return false
end

--把英雄从槽位上删除
function M:removeHeroInSendSlot( hero_id )
	local index = 1
	for k,v in pairs(self.slot) do
		if v == hero_id then
			index = k
		end
	end
	self.slot[index] = ""
end

function M:addHeroInSendSlot(hero_id)
	self.slot[1] = hero_id
	self.m_bless_data.bless_hero = hero_id
end

--根据id获得英雄数据
function M:getHero(id)
	local hero_data_config = self.hero_detail[id]
	if hero_data_config ~= nil then
		local hero_data_config_copy = table.copy(hero_data_config)
		--得到当前英雄id的我拥有的所有英雄
		local heros = UserDataManager.hero_data:getHeroIdsByCid( id )
		if #heros >0 then
			local max_evo = 1
			local oid = 1
			for i, v in pairs(heros) do
				local hero_data = UserDataManager.hero_data:getHeroDataById(v)
				if hero_data.evo > max_evo then
					max_evo = hero_data.evo
					oid = hero_data.oid
				end
			end
			hero_data_config_copy.evo = max_evo
			hero_data_config_copy.oid = oid
		end
		return hero_data_config_copy
	else
		return nil
	end
end

--是否已经兑换过
function M:hasBless(hero_id)
	local bless_received = self.m_bless_data.bless_received
	if bless_received == nil or #bless_received then
		return false
	end
	for k,v in pairs(bless_received) do
		if hero_id == v then
			return true
		end
	end
	return false
end

return M