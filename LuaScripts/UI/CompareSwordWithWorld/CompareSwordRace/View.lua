local M = class("CompareSwordRaceView", LikeOO.OOPopBase)

M.m_uiName = "CompareSwordWithWorld/GameOfHeavenAndEarth/CompareSwordRace" --
M.m_iphoneXAdapter = true
M.m_size_type = 1

local __TAB_DROPDOWN_BTN = { "a_tsjfs_btn_jiantou01","a_tsjfs_btn_jiantou02", }
local __TAB_DROPDOWN_ITEM_BTN = {"a_tsjfs_btn_xuanzhong", "a_tsjfs_btn_weixuanzhong"}
local __TAB_IMAGE_BG = {"a_tsjfs_bg","a_tsjjs_bg"}

local __TAB_DROPDOWN_BTN_COLOR = { Color(119 / 255, 85 / 255, 35 / 255), Color(1, 1, 1) }


function M:onEnter()
	self.m_params = self.m_model.m_params
	self.CompareSwordUtil = require("UI.CompareSwordWithWorld.compareSwordWithWorldUtil").new(self.m_model.m_version)
	self.material_gray = self:findImage("Img_gray").material
	self.dropDownCurIndex = 1
	self.dropDownDataList = self:getDropDownDataList()
	
	self.dD_open = false
	
	self:refreshUI()
	self:bindingBtnClick()
	self:refreshTimeText()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
end

function M:refreshUI()
	self:switchUIState(self.m_model.racePhase)
	self:refreshUIText()
	self:updateDropDownLoopScroll()
	self:refreshDropDown()
	self:updateRaceListLoopScroll()
	self:refreshRoundNode()
	self:refreshRed()
	self:setObjectVisible("editor_btn" , self.m_model.m_join_self ~= 0)
end

function M:refreshRed()
	if self.m_model.racePhase == 3 then
		local flag = GameUtil:getCompareSwordDefendTeamsRedFlag()  or false
		self:setObjectVisible("editor_red_point" ,flag)
	end
end

function M:refreshRoundNode()
	local roundIdx = self.m_model.sel_round 

	local btn_last = self:findButton("btn_round_last")
	local btn_next = self:findButton("btn_round_next")
	
	btn_last.interactable = roundIdx > 0
	btn_next.interactable = roundIdx < 9
	
	local round_lang = Language:getTextByKey("compare_sword_race_text_014" , GameUtil:numberToChineseString(roundIdx + 1))
	self:setTextByLanKey("text_cur_round",round_lang)
end

function M:bindingBtnClick()
	local dDbtn = self:findGameObject("btn_dropDown")	--下拉菜单按钮
	UIUtil.setButtonClick(dDbtn.transform ,function() 
		self.dD_open = not self.dD_open
		self:refreshDropDown()
	end )

	for i = 1, 6 do
		local axis_btn_go = self:findGameObject("img_axisNode" .. i)
		UIUtil.setButtonClick(axis_btn_go.transform , function() 
			self:updateMsg("switch_rise_race" , {idx = i})
		end)
	end
end

function M:refreshDropDown()
	local dDGO = self:findGameObject("dropDown_loopscroll")
	dDGO:SetActive(self.dD_open)
	
	local dDBtnImg = self:findImage("btn_dropDown")
	
	if self.dD_open then --列表展开状态
		self:setImg(__TAB_DROPDOWN_BTN[1],"active_ui" , "btn_dropDown")
	else
		self:setImg(__TAB_DROPDOWN_BTN[2],"active_ui" , "btn_dropDown")
	end

	local textGroup = self:findText("text_curGroup")
	textGroup.text = Language:getTextByKey(self.dropDownDataList[self.dropDownCurIndex].name)
end

function M:updateDropDownLoopScroll()
	local data = self.dropDownDataList
	if self.m_dropDown_scroll_view == nil then
		local loopscroll = self:findGameObject("dropDown_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:UpdateDDItem(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self.dD_open = false
				self.dropDownCurIndex = index
				self.m_model.group = index - 1 
				for i, v in pairs(self.dropDownDataList) do
					v.open = i == self.dropDownCurIndex
				end
				--self.dropDownDataList[index].open = true
				self:updateDropDownLoopScroll()
				self:refreshDropDown()
				--self:updateMsg("switchGroup",{groupId = index})	--todo: 刷新战斗列表的滚动视图
				self.m_control:switchGroup(self.m_model.raceType , index - 1 , self.m_model.sel_round)
			end
		}
		self.m_dropDown_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_dropDown_scroll_view:reloadData(data)
	end
