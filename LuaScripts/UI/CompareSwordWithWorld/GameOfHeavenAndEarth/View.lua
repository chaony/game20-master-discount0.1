local M = class("GameOfHeavenAndEarthView", LikeOO.OOPopBase)
--剑试天下积分、晋级赛主界面
M.m_uiName = "CompareSwordWithWorld/GameOfHeavenAndEarth/GameOfHeavenAndEarth"
M.m_iphoneXAdapter = true
M.m_size_type = 1

function M:onEnter()
	self.curRaceType = self.m_model:getCurRaceType() --2 积分赛 ; 3晋级赛
	self.CompareSwordUtil = require("UI.CompareSwordWithWorld.compareSwordWithWorldUtil").new(self.m_model.m_version)
	--self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 46})
	self:refreshTimeText()
	self:refreshUI()
	
end

function M:refreshUI()
	self:refreshSliderValue(self.curRaceType)
	self:refreshTimeAxisNotice(self.curRaceType)
	self:refreshHeavenAndEarthItem(self.curRaceType)
	self:refreshUIText()
	
	local img_bg = self:findImage("Img_Bg")
	GameUtil:updateResourcesImg(img_bg , "Texture/compareswordwithworld/" .. (self.curRaceType == 2 and "a_hd_jstx_zjm_bg" or "a_jstx_zjm_bg2" ))

	self:setObjectVisible("btn_myRace" ,self.m_model.m_join_self ~= nil and self.m_model.m_join_self ~= 0)
	if self.m_model.raceType == 3 then
		self:setObjectVisible("btn_myRace" ,self.m_model.in_top==1)
	end
	self.m_control:checkShowGuessPop()
	self:checkAndPlayVideo()
end

function M:refreshSliderValue()
	local slider1 = self:findSlider("slider_timeAxis_1")
	local slider2 = self:findSlider("slider_timeAxis_2")
	slider1.maxValue = self.m_model.m_phase_time_cfg[2].duration
	slider2.maxValue = self.m_model.m_phase_time_cfg[3].duration

	slider2.gameObject:SetActive(self.curRaceType >= 3)
	local sliderResult = self.m_model.active_day - self.m_model.m_phase_time_cfg[self.curRaceType - 1].end_day	
	if self.curRaceType == 2 then
		--积分赛阶段
		slider1.value = sliderResult
	elseif self.curRaceType == 3 then 
		--晋级赛阶段
		self:findGameObject("Img_point3"):SetActive(true)
		slider1.value = slider1.maxValue
		slider2.gameObject:SetActive(true)
		slider2.value =  sliderResult
	end

end

function M:refreshTimeText() --刷新显示时间倒计时部分
	local text_raceTime = self:findText("text_raceTime")
	local text_itemTimeEarth = self:findText("text_itemTimeEarth")
	local text_itemTimeHeaven = self:findText("text_itemTimeHeaven")

	local cur_timeStamp = UserDataManager:getServerTime()
	local active_end_ts , phase_nextRound_ts = 0
	if self.m_model.raceType == 2 then
		active_end_ts , phase_nextRound_ts = self.m_model:getPointRaceTimeStamp()
	elseif self.m_model.raceType == 3 then
		active_end_ts , phase_nextRound_ts = self.CompareSwordUtil:getRiseRaceTimeStamp(self.m_model.m_version , self.m_model.active_day , function	()
			self:updateMsg("refresh_NetData")
		end)
	end

	local active_end_timeStamp = active_end_ts - cur_timeStamp
	local phase_nextRound_timeStamp = phase_nextRound_ts - cur_timeStamp
	local time_left_txt = GameUtil:formatTimeBySecond(phase_nextRound_timeStamp,999)
	if phase_nextRound_ts == -1 then
		local txt_leftTimeStr = Language:getTextByKey("compare_sword_race_text_028")	--已结束
		text_itemTimeHeaven.text = txt_leftTimeStr
		text_itemTimeEarth.text = txt_leftTimeStr
	else
		local txt_leftTimeStr = Language:getTextByKey("compare_sword_race_text_008")	--	对决倒计时
		text_itemTimeHeaven.text = txt_leftTimeStr .. time_left_txt
		text_itemTimeEarth.text = txt_leftTimeStr .. time_left_txt
	end

	local lang_racePhase = ""
	if self.m_model.racePhase == 2 then	--积分赛
		lang_racePhase = "game_of_heaven_and_earth_reward_text_002"
	elseif self.m_model.racePhase == 3 then	--晋级赛
		lang_racePhase = "game_of_heaven_and_earth_reward_text_003"
	end
	local txt_racePhase = Language:getTextByKey(lang_racePhase)
	txt_racePhase = txt_racePhase .. Language:getTextByKey("compare_sword_race_text_010")
	local time_end_txt = GameUtil:formatTimeBySecond(active_end_timeStamp , 999)
	text_raceTime.text = txt_racePhase .. time_end_txt

end

