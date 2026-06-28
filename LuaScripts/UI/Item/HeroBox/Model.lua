local M = class("HeroBoxModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_show_data = self.m_params.show_data
	self.m_use_num = self.m_params.use_num or 1
	self.m_isShowDropType = (self.m_params.isShowDropType ~= nil) and self.m_params.isShowDropType or -1
	self.m_isShowBtnType = (self.m_params.isShowBtnType ~= nil) and self.m_params.isShowBtnType or 1
	self.m_callBack = self.m_params.callBack
	
	self.cur_select_index = 0
end

function M:getUseNum()
	return self.m_use_num
end

function M:getShowData()
	if self.m_show_data.item_cfg.type == GlobalConfig.ITEM_TYPE.SEASON_BOX then
		return self:getFetterHerosForSeason(self.m_show_data.item_effect or {})
	end
	return self.m_show_data.item_cfg.effect
end

function M:getDataCount()
	return #self.m_show_data.item_cfg.effect
end

function M:getDataByIndex(index)
    return self.m_show_data.item_cfg.effect[index]
end

--- 网络数据回调
function M:netData(data, tag)
	local item_id = self.m_show_data.data_id
	local item_data = UserDataManager.item_data:getItemDataById(item_id)
	self.m_show_data.user_num = item_data.num
end

function M:isHeroReward()
	local show_data = self.m_show_data
	local item_cfg = show_data.item_cfg or {}
	local effect = item_cfg.effect or {}
	if item_cfg.type == GlobalConfig.ITEM_TYPE.SEASON_BOX then
		effect = show_data.item_effect or {}
	end
	local flag = true
	for k,v in pairs(effect) do
		if v[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS then
			flag = false
			break
		end
	end
	return flag
end

function M:getFetterHerosForSeason(hero_data)
	local new_hero_tab = {}
	local cur_season = UserDataManager:getCurSeason()
	local cur_season_day = UserDataManager:getCurSeasonDay()
	local cfg_season
	local cfg_season_day
	local hero_item
	for k, v in pairs(hero_data) do
		hero_item = RewardUtil:getProcessRewardData(v)
		cfg_season = hero_item.item_cfg.season
		cfg_season_day = hero_item.item_cfg.season_day or 0
		if (cfg_season < cur_season) or (cfg_season == cur_season and ((cfg_season_day == 0) or (cfg_season_day ~= 0 and cfg_season_day <= cur_season_day))) then
			table.insert(new_hero_tab, v)
		end
	end
	return new_hero_tab
end

return M
