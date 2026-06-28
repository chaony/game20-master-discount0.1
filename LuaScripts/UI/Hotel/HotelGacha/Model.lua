local M = class("HotelGachaModel", LikeOO.OODataBase)

local __HOTEL_GACHA_RECORD_KEY = "hotel_gacha_record"

function M:onCreate()
	M.super.onCreate(self)
	self.m_room_id = self.m_params.room_id
	self.m_room_id = self.m_params.room_id
	self.m_room_lv = self.m_params.room_lv
	self:getData("hotel_gacha_index", {room = self.m_room_id})
end

function M:onEnter()
	local cfg = ConfigManager:getCfgByName("hotel_room_base")
	self.m_cfg = cfg[self.m_room_id]
	self.m_reward_record = self:getRewardRecord(self.m_cfg.gacha_attr_id) --奖励日志
	self.m_times = self.m_data.remain_times
	self.m_heroes = self.m_data.heros
	self.m_heroes_busy = self.m_data.heros_all
	self:updateTotalAttr()
end

--
function M:getHeroes()
	local ids = table.copy(UserDataManager.hero_data:getHerosId())
	local function sortFunc(id1, id2)
		local data1, cfg1 = UserDataManager.hero_data:getHeroDataById(id1)
		local data2, cfg2 = UserDataManager.hero_data:getHeroDataById(id2)
		return data2.evo < data1.evo
	end
	table.sort(ids, sortFunc)
	return ids
end

--侠客位是否开启
function M:isHeroPosOpen(pos)
	local open_lv = self.m_cfg.open_gacha_room_level[pos]
	if self.m_room_lv >= open_lv then
		return true
	end
	return false
end

--获得侠客对应的酒楼属性
function M:getHeroAttrs(oid)
	local hero, hero_cfg = UserDataManager.hero_data:getHeroDataById(oid)
	if hero == nil then
		return nil
	end
	local attrs_cfg = ConfigManager:getCfgByName("hotel_hero_attr")
	local hero_attrs_cfg = attrs_cfg[hero.id]
	if hero_attrs_cfg == nil then
		return nil
	end
	if hero_attrs_cfg[hero.evo] == nil then
		return nil
	end
	local attrs = hero_attrs_cfg[hero.evo].attrs
	return attrs
end

--判断侠客是否已经上阵
function M:isHeroBusy(oid)
	local index = table.keyof(self.m_heroes_busy, oid)
	if index == nil then
		return false
	end
	return true
end

--相同侠客不可重复上阵
function M:isUniqueHeroInGacha(oid)
	local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	local length = #self.m_heroes
	for i = 1, length do
		if self.m_heroes[i] ~= "" then
			local d, c = UserDataManager.hero_data:getHeroDataById(self.m_heroes[i])
			if data.id == d.id then
				return false
			end
		end
	end
	return true
end

--更新上阵侠客
function M:updateHeroes(heroes)
	--把原侠客清除
	local length = #self.m_heroes
	for i = 1, length do
		if self.m_heroes[i] ~= "" then
			table.removebyvalue(self.m_heroes_busy, self.m_heroes[i])
		end
	end
	--把新侠客加入
	table.insertto(self.m_heroes_busy, heroes)
	table.removebyvalue(self.m_heroes_busy, "", true)
	self.m_heroes = heroes
	self:updateTotalAttr()
end

--计算总属性值
function M:updateTotalAttr()
	self.m_total_attr = 0
	local length = #self.m_heroes
	for i = 1, length do
		local oid = self.m_heroes[i]
		if oid ~= "" then
			local attrs = self:getHeroAttrs(oid)
			self.m_total_attr = self.m_total_attr + attrs[self.m_cfg.gacha_attr_id] --计算最新总属性值
		end
	end
end

--抽卡
function M:updateGacha(times, reward)
	self.m_times = times
	local attr_id = self.m_cfg.gacha_attr_id
	local func_names = {"hotel_text_041", "hotel_text_042", "hotel_text_048"}
	local func_name = Language:getTextByKey(func_names[attr_id])
	local rewards = RewardUtil:mergeRewardAndFormat(reward)
	local reward_count = #rewards
	for i = 1, reward_count do
		local item_reward = rewards[i]
		local data = RewardUtil:getProcessRewardData(item_reward)
		--local color = GlobalConfig.QUALITY_COMMON_SETTING[data.quality].HC
		--if data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT or data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS_EXT or data.data_type == RewardUtil.REWARD_TYPE_KEYS.SEAL_CHARACTER then
		--	color = GlobalConfig.HERO_QUALITY_COMMON_SETTING[data.quality].HC
		--end
		--local text = Language:getTextByKey("hotel_text_050", UserDataManager.user_data:getUserStatusDataByKey("name"), func_name, color, data.name)
		local text = Language:getTextByKey("hotel_text_050", UserDataManager.user_data:getUserStatusDataByKey("name"), func_name, data.name, data.data_num)
		self.m_reward_record = self.m_reward_record .. "\n" .. text
	end
	self:saveRewardRecord(attr_id, self.m_reward_record)
end

--获得奖励日志
function M:getRewardRecord(attr)
	local key = __HOTEL_GACHA_RECORD_KEY .. attr
	local record = UserDataManager.local_data:getUserDataByKey(key, "")
	return record
end

--更新奖励日志
function M:saveRewardRecord(attr, new_record)
	local key = __HOTEL_GACHA_RECORD_KEY .. attr
	UserDataManager.local_data:setUserDataByKey(key, new_record)
end

return M