local M = class("CompareSwordRaceModel", LikeOO.OODataBase)

local rankListLoadStep = 10

function M:onCreate()
	M.super.onCreate(self)
	self.m_join_self = self.m_params.join_self
	self.m_version = self.m_params.version
	self.m_active_day = self.m_params.active_day
	self.m_data_racePhase = self.m_params.data_racePhase	--服务器返回的阶段
	self.m_phase_day = self.m_params.phase_day
	self.m_guessTimes = self.m_params.guess_times
	self.m_total_guess_times = self.m_params.total_guess_times
	self.racePhase = self.m_params.racePhase or 2	--积分赛2 晋级赛3
	--积分赛
	self.raceType = self.m_params.raceType 	or 1	--天赛 1  地赛 2
	self.group = self.m_params.group or 0 --当前组

	--晋级赛
	self.sel_round_stage = self.m_data_racePhase == 5 and 1 or self.m_phase_day
	
	local normalRound  = self:getCurRound() --打开界面默认选择的回合
	if normalRound == 0 then normalRound = 1 end
	if normalRound == -1 then normalRound = 10 end
	if self.m_data_racePhase == 3 then
		normalRound = 1
	end
	self.sel_round = normalRound - 1	--选中的回合 服务器回合数下标从0开始

	if not self:checkGroupIsDone() then --检测分组是否完成
		return
	end
	if self.racePhase == 2 then	--积分赛协议
		self:getData("full_service_point_race_battle_group_info", { typ = self.raceType or 1, group_id = self.group or 0, rounds = self.sel_round , start = 0, stop = 10 })
	elseif self.racePhase == 3 then	--todo:晋级赛协议
		self:getData("full_service_top_enter" , {typ = self.raceType or 1  , round_stage = self.sel_round_stage , start = 0, stop = 10})
	end
end

function M:onEnter()
	local netData = self.m_data  
	self.cur_rounds_data_list = {}
	self.total_data_list = {}
	
	self:initData()
end

function M:initData(data)
	--init net data
	self.m_data = data or self.m_data
	if self.m_data == nil then return end
	self.cur_round = self:getCurRound()	--0 当天比赛未开始 -1 当前比赛全部结束
	if self.m_data_racePhase == 3 or self.m_data_racePhase == 4 then
		self.cur_rounds_data_list = self.m_data.battle_group
	elseif self.m_data_racePhase == 5 or self.m_data_racePhase == 6 then
		self.cur_rounds_data_list = self.m_data.battles
	end
	self.data_total_count = self.m_data.count
	
end

--积分赛切换轮次 todo：放到control中
function M:switchRound(roundIdx , callback)
	self.sel_round = roundIdx
	local params = {
		typ = self.raceType or 1,
		group_id = self.group or 0,
		rounds = self.sel_round or 0,
		start = 0, stop = 10
	}
	self:getNetData("full_service_point_race_battle_group_info", params, function(data)
		self:initData(data)
		if callback then  callback() end 
	end)
end


function M:getRankData()
	local rankData = self.cur_rounds_data_list
	return rankData
end

function M:getLoadIndex()
	local max_rank_count = self.m_data.count
	local cur_rank_nums = table.nums(self:getRankData())
	local start_pos, end_pos = 0, 0 
	if cur_rank_nums + rankListLoadStep <= max_rank_count then 
		start_pos = cur_rank_nums + 1
		end_pos = cur_rank_nums + rankListLoadStep
	elseif max_rank_count - cur_rank_nums > 0 then 
		start_pos = cur_rank_nums + 1
		end_pos = max_rank_count
	end
	return start_pos, end_pos
end

function M:insertRankData(new_rank_data)
	for i = 1, #new_rank_data do
		table.insert(self.cur_rounds_data_list, new_rank_data[i])
	end
end

function M:getCurTm()
	local time = UserDataManager:getServerTime()
	local curTm = TimeUtil.gmTime(time)
	return curTm
end

function M:getCurRound() --0 当天比赛未开始 -1 当前比赛全部结束
	local result
	local curTm = self:getCurTm()
	if curTm.hour - 9 <= 0 then  return 0 end	
	--todo: 从表中获取开始间隔时间
	if curTm.hour - 9 > 10 then return -1 end
	result = Mathf.Clamp(curTm.hour - 9, 1, 10)
	return result
end

--获取回合结束时间戳
function M:getRoundEndTs(round)
	local r = round and round or 1
	local startHour = 10	--开始时间
	local interval = 1		--每回合的间隔
	local tm = self:getCurTm()
	local round_ts = os.time({year = tm.year, month = tm.month, day = tm.day, hour = startHour + (r * interval) , min = 0, sec = 0})
	return round_ts
end

function M:getPointRaceRoundEndTimeStamp()
	local startHour = 10
	local totalRound = 10
	local result = -1
	if self:getCurTm().hour < startHour + totalRound  then
		local roundTS = self:getRoundEndTs(self.cur_round)
		local curTimestemp = UserDataManager:getServerTime()
		result = roundTS - curTimestemp
		if result <= 0 then
			local params = {
				typ = self.raceType or 1,
				group_id = self.group or 0,
				rounds = self.sel_round or 0,
				start = 0, stop = 10
			}
			self:getNetData("full_service_point_race_battle_group_info", params, function(data)
				self:initData(data)
				if self.m_view then
					self.m_view:refreshUI()
				end
			end)
		end
	end
	return result
end

function M:getShowHeroData(hero_id,hero_data)
	--if hero_data then
	--	local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
	--	data.quality = hero_data.evo
	--	data.card_id = hero_id
	--	data.hero_data = hero_data
	--	return data
	--end
	local realData ={}
	if hero_id then
		for k,v in pairs(hero_id) do
			if v~="" then
				local hero_data = hero_data[v]
				if hero_data then
					local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
					data.quality = hero_data.evo
					data.card_id = hero_id
					data.hero_data = hero_data
					table.insert(realData,data)
				end
			end
		end
	end
	return realData
end

function M:checkGroupIsDone()
	if self.m_params.data_racePhase == 3 and self.m_params.phase_day ~= 1 then	--积分赛准备期除了第一天 都是已完成状态
		return true
	end
	if self.m_params.data_racePhase == 5 and self.m_params.phase_day ~= 1 then 
		return true	
	end
	local curTm = self:getCurTm()
	if curTm.hour < 3 and self.racePhase == 2 then 	--协定 : 在当日凌晨3点前 为分组时间,不能查看 
		GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("compare_sword_race_text_009"), delay_close = 2})
		return false
	end
	if self.m_data_racePhase == 5 and self.m_phase_day == 1 and  curTm.hour < 1 then --晋级赛准备阶段第一天凌晨1点前为匹配时间
		GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("compare_sword_race_text_009"), delay_close = 2})
		return false
	end
	return true
end

function M:destroy()

	M.super.destroy(self)
end

return M