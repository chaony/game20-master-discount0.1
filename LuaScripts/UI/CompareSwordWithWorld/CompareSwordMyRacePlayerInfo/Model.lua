local M = class("CompareSwordMyRacePlayerInfoModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	local role_id = self.m_params.uid or UserDataManager.user_data:getUid()
	self:getData("full_service_get_top_10_team",{target_uid = role_id})
end

function M:onEnter()
	--local cfg = ConfigManager:getCfgByName("") --获取配置表数据
	self.hero_data = {}
	self.heros = self.m_data.heros or {}
	self.teams = self.m_data.team or {}
	self:initData()
end

function M:initData()
	for k,v in pairs(self.teams) do
		local hero_data =  self.heros[v] or {}
		hero_data.index = tonumber(k)
		table.insert(self.hero_data,hero_data)
	end
	table.sort(self.hero_data,function(a, b) 
		return a.index<b.index
	end)
end

function M:updateData( response )
	-- use mothed in control , for update from net 
	table.merge(self.m_data , response)
	self:initData()
end

function M:getShowHeroData(hero_data)
	if hero_data then
		local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
		data.quality = hero_data.evo
		data.card_id = hero_id
		data.hero_data = hero_data
		return data
	end
end

--根据id获得英雄数据
function M:getHero(id)
	local data = self.m_heros[id]
	return data, UserDataManager.hero_data:getHeroConfigByCid(data.id)
end

function M:destroy()

	M.super.destroy(self)
end

return M