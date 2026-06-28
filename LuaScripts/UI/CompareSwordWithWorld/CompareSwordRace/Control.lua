local M = class("CompareSwordRaceControl",LikeOO.OOControlBase)

function M:onEnter()
	self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))

end

local __TAB_FORMATION_DATA = {{teamKey = "full_service_point_race", mode = GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_POINT_RACE},
							{teamKey = "full_service_promotion", mode = GlobalConfig.BATTLE_MODE.TEAM_SORT_FULL_SERVICE_PROMOTION} , 
}

function M:onHandle(msg , data)
	if msg == 99999 then
		self:closeView()
	elseif msg == "rank_btn" then
		if self.m_model.racePhase == 2 then
			self:openView("CompareSwordWithWorld.CompareSwordFightReportPop",{open_type = 1 , typ = self.m_model.raceType})
		elseif self.m_model.racePhase == 3 then
			self:openView("CompareSwordWithWorld.CompareSwordFightReportPop",{open_type = 3 , typ = self.m_model.raceType,round_stage = self.m_model.m_phase_day})
		end
	elseif msg == "formation_btn" then
		self:openView("CompareSwordWithWorld.CompareSwordResultRankList",{raceType = self.m_model.racePhase})
	elseif msg == "editor_btn" then
		local race_typ = self.m_model.racePhase - 1
		self:openView("CompareSwordWithWorld.CompareSwordDefendTeam" , {teamKey = __TAB_FORMATION_DATA[race_typ].teamKey,
																		mode =  __TAB_FORMATION_DATA[race_typ].mode,
																		back_refresh = true,
																		race_typ = race_typ,
		})
	elseif msg == "load_rank" then
		self:requestLoadRank()
	elseif msg == "refreshUI" then
		self.m_view:refreshUI()
	elseif msg == "btn_support" then --点赞
		--local function receivetCallback(response)
		--	--self:openView("CompareSwordWithWorld.CompareSwordGuessPop",{guess_times = self.m_model.guessTimes or 0 ,total_guess_times =self.m_model.total_guess_times or 0,
		--	--															point_race_guess_data = self.m_model.point_race_guess_data,open_type = 1})
		--	self:openView("CompareSwordWithWorld.CompareSwordGuessPop",{guess_times = self.m_model.guessTimes or 0 ,total_guess_times =self.m_model.total_guess_times or 0,
		--																point_race_guess_data = self.m_model.point_race_guess_data,open_type = 1})
		--end
		--local params = {
		--	typ = self.m_model.raceType,
		--	group_id = self.m_model.group,
		--	rounds = self.m_model.round,
		--	uuid =data.uuid ,
		--	uid =data.cell_data.uid ,
		--}
		--self.m_model:getNetData("full_service_point_race_guess", params, receivetCallback)
		self:openView("CompareSwordWithWorld.CompareSwordGuessPop",{guess_times = self.m_model.m_guessTimes or 0 ,total_guess_times =self.m_model.m_total_guess_times or 0,
																	point_race_guess_data = self.m_model.point_race_guess_data,open_type = 1,
		                                                            left_data = data.cell_data[1],right_data = data.cell_data[2],typ = self.m_model.raceType,group_id = self.m_model.group,	rounds = self.m_model.sel_round,
																	uuid =data.uuid , raceType = self.m_model.racePhase , round_stage = self.m_model.sel_round_stage})
	elseif msg == "btn_formation" then --侠客
		self:openView("CompareSwordWithWorld.CompareSwordMyRacePlayerInfo",{uid = data.uid })
	elseif msg == "btn_report" then -- 战报
		if self.m_model.racePhase == 2 then
			self:openView("CompareSwordWithWorld.CompareSwordFightReportPop",{open_type = 2,uid = data.uid})
		elseif self.m_model.racePhase == 3 then
			self:openView("CompareSwordWithWorld.CompareSwordFightReportPop",{open_type = 4,uid = data.uid,typ = self.m_model.raceType,round_stage = self.m_model.m_phase_day})
		end
		
	elseif msg == "help_btn" then
		local txt_raceType = Language:getTextByKey(self.m_model.raceType == 1 and "compare_sword_race_text_001" or "compare_sword_race_text_002") --剑试天赛 or 剑试地赛
		local txt_racePhase = Language:getTextByKey(self.m_model.racePhase == 2 and "game_of_heaven_and_earth_reward_text_002" or "game_of_heaven_and_earth_reward_text_003")--积分赛 or 晋级赛
		self:openView("Pops.CommonHelpPop", { title = txt_raceType..txt_racePhase, content =self.m_model.racePhase == 2 and "tid#Full_service_tips2" or "tid#Full_service_tips3"})
	elseif msg == "btn_round_last" then
		local roundIdx = self.m_model.sel_round - 1
		self.m_model:switchRound(roundIdx , function ()
			self.m_view:refreshUI()
		end)
	elseif msg == "btn_round_next" then
		local roundIdx = self.m_model.sel_round + 1
		self.m_model:switchRound(roundIdx , function ()
			self.m_view:refreshUI()
		end)

	elseif msg == "switch_rise_race" then
		if self.m_model.m_data_racePhase == 5 then return end
		local round_stage = data.idx
		local cur_timeStamp = UserDataManager:getServerTime()
		local curTm = TimeUtil.gmTime(cur_timeStamp)
		if round_stage <= self.m_model.m_phase_day + ( curTm.hour >= 11 and 1 or 0) then
			self:switchRiseRaceRoundStage(self.m_model.raceType , round_stage)
		else
			GameUtil:lookInfoTips(static_rootControl, { msg = "compare_sword_race_text_059", delay_close = 2 }) --对决未结束无法查看后续赛程
			
		end

	elseif msg == "eventDayRefreshEvent" then
		GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("compare_sword_race_text_009"), delay_close = 2})
		self:closeView()
	elseif msg == "refresh_red" then
		self.m_view:refreshRed()
	end
