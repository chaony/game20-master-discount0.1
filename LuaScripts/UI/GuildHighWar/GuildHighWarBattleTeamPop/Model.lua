local M = class("GuildHighWarBattleTeamPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("guild_high_war_dispatch_teams")
end

function M:onEnter()
	self.m_cur_city_name = ""
	self.m_guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
	self.m_guild_high_war_build = ConfigManager:getCfgByName("guild_high_war_build") or {}
	self.m_total_city_data = self.m_params.total_city_data or {}
	self.m_total_guild_data = self.m_params.total_guild_data or {}
	self.m_user_infos = self.m_data.user_infos or {}
	self.m_city_datas = self.m_data.city_datas or {}
	self.m_citys = self.m_data.citys or {}
	self.m_guild_data = self:getGuildDataById(self.m_guild_id) or {}
	self.m_city_id_tab = self:initCityData()
	self.m_city_index = 1
	self.m_open_tab_index = 1
	self.m_all_city = {}
	self.m_all_city[self.m_city_index] = self:getTeamInfoByCityId(self.m_city_index)
	self.position =  self.m_params.position or 0
	self.can_chance = self.m_data.can_change or false --是否能编辑队伍
	------------------------------------------我的队伍
    self.m_is_open_myteam = false 
	self.m_open_type = self.m_params.open_type or ""
	self.m_city_id = self.m_params.city_id or 0
	self.m_parent_model = self.m_params.parent_model
	self.mult_main_teams = {}
	self.team_num = 0
	--self.m_guild_high_war_build = ConfigManager:getCfgByName("guild_high_war_build") or {}
	--------------------------------------------我的队伍
end

function M:UpdateData(data)
	self.m_user_infos = data.user_infos or self.m_user_infos
	for k,v in pairs(self.m_city_datas) do
		if data.city_datas[1] and v.city_id == data.city_datas[1].city_id then
			v.team_info = data.city_datas[1].team_info
			break
		end
	end
	self.m_city_id_tab = self:initCityData()
	--self.m_all_city[self.m_city_index] = data.city_datas[1].team_info or {}
	--self.m_city_datas[self.m_city_index] 
end

function M:UpdateDataLoad(data)
	for k,v in pairs(self.m_city_datas) do
		if data.city_datas[1] and v.city_id == data.city_datas[1].city_id then
			for m,n in pairs(data.city_datas[1].team_info) do 
				table.insert(v.team_info,n)
			end
			break
		end
	end
	self.m_city_id_tab = self:initCityData()
end

function M:getCityTeamDataByCityId(city_id)
	if self.m_city_datas[tonumber(city_id)] then
		return self.m_city_datas[tonumber(city_id)]
	end
	return nil
end

function M:getTeamInfoByCityId(city_id)
	local team_data = self:getCityTeamDataByCityId(city_id) or {}
	return team_data.team_info
end

function M:getLoadIndex()
	local max_rank_count = self:getCityTeamDataByCityId(self.m_city_index).team_num or 0
	local cur_rank_nums = table.nums(self:getTeamInfoByCityId(self.m_city_index))
	local start_pos, end_pos = 0, 0
	if cur_rank_nums + 10 <= max_rank_count then
		start_pos = cur_rank_nums + 1
		end_pos = cur_rank_nums + 10
	elseif max_rank_count - cur_rank_nums > 0 then
		start_pos = cur_rank_nums + 1
		end_pos = max_rank_count
	end
	return start_pos, end_pos
end

--上移
function M:setTopTeamInfoByCityId(city_id,data,num)
	local teamInfo =  self.m_city_datas[tonumber(city_id)].team_info
	local data_ = data
	local realInfo = {}
	for k,v in ipairs(teamInfo) do
		if num == (#realInfo +1) then
			table.insert(realInfo,data_)
		end
		if data.team_id ~=v.team_id then
			table.insert(realInfo,v)
		end
		if data.team_id ==v.team_id and data.uid~= v.uid then
			table.insert(realInfo,v)
		end
	end
	self.m_city_datas[tonumber(city_id)].team_info = realInfo
end


function M:isAtk(city_id)
	local is_atk = false
	local _, atk_guild_id = self:getAtkGuildNameByCityId(city_id)
	if self.m_guild_id > 0 and self.m_guild_id == atk_guild_id then
		is_atk = true
	end
	return is_atk
end

function M:isDef(city_id)
	local is_def = false
	local _, def_guild_id = self:getOwnerNameByCityId(city_id)
	if self.m_guild_id > 0 and self.m_guild_id == def_guild_id then
		is_def = true
	end
	return is_def
end

function M:getCityInfoById(city_id)
	city_id = tostring(city_id)
	if self.m_total_city_data[city_id] then
		return self.m_total_city_data[city_id]
	end
	return nil
end

function M:getGuildDataById(guild_id)
	guild_id = tostring(guild_id)
	if self.m_total_guild_data[guild_id] then
		return self.m_total_guild_data[guild_id]
	end
	return nil
end

function M:getOwnerNameByCityId(city_id)
	local owner_name, owner_guild_id = "", 0
	local city_data = self:getCityInfoById(city_id)
	if city_data then
		local owner_guild = city_data.owner_guild or {}
		owner_guild_id = owner_guild.guild_id
		local guild_data = self:getGuildDataById(owner_guild_id)
		if guild_data then
			owner_name = guild_data.name
		end
	end
	return owner_name, owner_guild_id
end

function M:getAtkGuildNameByCityId(city_id)
	local atk_name, atk_guild_id = "", 0
	local city_data = self:getCityInfoById(city_id)
	if city_data then
		local challenger_guild = city_data.challenger_guild or {}
		local challenger_guild_id = challenger_guild.guild_id or 0
		atk_guild_id = challenger_guild_id
		local guild_data = self:getGuildDataById(challenger_guild_id)
		if guild_data then
			atk_name = guild_data.name
		end
	end
	return atk_name, atk_guild_id
end

function M:initCityData()
	local city_data = {}
	for i, v in pairs(self.m_city_datas) do
		local is_atk = self:isAtk(v.city_id)
		local is_def = self:isDef(v.city_id)
		
		if is_atk or is_def then
			city_data[#city_data + 1] = {city_index = i, is_atk = is_atk}
		end
		if v.team_info then
			for team_index = 1, #(v.team_info) do
				local team_data = v.team_info[team_index]
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
	table.sort(city_data, function(a, b) 
		return tonumber(a.city_index) < tonumber(b.city_index)
	end)
	return city_data
end

function M:getCfgValueByKey(city_id, cfg_key)
	local city_cfg = self.m_guild_high_war_build[tonumber(city_id)] or {}
	if city_cfg[cfg_key] then
		return city_cfg[cfg_key]
	end
	return nil
end

function M:getUserDataByUid(uid)
	if self.m_user_infos[tostring(uid)] then
		return self.m_user_infos[tostring(uid)]
	end
	return nil
end

-------------------------------------------------------------我的队伍
function M:updateTeams(teams)
	--if teams then
	--	table.merge(self.mult_main_teams, teams)
	--end
	self.mult_main_teams = teams
end

function M:getShowData()
	local show_data = {}
	local high_arena_defense = self.mult_main_teams
	local num = self.team_num
	--for k,v in pairs(high_arena_defense) do 
	--	num = num + 1
	--end
	for i = 1,num do
		local formation_data = high_arena_defense[tostring(i)] or {}
		local team = formation_data.team or {}
		local team_heros_data = {}
		if formation_data.boss_team == false or formation_data.boss_team ==nil then
			for index = 1,5 do
				local hero_id = team[index] or ""
				local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(hero_id)
				local data = nil
				if hero_data and hero_cfg then
					data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
					data.quality = hero_data.evo
					data.card_id = hero_id
					data.hero_data = hero_data
				end
				team_heros_data[index] = data or {}
			end
			show_data[i] = {team_heros_data = team_heros_data,boss_team =false}
		else
			show_data[i] = {team_heros_data = team_heros_data,boss_team =true}
		end
	end
	return show_data
end

function M:getTeamCityId(team_index)
	local formation_data = self.mult_main_teams[tostring(team_index)] or {}
	local city_id = formation_data.city_id or 0
	return city_id
end

--function M:getCfgValueByKey(city_id, cfg_key)
--	local city_cfg = self.m_guild_high_war_build[city_id] or {}
--	if city_cfg[cfg_key] then
--		return city_cfg[cfg_key]
--	end
--	return nil
--end
-------------------------------------------------------------我的队伍

return M
