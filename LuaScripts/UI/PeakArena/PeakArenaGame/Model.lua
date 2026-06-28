local M = class("PeakArenaGameModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("arena_outer_index")
end

function M:onEnter()
	self.m_top_data = self.m_params
	self.m_rank_progress = 0 --时间进度 1/小组赛 2/64强 3/8强 
	self.m_selete_index = 1 -- 页签索引
	self.m_id = UserDataManager.user_data:getUid()
	self:setRankProgress()
	self.m_battle_logs = self:myBattleLog()
	if #self.m_battle_logs > 0 then
		self.m_selete_battle_log = 1 --队伍索引	
	end
	self.m_battle_index_64 = 1
	self.m_player_data_64 = self:get64BattleLog()
	self.m_player_data_32 = self:get32BattleLog()
	self.m_player_data_16 = self:get16BattleLog()
	self.m_player_data_8 = self:get8BattleLog()
	self.m_player_data_4 = self:get4BattleLog()
end

function M:setRankProgress()
	if next(self.m_top_data.players) ~= nil then
		self.m_rank_progress = 2
	elseif next(self.m_top_data.group_data) ~= nil then
		self.m_rank_progress = 1
	end
end

function M:getRankType()
	if self:checkMyGroup() == false then
		return 3
	end
	if self.m_top_data.week == 1 then
		return 1
	elseif self.m_top_data.week == 2 then 
		if self:checkMyGroupWinner() == true then
			return 1
		else
			return 4	
		end
	else
		local min, max = self:getCurBattleStatus()
		for i = min,max do
			local c_p_data = self.m_top_data.players[tostring(i)]
			if c_p_data.uid == self.m_id then
				return 1
			end
		end
		return 4
	end
	return 1
end

--是否参与小组赛
function M:checkMyGroup()
	if next(self.m_top_data.group_data) == nil then
		return false
	end
	for k,v in pairs(self.m_top_data.group_data.users) do
		if tonumber(k) == self.m_id then
			return true
		end  
	end
	return false
end

--是否参与小组赛并且胜出
function M:checkMyGroupWinner()
	if next(self.m_top_data.group_data) == nil then
		return false
	end
	if self.m_top_data.group_data.winner == self.m_id then
		return true
	end
end


--我的战斗场次
function M:myBattleLog()
	if next(self.m_top_data.group_data) ~= nil and next(self.m_top_data.group_data.battle_log) ~= nil then
		local m_logs = {}
		for i = 1, #self.m_top_data.group_data.battle_log do
			local c_battle_log = self.m_top_data.group_data.battle_log[i]
			local match_ids = c_battle_log.match
			for k,v in pairs(match_ids) do
				if v == self.m_id then
					table.insert( m_logs, c_battle_log)
					break
				end
			end
		end
		return m_logs
	else
		return {}	
	end
end

function M:getBattlePlayerData(left)
	if self.m_top_data.week == 1 then
		if #self.m_battle_logs > 0 then
			local c_m_data = self.m_battle_logs[self.m_selete_battle_log]
			local ids = c_m_data.match
			if left == 1 then
				return self:getUsersById(self.m_id)
			else
				for k,v in pairs(ids) do
					if v ~= self.m_id then
						return self:getUsersById(v)
					end
				end
			end
		end
	else
		if next(self.m_top_data.players) == nil then
			return nil
		end 
		if left == 1 then
			return self:getUsersById(self.m_id)
		else
			return self:getMyEnemyId()
		end
	end
end

--64强后我的对位数据
function M:getMyEnemyId()
	local m_pos = 0
	local min, max = self:getCurBattleStatus()
	for i = min,max do
		local c_data = self.m_top_data.players[tostring(i)]
		if c_data and c_data.uid == self.m_id then
			m_pos = i
			break
		end
	end
	if m_pos == 0 or m_pos == 1 then
		return {}
	end
	local parent_pos = math.floor(m_pos/2)
	if parent_pos*2 == m_pos then
		return self.m_top_data.players[tostring(parent_pos*2 +1)]
	else
		return self.m_top_data.players[tostring(parent_pos*2)]
	end
end

function M:getUsersById(id)
	return self.m_top_data.group_data.users[tostring(id)]
end

function M:getUserHeadAvatar(avater)
	local cfg = ConfigManager:getPlayerPictureCfg(avater)
	return cfg.hero_spine
end

function M:getTeams(left)
	if self.m_top_data.week == 1 then
		if #self.m_battle_logs > 0 then
			local c_m_data = self.m_battle_logs[self.m_selete_battle_log]
			local ids = c_m_data.match
			if left == 1 then
				local play_data = self:getUsersById(self.m_id)
				return UserDataManager.hero_data:getMultTeamByKey("top_arena")
			else
				for k,v in pairs(ids) do
					if v ~= self.m_id then
						local play_data = self:getUsersById(v)
						return play_data.teams
					end
				end
			end
		end
	else
		if next(self.m_top_data.players) == nil then
			return {}
		end 
		if left == 1 then
			local play_data = self:getUsersById(self.m_id)
			return UserDataManager.hero_data:getMultTeamByKey("top_arena")
		else
			local play_data = self:getMyEnemyId()
			return play_data.teams or {}
		end
	end
	local new_tab = {
		{101,102,103,104,105},
		{201,202,203,0,205},
		{301,302,403,304,305},
	}
	return new_tab
end

--我的比赛敌人英雄
function M:getEnemyHeroData(oid)
	if self.m_top_data.week == 1 then
		if #self.m_battle_logs > 0 then
			local c_m_data = self.m_battle_logs[self.m_selete_battle_log]
			local ids = c_m_data.match
			for k,v in pairs(ids) do
				if v ~= self.m_id then
					local play_data = self:getUsersById(v)
					return play_data.heros[oid]
				end
			end
		end
	else
		local play_data = self:getMyEnemyId()
		return play_data.heros[oid]
	end
end

function M:geMyGameTeams()
	local new_tab = {}
	local m_user = self:getUsersById(self.m_id)
	if m_user then
		new_tab = table.copy(m_user.heros)
	end
	if self.m_top_data.week == 1 then
		if #self.m_battle_logs > 0 then
			local c_m_data = self.m_battle_logs[self.m_selete_battle_log]
			local ids = c_m_data.match
			for k,v in pairs(ids) do
				if v ~= self.m_id then
					local play_data = self:getUsersById(v)
					table.merge(new_tab, play_data.heros)
					return new_tab
				end
			end
		end
	else
		local play_data = self:getMyEnemyId()
		if play_data.heros then
			table.merge(new_tab, play_data.heros)
		end
		return new_tab
	end
end

function M:checkTeamLock()
	local c_tim = UserDataManager:getServerTime()
	local end_ts = self:getDownTime()
	local last_tim = end_ts - c_tim
	if last_tim < 3600 then
		return false
	end
	return true
end

function M:getDownTime()
	return UserDataManager.end_ts
end

function M:check64Win()
	if next(self.m_top_data.players) == nil then
		return false
	end 
end

function M:check8Win()
	if next(self.m_top_data.players) == nil then
		return false
	end 
	if self.m_top_data.players[tostring(8)] == nil then
		return false
	end 
	return true
end

function M:getUnionTripo(left, index)
	if #self.m_battle_logs > 0 then
		local c_m_data = self.m_battle_logs[self.m_selete_battle_log]
		local ids = c_m_data.match
		if left == 1 then
			local play_data = self:getUsersById(self.m_id)
			return self:getTripodCfgByType(index, play_data.tripods) 
		else
			for k,v in pairs(ids) do
				if v ~= self.m_id then
					local play_data = self:getUsersById(v)
					return self:getTripodCfgByType(index, play_data.tripods or {}) 
				end
			end
		end
	end
end

--[[
1防御
2治疗
3内功输出
4外功输出
]]
function M:getTripodCfgByType(guild_tripod_type, tripods)
	tripods = tripods or {}
	local guild_tripod = ConfigManager:getCfgByName("guild_tripod")
	local type_cfg = guild_tripod[guild_tripod_type] or {}
	local lv = tripods[tostring(guild_tripod_type)] or 0
	local cfg = table.copy(type_cfg.config[lv]) or {}
	cfg.heroes_list = type_cfg.heroes_list
	cfg.name = type_cfg.name
	return cfg, lv
end


--64强
function M:get64BattleLog()
	if next(self.m_top_data.players) == nil then
		return {}
	end 
	local new_tab = {}
	local team_index = 1
	for t_key = team_index, 8 do
		for i = 1,8 do
			local index = 64 + i - 1 + (t_key-1) * 8
			local c_player = self.m_top_data.players[tostring(index)]
			if c_player then
				c_player.index = index
				if new_tab[t_key] then
					table.insert(new_tab[t_key], c_player)
				else
					new_tab[t_key] = {c_player}
				end
			end
		end
	end
	return new_tab
end

--32强
function M:get32BattleLog()
	if next(self.m_top_data.players) == nil then
		return {}
	end 
	local new_tab = {}
	local team_index = 1
	for t_key = team_index, 8 do
		for i = 1,4 do
			local index = 32 + i - 1 + (t_key-1) * 4
			local c_player = self.m_top_data.players[tostring(index)]
			if c_player then
				c_player.index = index
				if new_tab[t_key] then
					table.insert(new_tab[t_key], c_player)
				else
					new_tab[t_key] = {c_player}
				end
			end
		end
	end
	return new_tab
end

function M:get16BattleLog()
	if next(self.m_top_data.players) == nil then
		return {}
	end 
	local new_tab = {}
	local team_index = 1
	for t_key = team_index, 8 do
		for i = 1,2 do
			local index = 16 + i - 1 + (t_key-1) * 2
			local c_player = self.m_top_data.players[tostring(index)]
			if c_player then
				c_player.index = index
				if new_tab[t_key] then
					table.insert(new_tab[t_key], c_player)
				else
					new_tab[t_key] = {c_player}
				end
			end
		end
	end
	return new_tab
end

function M:get8BattleLog()
	if next(self.m_top_data.players) == nil then
		return {}
	end 
	local new_tab = {}
	local team_index = 1
	for t_key = 8, 15 do
		local c_player = self.m_top_data.players[tostring(t_key)]
		if c_player then
			c_player.index = t_key
			new_tab[t_key-7] = c_player
		end
	end
	return new_tab
end

function M:get4BattleLog()
	if next(self.m_top_data.players) == nil then
		return {}
	end 
	local new_tab = {}
	local team_index = 1
	for t_key = 4, 7 do
		local c_player = self.m_top_data.players[tostring(t_key)]
		if c_player then
			c_player.index = t_key
			new_tab[t_key-3] = c_player
		end
	end
	return new_tab
end

--64强玩家数据
function M:getPlayerDataByIndex(index)
	local team_s = self.m_player_data_64[self.m_battle_index_64] or {}
	if next(team_s) ~= nil then
		return team_s[index-7]
	end
	return nil
end

--32强玩家数据
function M:getPlayerDataByIndex2(index)
	local team_s = self.m_player_data_32[self.m_battle_index_64] or {}
	if next(team_s) ~= nil then
		return team_s[index-3]
	end
	return nil
end

--16强玩家数据
function M:getPlayerDataByIndex3(index)
	local team_s = self.m_player_data_16[self.m_battle_index_64] or {}
	if next(team_s) ~= nil then
		return team_s[index-1]
	end
	return nil
end

--8强玩家数据
function M:getPlayerDataByIndex4(index)
	local team_s = self.m_player_data_8[self.m_battle_index_64] or {}
	if next(team_s) ~= nil then
		return team_s
	end
	return nil
end

--八强赛数据
function M:getWinPlayerData(index)
	local team_s = self.m_player_data_8[index-7] or {}
	if next(team_s) ~= nil then
		return team_s
	end
	return nil
end
--4强赛数据
function M:getWinPlayerData2(index)
	local team_s = self.m_player_data_4[index-3] or {}
	if next(team_s) ~= nil then
		return team_s
	end
	return nil
end
--决赛数据
function M:getWinPlayerData3(index)
	local team_s = self.m_top_data.players[tostring(index)] or {}
	if next(team_s) ~= nil then
		team_s.index = index
		return team_s
	end
	return nil
end
--冠军数据
function M:getWinPlayerData4(index)
	local team_s = self.m_top_data.players[tostring(1)] or {}
	if next(team_s) ~= nil then
		team_s.index = index
		return team_s
	end
	return nil
end

function M:checkPromotionDataByIndex(index)
	local father_pos = math.floor(index/2)
	return self.m_top_data.players[tostring(father_pos)]
end

--当前赛程 1 小组赛 2 64强赛 3 8强赛  4已结束
function M:getCurBattleStatus()
	if self.m_top_data.week == 1 then
		return 1000, 9999 --"小组赛"
	elseif self.m_top_data.week == 2 then
		return 64,127-- "64强赛"
	elseif self.m_top_data.week == 3 then
		return 32,63 -- "32强赛"
	elseif self.m_top_data.week == 4 then
		return 16,31 --"16强赛"
	elseif self.m_top_data.week == 5 then
		return 8,15 -- "8强赛"
	elseif self.m_top_data.week == 6 then
		return 4,7--"4强赛"
	elseif self.m_top_data.week == 7 then
		return 2,3 --"冠军"
	end
end

--当前竞猜ids
function M:getGuessIds()
	local pos_id = 0
	local min, max = self:getCurBattleStatus()
	if self.m_top_data.week == 1 then
		if self.m_top_data.group_data.battle_log then
			pos_id = self:getGuessByScope(1000)
			for k,v in pairs(self.m_top_data.group_data.battle_log) do
				if v.team_id == pos_id then
					return v.match[1], v.match[2]
				end
			end
		else
			return nil, nil
		end
	else
		return self:getGuessByScope(min, max)
	end
end

--获取位置id
function M:getGuessByScope(min, max)
	if min >= 1000 then
		for k,v in pairs(self.m_top_data.quiz_data.step_teams) do
			if v >= 1000 then
				return v
			end
		end
	else
		for k,v in pairs(self.m_top_data.quiz_data.step_teams) do
			if v*2 >= min and v*2 <= max then
				return self.m_top_data.players[tostring(v*2)].uid, self.m_top_data.players[tostring(v*2+1)].uid
			end
		end
	end
end

function M:getGuessKey()
	local pos_id = 0
	local min, max = self:getCurBattleStatus()
	if self.m_top_data.week == 1 then
		pos_id = self:getGuessByScope(1000)
	else
		for k,v in pairs(self.m_top_data.quiz_data.step_teams) do
			if v*2 >= min and v*2 <= max then
				pos_id = v
			end
		end
	end
	return pos_id
end

-- 竞猜玩家数据
function M:getGuessBattlePlayerData()
	if self.m_top_data.quiz_data then
		local id_1,id_2 = self:getGuessIds()
		if id_1 == nil or id_2 == nil then
			return nil, nil
		end
		return self.m_top_data.quiz_data.user_data[tostring(id_1)],self.m_top_data.quiz_data.user_data[tostring(id_2)]
	end
	return nil, nil
end

--竞猜票数
function M:getGuessTicketNum(id)
	return self.m_top_data.quiz_count[tostring(id)] or 0
end

--竞猜押注数据
function M:getGuessData()
	if self.m_top_data.quiz_data then
		local key = self:getGuessKey()
		-- [自己猜的uid, 实际赢的uid，押注金额]
		return self.m_top_data.guess_data[tostring(key)] or {}
	end
	return {}
end

function M:getGuessAlert()
	if next(self.m_top_data.need_alert) == nil then
		return nil
	end
	for k,v in pairs(self.m_top_data.need_alert) do
		return v
	end
end

--我当前的积分排名
function M:getMyScoreRank()
	return self.m_top_data.score_rank or 0
end

function M:checkCanClick()
	local lock_tim = ConfigManager:getCommonValueById(415) * 60
	local server_time = UserDataManager:getServerTime()
	local next_fresh_time = TimeUtil.getIntTimestamp(server_time)
	if server_time >= next_fresh_time+lock_tim then
		return true
	end
	return false
end

return M
