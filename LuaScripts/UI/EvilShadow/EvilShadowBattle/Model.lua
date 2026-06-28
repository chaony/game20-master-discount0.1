local M = class("EvilShadowBattleModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("evil_shadow_train_index")
end

function M:onEnter()
	self.m_rank_type = 0 --1日排行数据, 0期排行数据
	self.m_version = self.m_params.version or 0
	self.m_max_damage = self.m_params.max_damage or 0
	self.m_open_status = self.m_params.open_status or 0
	self.m_rank_data = {}
	self.m_current_day = self.m_params.current_day or 0
	
	local hero_data_oid_list = UserDataManager.hero_data:getHerosIdByFilterFunc(function(hero_data, hero_cfg)
		if hero_cfg.id == 602 then
			return true;
		end
	end)
	self.mood_shadow = ConfigManager:getCfgByName("evil_shadow")
	self.cur_verson_mood_shadow = self.mood_shadow[self.m_version]
	UserDataManager.hero_data:heroIdsSort(hero_data_oid_list)
	self.cur_hero_id = hero_data_oid_list[1]
	if self.cur_hero_id ~= nil then
		self.cur_hero = UserDataManager.hero_data:getHeroDataById(self.cur_hero_id);
	end
end

function M:getVersion()
	return self.m_version
end

function M:getCurrentDay()
	return self.m_current_day
end

function M:getRankType()
	return self.m_rank_type
end

function M:updateRankData(data)
	self.m_rank_data = data
end

function M:getRankData()
	if self.m_rank_data then
		return self.m_rank_data.ranks or {}
	end
	return {}
end

function M:getEnemy()
	if self.m_params then
		return self.m_params.enemy
	end
	return {}
end

function M:getHeirloom()
	if self.m_params then
		return self.m_params.heirloom
	end
	return {}
end

function M:setMaxDamageData(damage)
	self.m_max_damage = damage
end

function M:getMaxDamage()
	return self.m_max_damage
end

return M