function M:refreshHeavenAndEarthItem(racePhase) 
	for i = 1, 2 do
		local ItemGo =  self:findGameObject("Item_"..i)
		local luaBehaviour =  UIUtil.findLuaBehaviour(ItemGo.transform)
		local btn_riseGo = luaBehaviour:FindGameObject("btn_rise")
		local btn_enterGo = luaBehaviour:FindGameObject("btn_enter")
		local text_itemTitle = luaBehaviour:FindText("text_itemTitle")
		local img_itemBg = luaBehaviour:FindImage("Img_itemBg")
	
		
		btn_riseGo:SetActive(racePhase == 3)
		if i == 1 then	--天赛
			text_itemTitle.text = Language:getTextByKey("compare_sword_race_text_001")	--剑试天赛
			GameUtil:updateResourcesImg(img_itemBg , "Texture/compareswordwithworld/" .. (racePhase == 2 and "a_hd_jstx_rukoujuanzhou_zi1" or "a_hd_jstx_rukoujuanzhou_zi2" ))

			UIUtil.setButtonClick(btn_riseGo.transform,function ()
				self:updateMsg("onclick_btn_rise",{raceType = i})
			end )
			UIUtil.setButtonClick(btn_enterGo.transform, function()
				self:updateMsg("onclick_btn_enter", { raceType = i, racePhase = racePhase , raceRound = self.m_model.raceRound})
			end )
		elseif i == 2 then	--地赛
			text_itemTitle.text = Language:getTextByKey("compare_sword_race_text_002")	--剑试地赛
			GameUtil:updateResourcesImg(img_itemBg , "Texture/compareswordwithworld/" .. (racePhase == 2 and "a_hd_jstx_rukoujuanzhou_lan1" or "a_hd_jstx_rukoujuanzhou_lan2")  )

			UIUtil.setButtonClick(btn_riseGo.transform,function ()
				self:updateMsg("onclick_btn_rise",{raceType = i})
			end )
			UIUtil.setButtonClick(btn_enterGo.transform, function()
				self:updateMsg("onclick_btn_enter", { raceType = i, racePhase = racePhase , raceRound = self.m_model.raceRound})
			end )
		end

		local txt_btnEnter = luaBehaviour:FindText("text_btnEnter")
		local txt_btnRise = luaBehaviour:FindText("text_btnRise")
		txt_btnEnter.text = Language:getTextByKey("compare_sword_race_text_003")	--进入
		txt_btnRise.text = Language:getTextByKey("game_of_heaven_and_earth_reward_text_003")	--晋级赛
		
	end
end

function M:refreshUIText() 
	self:setTextByLanKey("close_title_text",self.m_model.m_phase_info_cfg[self.curRaceType].name)
	
	self:setTextByLanKey("text_myRace","compare_sword_race_text_004")	--我的赛程
	self:setTextByLanKey("text_guess","compare_sword_race_text_005")	--竞猜
	self:setTextByLanKey("text_rank","compare_sword_race_text_006")	--排名
	self:setTextByLanKey("text_award","compare_sword_race_text_007")	--奖励
	self:setTextByLanKey("shop_text","compare_sword_race_text_049")	--剑试商店
	
	
end

function M:refreshTimeAxisNotice()
	local curRaceType = self.m_model:getCurRaceType()
	for i = 1, 4 do
		local axisNotice = self:findGameObject("axisNotice_"..i)
		local noticeLua = UIUtil.findLuaBehaviour(axisNotice.transform)
		if noticeLua then
			LuaBehaviourUtil.setImg(noticeLua,"Img_noticeBg",curRaceType == i and "a_hd_jstx_jdttxt_di_h" or "a_hd_jstx_jdttxt_di_n" ,"active_ui")
			LuaBehaviourUtil.setTextByLanKey(noticeLua ,"text_axisTime" ,self.m_model.m_phase_info_cfg[i].time )
			LuaBehaviourUtil.setTextByLanKey(noticeLua ,"text_axisNotice" ,self.m_model.m_phase_info_cfg[i].name )
		end
	end
	
end

--检测播放视频
function M:checkAndPlayVideo()
	local isCompareSwordVideoPlay = UserDataManager.local_data:getLocalDataByKey("compareSwordVideoPlay_boss")
	if isCompareSwordVideoPlay == 1 then
		return
	end
	self:playerVideo()
end

function M:playerVideo()
	self:lockTouch()
	audio:PauseMusicBusVol()
	--self.sound_id = audio:SendEvtUI("S2_MovieIntro")
	local model = self.m_model
	self.m_control:openView("Pops.VedioPlayerPop", {
		callback = function()
			if self.sound_id then
				--audio:StopPlayingID(self.sound_id)
			end
			audio:ResumeMusicBusVol()
			UserDataManager.local_data:setLocalDataByKey("compareSwordVideoPlay_boss" , 1)
			self:unlockTouch()
		end, vedio_name = "jstx_race_vedio.mp4" , no_close_btn = false, close_btn_type = 1
	})

end

function M:destroy()

	M.super.destroy(self)
end

return M