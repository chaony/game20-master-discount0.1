local M = class("PeakMyGuessPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData("arena_inner_index")
end

function M:onEnter()
	self.m_open_tab_index = 1
	self.m_sel_tab_index = 0
	self.m_top_data = self.m_params.top_data
	self.left_data, self.right_data = self:getGuessBattlePlayerData()
	if self.left_data == nil or self.right_data == nil then
		self.m_open_tab_index = 2
	end
end

function M:getQuizList()
	local new_tab = {}
	for k,v in pairs(self.m_data.quiz_data.step_teams) do
		if v > 0 and self:isGuessId(v) == false then
			table.insert(new_tab, {index = tonumber(k),id = v})
		end
	end
	table.sort(new_tab, function(data1, data2)
		return data1.index > data2.index
	end)
	return new_tab
end

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
	if self.m_data.quiz_data then
		local id_1,id_2 = self:getGuessIds()
		if id_1 == nil or id_2 == nil then
			return nil, nil
		end
		return self.m_data.quiz_data.user_data[tostring(id_1)],self.m_data.quiz_data.user_data[tostring(id_2)]
	end
	return nil, nil
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