end

--下拉刷新的加载逻辑
function M:requestLoadRank()
	local start_pos, end_pos = self.m_model:getLoadIndex()
	if start_pos  == end_pos then return end 
	if start_pos > 0 then
		local function netCallback(response)
			if self.m_view then
				self.m_load_end = true
				if self.m_model.racePhase == 2 then
					self.m_model:insertRankData(response.battle_group)
				elseif self.m_model.racePhase == 3 then
					self.m_model:insertRankData(response.battles)
				end
				self.m_view:updateRaceListLoopScroll()
			end
		end
		if self.m_model.racePhase == 2 then
			local params = {
				typ = self.m_model.raceType,
				group_id = self.m_model.group,
				rounds = self.m_model.sel_round,
				start = start_pos,
				stop = end_pos,
			}
			self.m_model:getNetData("full_service_point_race_battle_group_info", params, netCallback )
		elseif self.m_model.racePhase == 3 then
			local params = {
				typ = self.m_model.raceType,
				round_stage = self.m_model.sel_round_stage,
				start = start_pos,
				stop = end_pos,
			}
			self.m_model:getNetData("full_service_top_enter", params, netCallback )
		end
	end
end

function M:switchGroup(typ, groupId, round ) --参数 积分赛：组id  晋级赛：16强 8强...
	local callBack = function(data)
		self.m_model:initData(data)
		self.m_view:refreshUI()
	end
	if self.m_model.racePhase == 2 then
		self.m_model:getNetData("full_service_point_race_battle_group_info" ,
				{typ = typ , group_id = groupId ,rounds = round ,  start = 0 , stop = 10 }, callBack)
	elseif self.m_model.racePhase == 3 then --todo:  晋级赛
		--self:getNetData( ,callBack)
	end
end

function M:switchRound(roundIdx)
	self.m_model.sel_round = roundIdx
	local params = {

	}

end

function M:switchRiseRaceRoundStage(typ , round)
	local callBack = function(response)
		self.m_model:initData(response)
		self.m_view:refreshUI()
	end
	self.m_model.sel_round_stage = round
	self.m_model:getNetData("full_service_top_enter" , 
			{typ = typ or self.m_model.raceType   , round_stage = round or self.m_model.sel_round_stage , start = 0, stop = 10},
			callBack)
end

function M:getTeamShowData(team , hero)
	local result = {}
	if team == nil then return result end
	for i = 1, 5 do
		local hero_id = team[i] or ""
		local hero_data = hero[hero_id]
		local data 
		if hero_data then
			data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
			data.quality = hero_data.evo
			data.card_id = hero_id
			data.hero_data = hero_data
			--total_combat = total_combat + (hero_data.combat or 0)
		end
		result[i] = data or {}
	end
	return result

end

function M:updateTime()
	self.m_view:refreshTimeText()
end

function M:destroy()
	self:removeTimer(self.m_timer_id)
	M.super.destroy(self)
end


return M