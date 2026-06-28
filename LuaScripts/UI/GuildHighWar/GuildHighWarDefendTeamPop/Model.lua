local M = class("GuildHighWarDefendTeamPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_city_id = self.m_params.city_id or 0
	self:getData("guild_high_war_dispatch_teams", {city_id = self.m_city_id})
end

function M:onEnter()
	self.m_user_infos = self.m_data.user_infos or {}
	self.m_city_datas = self.m_data.city_datas or {}
	self.m_citys = self.m_data.citys or {}
	self.m_city_team_data = self:getCityTeamDataByCityId(self.m_city_id) or {}
	self.position =  self.m_params.position or 0
	self.can_chance = self.m_data.can_change or false --是否能编辑队伍
	self:initShowHeroData()
end

function M:removeTeamData(team_id)
	local ownUid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	if self.m_city_team_data.team_info  then
		for k,v in pairs(self.m_city_team_data.team_info) do
			if v.team_id == team_id and ownUid == v.uid then
				table.remove(self.m_city_team_data.team_info, k)
			end
		end
	end
end

function M:initShowHeroData()
	if self.m_city_team_data.team_info then
		for team_index = 1, #self.m_city_team_data.team_info do
			local team_data = self.m_city_team_data.team_info[team_index]
			for hero_index = 1, 5 do
				local hero_id = team_data.team[hero_index]
				if hero_id and hero_id ~= "" then
					local hero_data = team_data.heros[hero_id]
					if hero_data then
						local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
						data.quality = hero_data.evo
						data.card_id = hero_id
						data.hero_data = hero_data
						if team_data.show_hero == nil then
							team_data.show_hero = {}
						end
						team_data.show_hero[hero_id] = data
					end
				end
			end
		end
	end
end

function M:getCityTeamDataByCityId(city_id)
	if self.m_city_datas[1] then
		return self.m_city_datas[1]
	end
	return nil
end

function M:getUserDataByUid(uid)
	if self.m_user_infos[tostring(uid)] then
		return self.m_user_infos[tostring(uid)]
	end
	return nil
end
return M
