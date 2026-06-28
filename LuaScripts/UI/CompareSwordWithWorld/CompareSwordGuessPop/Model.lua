local M = class("CompareSwordGuessPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self.m_open_tab_index = 1
	self.m_sel_tab_index = 0
	self.open_type = self.m_params.open_type or 0 --0 主入口进入 --1 支持入口进入
	self.m_top_data = self.m_params.top_data
	self.left_data = self.m_params.left_data or nil
	self.right_data = self.m_params.right_data or nil
	self.typ = self.m_params.typ
	self.raceType = self.m_params.raceType -- 2积分赛 ， 3晋级赛
	self.round_stage = self.m_params.round_stage --晋级赛回合数
	self.group_id = self.m_params.group_id
	self.rounds = self.m_params.rounds
	self.uuid = self.m_params.uuid
	self.point_race_guess_data = self.m_params.point_race_guess_data or {}
	self.m_open_tab_index = 1
	--self.left_data, self.right_data = self:getGuessBattlePlayerData()
	self.guess_times = self.m_params.guess_times or 0
	self.total_guess_times = self.m_params.total_guess_times or 0

	if self.raceType == 3 then --晋级赛
		self.m_open_tab_index = 1
	else	--积分赛
		if self.open_type == 0 then
			self.m_open_tab_index = self.guess_times==0 and 1 or 2
		else
			self.m_open_tab_index = 1
		end
	end

	self.guess_data = {}
	self.is_support_type = 0 -- 0 全支持 1 支持 左 2 支持右

	if  self.raceType == 2 then
		self:getData("full_service_my_guess_v2")
	elseif self.raceType == 3 then
		self:getData("full_service_top_guess_index")
	end

end

function M:onEnter()
	self:UpdateGuessData(self.m_data or {})
end

function M:getQuizList()
	return self.guess_data or {}
end

function M:UpdateGuessData(response)
	self.guess_data = response.guess_data or {}
	self.guess_times = response.guess_times or self.guess_times
	self.total_guess_times = response.total_guess_times or self.total_guess_times
end

-----------------------by  liu
function M:getGuessResult(id)
	return self.m_data.guess_data[tostring(id)] or {}
end

function M:isGuessId(g_id)
	local min,max = self:getCurBattleStatus()
	if g_id*2 >= min and g_id*2 < max then
		return true
	end
	return false
end

function M:getCurBattleStatus()
	if self.m_top_data.week == 1 then
		return 1000, 9999 --"小组赛"
	elseif self.m_top_data.week == 2 then
		return 32,63 -- "32强赛"
	elseif self.m_top_data.week == 3 then
		return 16,31 --"16强赛"
	elseif self.m_top_data.week == 4 then
		return 8,15 -- "8强赛"
	elseif self.m_top_data.week == 5 then
		return 4,7--"4强赛"
	elseif self.m_top_data.week == 6 then
		return 2,3 --"冠军"
	end
	return 0,0
end


function M:getGuessData(id)
	if id >= 1000 then
		return self:getGroupData(id)
	else
		return self:getGroupData2(id)
	end
end

--竞猜押注数据
function M:getMyGuessData()
	if self.m_data.quiz_data then
		local key = self:getGuessKey()
		-- [自己猜的uid, 实际赢的uid，押注金额]
		return self.m_data.guess_data[tostring(key)] or {}
	end
	return {}
end

function M:getGuessKey()
	local pos_id = 0
	local min, max = self:getCurBattleStatus()
	if self.m_top_data.week == 1 then
		pos_id = self:getGuessByScope(1000)
	else
		for k,v in pairs(self.m_data.quiz_data.step_teams) do
			if v*2 >= min and v*2 <= max then
				pos_id = v
			end
		end
	end
	return pos_id
end

function M:getGroupData(id)
	if self.m_data.group_data.battle_log ~= nil then
		for k,v in pairs(self.m_data.group_data.battle_log) do
			if id == v.team_id then
				return self:getGuessPlayerData(v.match[1]),self:getGuessPlayerData(v.match[2])
			end
		end
	else
		return {}, {}	
	end
end

function M:getGroupData2(id)
	local pos_1, pos_2 = self.m_data.players[tostring(id*2)].uid, self.m_data.players[tostring(id*2+1)].uid
	return self:getGuessPlayerData(pos_1),self:getGuessPlayerData(pos_2)
end

--当前赛程 1 小组赛 2 64强赛 3 8强赛  4已结束
function M:getCurBattleStatusName(team_id)
	if team_id >= 1000 then
		return Language:getTextByKey("peak_str_0032") 
	elseif team_id >= 32 then
		return Language:getTextByKey("peak_str_0039") 
	elseif team_id >= 16 then
		return Language:getTextByKey("peak_str_0040") --"16强赛"
	elseif team_id >= 8 then
		return Language:getTextByKey("peak_str_0041") --"8强赛"
	elseif team_id >= 4 then
		return Language:getTextByKey("peak_str_0042") --"4强赛"
	elseif team_id >= 2 then
		return Language:getTextByKey("peak_str_0034")--"冠军赛"
	else
		return Language:getTextByKey("peak_str_0034")--"冠军赛"
	end
end

function M:getGuessPlayerData(uid)
	return self.m_data.quiz_data.user_data[tostring(uid)]
end

function M:getBattleId(id)
	if id >= 1000 then
		for k,v in pairs(self.m_data.group_data.battle_log) do
			if id == v.team_id then
				return v.battle_id
			end
		end
	else
		return self.m_data.players[tostring(id)].battle_id
		-- if id == 1 then
			
		-- else 
		-- 	return self.m_data.players[tostring(id*2)].battle_id
		-- end
	end
end

-- 竞猜玩家数据
function M:getGuessBattlePlayerData()
	--if self.m_data.quiz_data then
	--	local id_1,id_2 = self:getGuessIds()
	--	if id_1 == nil or id_2 == nil then
	--		return nil, nil
	--	end
	--	return self.m_data.quiz_data.user_data[tostring(id_1)],self.m_data.quiz_data.user_data[tostring(id_2)]
	--end
	--return nil, nil
	return self.left_data,self.right_data
end

--当前竞猜ids
function M:getGuessIds()
	local pos_id = 0
	local min, max = self:getCurBattleStatus()
	if self.m_top_data.week == 1 then
		if self.m_data.group_data.battle_log then
			pos_id = self:getGuessByScope(1000)
			for k,v in pairs(self.m_data.group_data.battle_log) do
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
		for k,v in pairs(self.m_data.quiz_data.step_teams) do
			if v >= 1000 then
				return v
			end
		end
	else
		for k,v in pairs(self.m_data.quiz_data.step_teams) do
			if v >0 and v*2 >= min and v*2 <= max then
				return self.m_data.players[tostring(v*2)].uid, self.m_data.players[tostring(v*2+1)].uid
			end
		end
	end
end

return M