end

function M:UpdateDDItem(obj , data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if luaBehaviour then
		local itemName = luaBehaviour:FindText("text_itemName")

		itemName.text = Language:getTextByKey(data.name)
		LuaBehaviourUtil.setImg(luaBehaviour,"img_dDBtnBg" ,data.open and __TAB_DROPDOWN_ITEM_BTN[1] or __TAB_DROPDOWN_ITEM_BTN[2] , "active_ui")
		itemName.color = data.open and __TAB_DROPDOWN_BTN_COLOR[1] or __TAB_DROPDOWN_BTN_COLOR[2]
		--self:setTextColor("text_itemName" , )
		
	end
end


---刷新战斗列表的滚动视图
function M:updateRaceListLoopScroll()
	local data = self.m_model:getRankData()
	if self.m_race_scroll_view == nil then
		local loopscroll = self:findGameObject("raceList_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateRaceItem(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsgByType(click_name,cell_data)
			end,
			pull_refresh = function() -- 下拉刷新
				self.last_offsety = self.m_race_scroll_view.m_scroll_rect.viewport.rect.height - self.m_race_scroll_view.m_scroll_rect.content.rect.height
				self:updateMsg("load_rank")
			end,
		}
		self.m_race_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_race_scroll_view:reloadData(data, true)
		if self.m_control.m_load_end == true then
			self:pullRefreshListOffset()
		end
	end
end

function M:updateMsgByType(click_name,cell_data)
	if click_name == "btn_support_right" then
		
		if cell_data.winner ~= 0 or not self:checkCanGuess() then
			GameUtil:lookInfoTips(static_rootControl , {msg ="compare_sword_race_text_047" , delay_close = 2})
		else
			self:updateMsg("btn_support",{cell_data = cell_data.players,uuid = cell_data.uuid})
		end
	elseif click_name == "btn_support_left" then
		if cell_data.winner ~= 0 or not self:checkCanGuess() then
			GameUtil:lookInfoTips(static_rootControl , {msg ="compare_sword_race_text_047" , delay_close = 2})
		else
			self:updateMsg("btn_support",{cell_data = cell_data.players,uuid = cell_data.uuid})
		end
	elseif click_name == "btn_formation_right" then
		self:updateMsg("btn_formation",cell_data.players[1])
	elseif click_name == "btn_formation_left" then
		self:updateMsg("btn_formation",cell_data.players[2])
	elseif click_name == "btn_report_right" then
		self:updateMsg("btn_report",cell_data.players[1])
	elseif click_name == "btn_report_left" then
		self:updateMsg("btn_report",cell_data.players[2])
	end
	
end

function M:pullRefreshListOffset()
	self.now_offsety = self.m_race_scroll_view.m_scroll_rect.viewport.rect.height - self.m_race_scroll_view.m_scroll_rect.content.rect.height
	local position = (self.last_offsety - self.now_offsety) / self.m_race_scroll_view.m_scroll_rect.content.rect.height
	self.m_race_scroll_view:setVerticalNormalizedPosition(position)
	self.m_control.m_load_end = false
end

function M:updateRaceItem(index, obj, data)
	local lua_cellNode = UIUtil.findLuaBehaviour(obj)
	if lua_cellNode then
		local right_obj = lua_cellNode:FindGameObject("right_node")
		local left_obj = lua_cellNode:FindGameObject("left_node")
		local img_winner_right = lua_cellNode:FindGameObject("Img_winner_right")
		local img_winner_left = lua_cellNode:FindGameObject("Img_winner_left")
		local img_support_left = lua_cellNode:FindImage("btn_support_left")
		local img_support_right = lua_cellNode:FindImage("btn_support_right")
		img_support_left.material = nil
		img_support_right.material = nil
		img_winner_left:SetActive(false)
		img_winner_right:SetActive(false)

		local player_Data = data.players
		local battle_uuid = data.uuid
		if data and data.players then
			if not self:checkCanGuess()	 then
				img_support_left.material = self.material_gray
				img_support_right.material = self.material_gray
			end
			if data.winner ~= 0  then	--当前比赛已经结束
				img_support_left.material = self.material_gray
				img_support_right.material = self.material_gray
				local winner = tostring(data.winner)
				local player1 = tostring(player_Data[1].uid)
				local player2 = tostring(player_Data[2].uid)
				if winner == player1 then
					img_winner_right:SetActive(true)
				elseif winner == player2 then
					img_winner_left:SetActive(true)
				else
					Logger.log("有bug，两个玩家都没有胜利")
				end
			end
			
			self:updatePlayerItem(index, right_obj.transform, player_Data[1] , battle_uuid)
			self:updatePlayerItem(index, left_obj.transform, player_Data[2] , battle_uuid)
		end
		
	end
end

function M:updatePlayerItem(index, trans, data , battle_uuid , showSupport)
	local luaBehaviour = UIUtil.findLuaBehaviour(trans)
	local text_imgPoint = luaBehaviour:FindText("text_imgPoint")
	text_imgPoint.text = Language:getTextByKey("compare_sword_race_text_017")	--积分
	
	local uid = data.uid
	local text_playerName = luaBehaviour:FindText("text_playerName")	--玩家名称
	local text_power = luaBehaviour:FindText("text_power")	--战力
	local text_point = luaBehaviour:FindText("text_point")	--积分
	local text_popular = luaBehaviour:FindText("text_popular")	--人气
	--local btn_popular  = luaBehaviour:FindButton("btn_popular")
	local popular_txt = Language:getTextByKey("compare_sword_race_text_016")
	--btn_popular.interactable = data.winner == 0
	text_playerName.text = data.name
	text_power.text =GameUtil:formatValueToString(data.full_combat) 
	text_point.text = GameUtil:formatValueToString(data.score)
	text_popular.text = popular_txt .. data.hot
	
	local user_data = data -- UserDataManager.user_data.user_status
	local head_node = luaBehaviour:FindGameObject("head_node") --获取头像
	GameUtil:setUserAvatar(head_node, user_data, false, false, {show_flag = true, scale = 1})
	
	--侠客阵容
	local team_heros_data = data.heros
	local team_heros_id = data.teams[1]
	if team_heros_id == nil then
		local a = team_heros_data
	end
	local team_data = self.m_model:getShowHeroData(team_heros_id , team_heros_data)
	if team_data then
		for i = 1, 5 do
			local hero_node = UIUtil.findTrans(trans, "team_node/hero_node_" .. i)
			local item_data = team_data[i]
			if item_data and _G.next(item_data) then
				GameUtil:updateItemElementByData(hero_node.gameObject, item_data, false, false)
			else
				local ui_element = GameUtil:updateItemElementNoData(hero_node)
				ui_element.add_img.gameObject:SetActive(false)
			end
		end
	end
	
end



---切换积分赛与晋级赛
function M:switchUIState(racePhase)
	local middleNode = self:findGameObject("middle_node")
	local middleRect = middleNode:GetComponent("RectTransform")
	local dropDown = self:findGameObject("dropDown_node")
	local timeAxis = self:findGameObject("timeAxis_node")
	local round_node = self:findGameObject("switch_round_node")
	
	local imageBg = self:findImage("main_bg_img")

	if racePhase == 2 then --积分赛
		middleRect.sizeDelta = Vector2(middleRect.rect.width , 575)
		dropDown.gameObject:SetActive(true)
		timeAxis:SetActive(false)
		round_node:SetActive(true)
		GameUtil:updateResourcesImg( imageBg, "Texture/compareswordwithworld/" .. __TAB_IMAGE_BG[1])		--更换大背景
	elseif racePhase == 3 then --晋级赛
		middleRect.sizeDelta = Vector2(middleRect.rect.width , 510)
		dropDown.gameObject:SetActive(false)
		timeAxis:SetActive(true)
		round_node:SetActive(false)
		GameUtil:updateResourcesImg( imageBg, "Texture/compareswordwithworld/" .. __TAB_IMAGE_BG[2])
		self:updateAxisNode()
	end
	
end

function M:updateAxisNode()
	local cur_timeStamp = UserDataManager:getServerTime()
	local curTm = TimeUtil.gmTime(cur_timeStamp)
	if self.m_model.m_data_racePhase == 5 then --准备阶段
		
	elseif self.m_model.m_data_racePhase == 6 then	--比赛阶段
		for i = 1, 5 do
			local axis_node = self:findGameObject("img_axis"..i)
			axis_node:SetActive(i <= self.m_model.m_phase_day - 1)
		end

		for i = 1, 6 do
			local axis_btn_node = self:findGameObject("img_axisNode"..i)
			local axis_btn_img = self:findImage("img_axisNode"..i)
			self:setImg(self.m_model.sel_round_stage == i and "a_tsjjs_btn_xuanzhong" or "a_tsjjs_btn_weixuanzhong", "active_ui" , "img_axisNode"..i)
			local luaBehaviour = UIUtil.findLuaBehaviour(axis_btn_node.transform)
			local fight_go =  luaBehaviour:FindGameObject("Img_fight")
			fight_go:SetActive( i == self.m_model.m_phase_day)
			if i <= self.m_model.m_phase_day +( curTm.hour >= 11 and 1 or 0) then
				axis_btn_img.material =nil
			else
				axis_btn_img.material = self.material_gray
			end
		end
	end

	if curTm.hour <= 10 then
		self:setObjectVisible("Img_timeBg", self.m_model.m_phase_day == self.m_model.sel_round_stage)
	elseif curTm.hour >= 11 then
		self:setObjectVisible("Img_timeBg", self.m_model.m_phase_day + 1 == self.m_model.sel_round_stage)
	end
	
end

function M:refreshUIText()
	local txt_raceType = Language:getTextByKey(self.m_model.raceType == 1 and "compare_sword_race_text_001" or "compare_sword_race_text_002") --剑试天赛 or 剑试地赛
	local txt_racePhase = Language:getTextByKey(self.m_model.racePhase == 2 and "game_of_heaven_and_earth_reward_text_002" or "game_of_heaven_and_earth_reward_text_003")--积分赛 or 晋级赛
	self:setTextByLanKey("close_title_text",txt_raceType .. txt_racePhase) --标题文字
	
	self:setTextByLanKey("editor_btn_text","compare_sword_race_text_011")	--布阵
	self:setTextByLanKey("rank_btn_text","compare_sword_race_text_012")	--战报
	self:setTextByLanKey("formation_btn_text","compare_sword_race_text_013") --榜单
	
	if self.m_model.racePhase == 2 then --积分赛
		
	elseif self.m_model.racePhase == 3 then --晋级赛
		
	end
	
end


function M:refreshTimeText()
	local cur_timeStamp = UserDataManager:getServerTime()
	local curTm = TimeUtil.gmTime(cur_timeStamp)
	local race_nextRound_ts = 0
	local race_nextRound_end_ts = 0

	if self.m_model.racePhase == 2 then --积分赛
		_,_,race_nextRound_ts = self.CompareSwordUtil:getPointRaceTimeStamp(self.m_model.m_version , self.m_model.m_active_day)

		local pointRace_nextRound_timeStamp = race_nextRound_ts - cur_timeStamp
		local nextRound_time_text = GameUtil:formatTimeBySecond(pointRace_nextRound_timeStamp, 999)

		local title_lang = "compare_sword_race_text_028"
		if race_nextRound_ts <= -1 then
			self:setObjectVisible("text_timeValue", false)
			self:setTextByLanKey("text_timeTitle" , "compare_sword_race_text_028") --已结束

		else
			if self.m_model.m_data_racePhase == 3 then --准备期
				title_lang = Language:getTextByKey("compare_sword_race_text_038",GameUtil:numberToChineseString(1), GameUtil:numberToChineseString(1))
			elseif curTm.hour < 11 then	--当天未开始
				title_lang = Language:getTextByKey("compare_sword_race_text_038",GameUtil:numberToChineseString(self.m_model.m_params.phase_day), GameUtil:numberToChineseString(1))
			elseif curTm.hour >= 20 then	--当天已结束
				title_lang = "compare_sword_race_text_040"
			else
				local curRound = curTm.hour - 9
				title_lang = Language:getTextByKey("compare_sword_race_text_038",GameUtil:numberToChineseString(self.m_model.m_params.phase_day) , GameUtil:numberToChineseString(curRound))
			end
			self:setObjectVisible("text_timeValue", true)
			self:setTextByLanKey("text_timeValue" , nextRound_time_text)
			self:setTextByLanKey("text_timeTitle" , title_lang)
		end
	elseif self.m_model.racePhase == 3 then	--晋级赛
		_,race_nextRound_ts,race_nextRound_end_ts = self.CompareSwordUtil:getRiseRaceTimeStamp(self.m_model.m_version , self.m_model.m_active_day,function()
			if self.m_control then self.m_control:closeView() end
			GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_1087"), delay_close = 2})
		end, function()
			self:refreshUI()
		end)
		if not self.m_model then return end
		local riseRace_nextRound_timeStamp = race_nextRound_ts - cur_timeStamp
		local nextRound_time_text = GameUtil:formatTimeBySecond(riseRace_nextRound_timeStamp, 999)

		local title_lang = "compare_sword_race_text_028"

		self:setObjectVisible("text_timeValue", true)
		if race_nextRound_ts <= -1 then
			self:setObjectVisible("text_timeValue", false)
			self:setObjectVisible("text_timeTitle", false)
		else
			if self.m_model.m_data_racePhase == 5 then --准备期
				title_lang = Language:getTextByKey("compare_sword_race_text_008")
			elseif curTm.hour < 10 then	--当天未开始
				title_lang = Language:getTextByKey("compare_sword_race_text_008")
				--self:setObjectVisible("Img_timeBg", self.m_model.m_phase_day == self.m_model.sel_round_stage)
			elseif curTm.hour >= 11 then	--当天已结束
				title_lang = "compare_sword_race_text_008"
				--self:setObjectVisible("Img_timeBg", self.m_model.m_phase_day + 1 == self.m_model.sel_round_stage)
			else
				title_lang = Language:getTextByKey("compare_sword_race_text_056")
				self:setObjectVisible("text_timeValue", false)
			end
			
			self:setTextByLanKey("text_timeValue" , nextRound_time_text)
			self:setTextByLanKey("text_timeTitle" , title_lang)
		end
	end
	
	
	if curTm.hour < 3 and self.m_model.racePhase == 2 then	--跨天后弹出逻辑
		if self.m_model.m_data_racePhase == 3 or self.m_model.m_data_racePhase == 5 then
			return
		end
		self:updateMsg("eventDayRefreshEvent")
	end
end

function M:getDropDownDataList()
	local result ={}
	for i = 1, 16 do	-- 16是固定的积分赛小组数量
		local lang_num = GameUtil:numberToChineseString(i)
		local lang_txt = Language:getTextByKey("compare_sword_race_text_015", lang_num) 
		table.insert(result, i , {name = lang_txt , open = false})
	end
	result[self.dropDownCurIndex].open = true	--todo：设置为当前进行的组 开启
	return result
end

function M:everyDayRefreshEvent()
	if self.m_model.m_data_racePhase == 3 or self.m_model.m_data_racePhase == 5 then
		return 
	end
	self:updateMsg("eventDayRefreshEvent")
	
end

function M:checkCanGuess()
	if self.m_model.m_data_racePhase == 3 or self.m_model.m_data_racePhase == 5 then
		return true
	end
	local curTm  = self.m_model:getCurTm()
	if self.m_model.racePhase == 2 then
		local sel_round = self.m_model.sel_round
		local canGuess = sel_round > curTm.hour	- 10
		return canGuess
	elseif self.m_model.racePhase == 3 then
		if curTm.hour < 10 then
			return  self.m_model.m_phase_day == self.m_model.sel_round_stage
		elseif curTm.hour >= 10 then
			return self.m_model.m_phase_day + 1 == self.m_model.sel_round_stage
		end
		
	end
	return false
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
	M.super.destroy(self)
end

return M