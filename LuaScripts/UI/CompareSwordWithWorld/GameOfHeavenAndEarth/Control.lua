local M = class("GameOfHeavenAndEarthControl",LikeOO.OOControlBase)

function M:onEnter()

	self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
	local cur_timeStamp = UserDataManager:getServerTime()
	if msg == 99999 then
		self:closeView()

	elseif cur_timeStamp >= self.m_model.phase_end_ts then
		GameUtil:lookInfoTips(static_rootControl, { msg = "new_str_1087", delay_close = 2 })
		self:closeView()
	elseif msg ==  "onclick_btn_rise" then
		local raceType = data.raceType
		self:openView("CompareSwordWithWorld.PromotionEventPop" , {raceType = raceType , version = self.m_model.m_version , active_day = self.m_model.active_day})
		
	--右侧按钮	
	elseif msg == "btn_myRace" then		--我的赛程
		self:openView("CompareSwordWithWorld.CompareSwordMyRace",{phase_day = self.m_model.phase_day,racePhase = self.m_model.raceType , data_racePhase = self.m_model.race_phase })
	elseif msg == "btn_guess" then		--竞猜
		self:openView("CompareSwordWithWorld.CompareSwordGuessPop",{guess_times = self.m_model.guessTimes or 0 ,total_guess_times =self.m_model.total_guess_times or 0,
																	point_race_guess_data = self.m_model.point_race_guess_data,open_type = 0 , raceType = self.m_model.raceType})
	elseif msg == "btn_rank" then		--排名
		self:openView("CompareSwordWithWorld.CompareSwordResultRankList",{raceType = self.m_model.raceType,round_stage = self.m_model.phase_day})
	elseif msg == "btn_award" then		--奖励
		self:openView("CompareSwordWithWorld.GameOfHeavenAndEarthReward",{version = self.m_model.m_version,raceType = self.m_model.raceType})
	elseif msg == "guide_btn" then		--导航按钮
		
	elseif msg == "onclick_btn_enter" then --进入天赛/地赛
		--local curTm = self.m_model:getCurTm()
		--if curTm.hour < 3 then 	--协定 : 在当日凌晨3点前 为分组时间,不能查看  todo:排除掉准备阶段除第一天之外的天数
		--	GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("compare_sword_race_text_009"), delay_close = 2})
		--	return
		--end
		local raceType = data.raceType
		local racePhase = data.racePhase or self.m_model:getCurRaceType()
		local raceRound = data.raceRound or self.m_model.race_point_round
		local active_day = data.active_day or self.m_model.active_day
		self:openView("CompareSwordWithWorld.CompareSwordRace",{raceType = raceType ,
																racePhase  = racePhase , 
																raceRound = raceRound , 
																join_self = self.m_model.m_join_self,
																active_day = self.m_model.active_day,
																version = self.m_model.m_version,
																data_racePhase = self.m_model.race_phase ,
																phase_day = self.m_model.phase_day,
																guess_times = self.m_model.guessTimes,
																total_guess_times = self.m_model.total_guess_times,
																
		})
	elseif msg == "update_times" then
		self.m_model.guessTimes = data.guess_times --竞猜次数
		self.m_model.total_guess_times = data.total_guess_times or 0 --总竞猜次数
	elseif msg == "shop_btn" then
		self:openView("Shop", {shop_type = 35})
	elseif msg == "help_btn" then
		local titleName = self.m_model.m_phase_info_cfg[(self.m_model.raceType or 2)].name
		self:openView("Pops.CommonHelpPop", { title = titleName, content =self.m_model.raceType == 2 and "tid#Full_service_tips2" or "tid#Full_service_tips3" })
	elseif msg == "refresh_NetData" then
		self.m_model:getNetData("full_service_index", nil, function(response)
			self.m_model:initData(response)
		end)
	end
end

function M:checkShowGuessPop()
	if self.m_model.guessTimes == 0 then
		self:openView("CompareSwordWithWorld.CompareSwordGuessPop",{guess_times = self.m_model.guessTimes or 0 ,total_guess_times =self.m_model.total_guess_times or 0,
																	point_race_guess_data = self.m_model.point_race_guess_data,open_type = 0, raceType = self.m_model.raceType})
	end
end

function M:updateTime()
	self.m_view:refreshTimeText()
end

function M:destroy()
	self:removeTimer(self.m_timer_id)
	M.super.destroy(self)
end


return M