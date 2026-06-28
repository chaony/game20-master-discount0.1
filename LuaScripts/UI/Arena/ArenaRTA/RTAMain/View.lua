---@class RTAMainView:OOPopBase
---@field m_model RTAMainModel
---@field m_control RTAMainControl
local M = class("RTAMainView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaRTA/RTAMainPop"
M.m_size_type = 1
--M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = GlobalConfig.RACE_TAB_BTN_NODE
function M:onEnter()
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 57})
	--self.m_attr_node:setTitle(Language:getTextByKey("tid#arena_explain7"))

	self.dan_icon={
		[1]="rta_dan_badge_qingtong",
		[2]="rta_dan_badge_baiyin",
		[3]="rta_dan_badge_gold",
		[4]="rta_dan_badge_zuanshi",
		[5]="rta_dan_badge_dashi",
	}

	self:setTextByLanKey("record_btn_text", "new_str_0233")
	self:setTextByLanKey("rank_btn_text", "new_str_0235")
	self:setTextByLanKey("battleReport_text", "UnionWar_str_006")
	self:setTextByLanKey("server_ban_text", "arena_rta_str_0001")

	self:setTextByLanKey("preban_text", "arena_rta_str_0002")
	self:setTextByLanKey("preban_text2", "arena_rta_str_0002")
	self:setTextByLanKey("preban_text3", "arena_rta_str_0002")

	self:setTextByLanKey("challenge_btn_text", "new_str_0386")
	self:setTextByLanKey("start_btn_text", "arena_rta_str_0020")

	self:setTextByLanKey("score_title_text", "new_str_0566")
	self:setTextByLanKey("victory_title_text", "arena_rta_str_0003")
	self:setTextByLanKey("failure_title_text", "arena_rta_str_0004")
	self:setTextByLanKey("win_rate_title_text", "arena_rta_str_0005")
	self:setTextByLanKey("rank_title_text", "arena_rta_str_0012")

	self:setTextByLanKey("shop_btn_text", "new_str_0861")
	self:setTextByLanKey("close_title_text", "arena_rta_str_0006")

	self:setTextByLanKey("limit_text","arena_rta_str_0010")
	self:setTextByLanKey("timer_times_text2","arena_rta_str_0009")
	self:setTextByLanKey("cancel_btn_text","new_str_0007")

	self:setTextByLanKey("select_btn_text","new_str_0771")
	self:setTextByLanKey("ban_select_btn_text","new_str_0771")
	self:setTextByLanKey("ban_text","arena_rta_str_0013")
	self:setTextByLanKey("turn_text","arena_rta_str_0016")
	self:setTextByLanKey("turn_text2","arena_rta_str_0016")
	self:setTextByLanKey("opponent_turn_text","arena_rta_str_0025")
	self:setTextByLanKey("score_text","arena_str_0001")

	self.m_gray_img = self:findImage("gray_img")
	self.m_timer_times_text = self:findText("timer_times_text")
	self.limit_icon_trans=self:findGameObject("limit_icon").transform
	self:setObjectVisible("limit",self.m_model.m_limit_cfg~=nil)
	if self.m_model.m_limit_cfg~=nil then
		self:setImg(self.m_model.m_limit_cfg.rule_icon,"arena_ui","limit_icon")
	end

	local ownHpLabel=self:findGameObject("ownHpLabel").transform
	self.ownHpCon = ownHpLabel:GetComponent(typeof(CS.HpLabelController));
	local opponentHpLabel=self:findGameObject("opponentHpLabel").transform
	self.opponentHpCon = opponentHpLabel:GetComponent(typeof(CS.HpLabelController))

	opponentHpLabel=self:findGameObject("ownBanHpLabel").transform
	self.banHpCon=opponentHpLabel:GetComponent(typeof(CS.HpLabelController))

	local other_tip_effect_go=self:findGameObject("other_tip_effect")
	self.other_tip_effect_luaBehaviour=UIUtil.findLuaBehaviour(other_tip_effect_go.transform)
	
	local own_tip_effect_go=self:findGameObject("self_tip_effect")
	self.own_tip_effect_luaBehaviour=UIUtil.findLuaBehaviour(own_tip_effect_go.transform)

	self.own_curTurn_hero_name_img=self:findImage("own_curTurn_hero_name")
	self.other_curTurn_hero_name_img=self:findImage("other_curTurn_hero_name")


	self.other_selected_heros_trans=self:findGameObject("other_selected_heros").transform
	self.rightpart_trans=self:findGameObject("rightpart").transform

--是否处于ban的阶段
	self.m_model.is_inBanState=false
	self.blinking_trans={}

	self:initUi()
	self:refreshUI()
end

function M:initUi()
	local tip_effect_go=self:findGameObject("self_tip_effect")
	self.mySelectionAni=tip_effect_go:GetComponent("Animation")

	local tip_effect_go=self:findGameObject("other_tip_effect")
	self.otherSelectionAni=tip_effect_go:GetComponent("Animation")
	self:initServerBanHeros()

	self.m_selected_hero_sp_trans =self:findGameObject("selected_hero_spine").transform

	self.ban_select_btn_img = self:findImage("ban_select_btn")
	self:refreshPreBanHeros()
	self:set_select_btn_visible(false)
end

--function M:resetUI()
--	self:setObjectVisible("content_node",true)
--	self:setObjectVisible("next_content_node",false)
--end

function M:setBanState(state)
	self.m_model.is_inBanState=state
	if not state then
		self.ban_select_btn_img.material = self.m_gray_img.material
		self:setTextByLanKey("ban_text","arena_rta_str_0035")
	else
		self:setTextByLanKey("ban_text","arena_rta_str_0013")
		self.ban_select_btn_img.material = nil
	end
end

function M:set_select_btn_visible(visible)
	self:setObjectVisible("select_btn",visible)
end

function M:initServerBanHeros()
	local global_ban_heros=self.m_model:getServerBanHeros()
	if global_ban_heros==nil or table.nums(global_ban_heros)==0 then
		self:setObjectVisible("serverban",false)
	else
		self:setBanHeroInfo(global_ban_heros[1],"serverban_hero1")
		if global_ban_heros[2] then
			self:setBanHeroInfo(global_ban_heros[2],"serverban_hero2")
		else
			self:setObjectVisible("serverban_hero2",false)
		end
	end
end

function M:setBanHeroInfo(hero_id, forbiddenGoName)
	local hero_cfg=UserDataManager.hero_data:getHeroConfigByCid(hero_id)
	if hero_cfg then
		local forbiddenNode=self:findGameObject(forbiddenGoName).transform
		UIUtil.setImg(forbiddenNode, hero_cfg.icon, "hero_head_ui","tx_mask/tx_img")
	end
end

function M:refreshUI()
	--self:refreshRedPoint()
	local match_over_remaining_time=self.m_model:calculateOverRemainingTime()
	self:setTextByLanKey("time_titile_text","arena_rta_str_0008",match_over_remaining_time)
	self:setTextByLanKey("advance_tip_text","arena_rta_str_0007",self.m_model.m_data.rank_promote)
	self:setText("score_num_text",self.m_model:getSelfScore())


	self:setImg(self.dan_icon[self.m_model.m_cur_tier],"arena_ui","badge_img")
	self:setText("victory_num_text",self.m_model.m_data.win_num)
	self:setText("failure_num_text",self.m_model.m_data.lose_num)

	local rank=self.m_model.m_data.rank
	self:setText("rank_text",rank==0 and Language:getTextByKey("new_str_0076") or rank)

	self:setText("time_titile_text2",self.m_model.m_data.open_time_desc)

	local win_num=self.m_model.m_data.win_num
	local lose_num=self.m_model.m_data.lose_num
	local rate=0
	if win_num+lose_num~=0 then
		rate=win_num*100/(win_num+lose_num)
		rate=string.format("%.1f",rate)
	end

	--local win_rate=self.m_model:calculateWinRate()
	self:setText("win_rate_num_text",rate.."%")
	self:setObjectVisible("next_content_node",false)
	self.m_model.is_inBanState=false

	if not IsNull(self.select_cell_obj) then
		local LuaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",false)
	end
	self.select_cell_obj = nil
end

--自己主界面的preban显示
function M:refreshPreBanHeros()
	self:setObjectVisible("addPreBan_btn",self.m_model.m_data.self_ban_hero~=nil)
	if self.m_model.m_data.self_ban_hero~=0 and self.m_model.m_data.self_ban_hero~=nil then
		self:setBanHeroInfo(self.m_model.m_data.self_ban_hero,"prebanHero")
	end
end

--初始化ban界面双方的preban
function M:initPreBanHeros()
	if table.nums(self.m_model.pre_ban_heros)==0 then
		self:setObjectVisible("preban",false)
	else
		self:setObjectVisible("preban",true)
		for i = 1, 2 do
			self:setBanHeroInfo(self.m_model.pre_ban_heros[i],"preban"..i)
		end
	end
end

function M:endBanAndCountdown()
	self:setObjectVisible("own_ban_turn",false)
	self:setObjectVisible("ban_select_btn",false)

	self:setBanState(false)
end

function M:startMatch()
	self:setObjectVisible("start_btn",false)
	self:setObjectVisible("cancel_btn",true)
	self:setTimeText()
	local time = self.m_model.matchRemainingTime
	local function tick(event, dt, remaining_time)
		self:setTimeText()
	end
	EventDispatcher:registerTimeEvent("RTAMainTime", tick, 1, time)
end

--取消匹配
function M:cancelMatch()
	self:setObjectVisible("start_btn",true)
	self:setObjectVisible("cancel_btn",false)
	EventDispatcher:unRegisterEvent("RTAMainTime")
end



function M:setTimeText()
	local remaining_time=self.m_model:getMatchRemainingTime()
	local ft = GameUtil:formatTimeBySecond(remaining_time,999)
	self.m_timer_times_text.text = ft
end

function M:refreshRedPoint()
    local record_flag1 = RedPointUtil:hasRedPointById(131)
    self:setObjectVisible("record_btn_red_point", record_flag1)
	UserDataManager:removeRedDotByKey("race_arena_beat")
	UserDataManager:removeRedDotByKey("race_arena_times")
end


--进入轮选界面
function M:enterSelectNode()

	self:setObjectVisible("start_btn",true)
	self:setObjectVisible("cancel_btn",false)
	EventDispatcher:unRegisterEvent("RTAMainTime")

	self:setObjectVisible("content_node",false)
	self:addBattleVS()
	self.m_control:setOnceTimer(2,function()
		self:removeBattleVS()
		self:setObjectVisible("next_content_node",true)
		self:init_selectNode_rightPart()
		self:init_selectNode_leftPart_palyerHead()
		--self:enableMaskLayer()
	end)
end

function M:back2MainReset()
	self:resetTurn()
	self:setObjectVisible("next_content_node",false)
	self:setObjectVisible("ownTurn",false)
	self:setObjectVisible("opponentTurn",false)
	self:setObjectVisible("ban_select",false)
	self:setObjectVisible("content_node",true)

	self.cur_skin_name=nil
	self:setObjectVisible("own_curTurn_hero_name",false)
	self:setObjectVisible("other_curTurn_hero_name",false)

	self.m_selected_hero_sp_trans.gameObject:SetActive(false)
	UIUtil.setLocalPosition(self.other_selected_heros_trans,0)
	UIUtil.setLocalPosition(self.rightpart_trans,22)
	self:disableMaskLayer()
	self:SetBanHeroEffect(false)
end

--ban选结束后进入战斗布阵
function M:enterBattle()
	self:addBattleVS()
	self.m_control:setOnceTimer(1,function()
		self:removeBattleVS()

	end)
end

function M:init_selectNode_leftPart_palyerHead()
	local left_user = self.m_model:getUserInfoBySort(1)--{avatar = 1, level = 1, name = "one"}
	local right_user = self.m_model:getUserInfoBySort(2)--{avatar = 1, level = 1, name = "two"}
	local left_head_node = self:findGameObject("left_head_node")
	local real_left_head_node = self:findGameObject("real_left_head_node")
	GameUtil:setUserAvatar(real_left_head_node, left_user, false, nil, {show_flag = true, scale = 1})
	UIUtil.setTextByLanKey(left_head_node.transform, "left_name_text", tostring(left_user.name))

	local scoreStr=Language:getTextByKey("arena_rta_str_0024",left_user.score)
	UIUtil.setText(left_head_node.transform,scoreStr,"left_score_text")

	local right_head_node = self:findGameObject("right_head_node")
	local real_right_head_node = self:findGameObject("real_right_head_node")
	GameUtil:setUserAvatar(real_right_head_node, right_user, false,nil,{show_flag = true, scale = 1})
	UIUtil.setTextByLanKey(right_head_node.transform, "right_name_text", tostring(right_user.name))
	scoreStr=Language:getTextByKey("arena_rta_str_0024",right_user.score)
	UIUtil.setText(right_head_node.transform,scoreStr,"right_score_text")
end

--开始新一轮选人计时
function M:startTurn(end_ts,isOwn,callback)
	self:resetTurn(isOwn)
	self:setObjectVisible("ownTurn",isOwn)
	self:setObjectVisible("opponentTurn",not isOwn)

	self:set_select_btn_visible(isOwn)
	if isOwn then
		--self:setObjectVisible("own_curTurn_hero_name",false)
		if self.cur_skin_name then
			self:setObjectVisible("own_curTurn_hero_name",true)
			local skin_name_img=GameUtil:updateResourcesImg(self.own_curTurn_hero_name_img,self.cur_skin_name)
			skin_name_img:SetNativeSize()
		end

		self:disableMaskLayer()
	else

		--self:setObjectVisible("other_curTurn_hero_name",false)
		if self.cur_skin_name then
			self:setObjectVisible("other_curTurn_hero_name",true)
			local skin_name_img=GameUtil:updateResourcesImg(self.other_curTurn_hero_name_img,self.cur_skin_name)
			skin_name_img:SetNativeSize()
		end
	end

	self:Selecting_blink(isOwn)
	self.preSide=isOwn

	local hpCon = isOwn and self.ownHpCon or self.opponentHpCon
	local serverTime=UserDataManager:getServerTime()
	self.countDown_time = math.floor((end_ts- serverTime))

	--Logger.logWarning("countDown_time=================="..self.countDown_time)
	hpCon:SetText(self.countDown_time,-1);
	local function tick(event, dt, remaining_time)
		self.countDown_time=self.countDown_time-1

		if self.countDown_time<=0 then
			if isOwn then
				self:setObjectVisible("ownTurn",false)
				self:set_select_btn_visible(false)
			else
				self:setObjectVisible("opponentTurn",false)
			end
			if callback then
				callback()
			end
			--self:stopSelectionAni()
			--self:enableMaskLayer()

			--Logger.logWarning("time out==================")
			EventDispatcher:unRegisterEvent("SelectTime")

		else
			--remaining_time=math.floor(remaining_time+0.5)

		end
		hpCon:SetText(self.countDown_time,-1);
	end
	EventDispatcher:registerTimeEvent("SelectTime", tick, 1, self.countDown_time)
end

function M:resetTurn(isOwn)
	--self:stopSelectionAni()
	self:disableMaskLayer()
	self:setObjectVisible("ownTurn",false)
	self:setObjectVisible("opponentTurn",false)

	if isOwn~=nil then
		if isOwn~=self.preSide then
			if table.nums(self.blinking_trans)>0 then
				for i, tran in pairs(self.blinking_trans) do
					UIUtil.setObjectVisible(tran,false,"UI_RTAMainPop_heros")
				end
				self.blinking_trans={}
			end
		end
	else
		if table.nums(self.blinking_trans)>0 then
			for i, tran in pairs(self.blinking_trans) do
				UIUtil.setObjectVisible(tran,false,"UI_RTAMainPop_heros")
			end
			self.blinking_trans={}
		end
	end
end


function M:startBanturn(end_ts, callback)
	EventDispatcher:unRegisterEvent("banSelectTime")
	EventDispatcher:unRegisterEvent("SelectTime")

	local serverTime=UserDataManager:getServerTime()
	self.countDown_time = math.floor((end_ts- serverTime))
	self.banHpCon:SetText(self.countDown_time,-1);
	local function tick(event, dt, remaining_time)
		self.countDown_time=self.countDown_time-1
		--Logger.logWarning("ban--------countDown_time===="..self.countDown_time)
		if self.countDown_time<=0 then
			if callback then
				callback()
			end
			self:enableMaskLayer()
			Logger.logWarning("time out==================")
		end
		self.banHpCon:SetText(self.countDown_time,-1);
	end
	EventDispatcher:registerTimeEvent("banSelectTime", tick, 1,self.countDown_time)
end


function M:update_selectNode_leftPart_Heros()
	local own=self.m_model:getUserInfoBySort(1)
	local ownHeros=own.heros
	local enemy=self.m_model:getUserInfoBySort(2)
	local enemyHeros=enemy.heros

	local new_hero_id=nil
	local heroNum=0
	if ownHeros then
		heroNum=table.nums(ownHeros)
		if self.m_model.m_own_pre_selected_num<heroNum then
			self.m_model.m_own_pre_selected_num=heroNum
			local hero=ownHeros[heroNum]
			new_hero_id=hero.tid
			--Logger.log("update------------")

		end
	end

	if self.m_model:selectedHaveChanged() then
		self.m_model.cur_seclect_hero_oid=nil
		self:updateHerosScroll()
	end
	if enemyHeros then
		heroNum=table.nums(enemyHeros)
		if self.m_model.m_other_pre_selected_num<heroNum then
			self.m_model.m_other_pre_selected_num=heroNum
			local hero=enemyHeros[heroNum]
			new_hero_id=hero.tid
		end
	end
	if new_hero_id then
		self:update_cur_selected(new_hero_id)
	end

	self:update_Heros(0,ownHeros,false)
	self:update_Heros(10,enemyHeros,true)
end

--更新最新选中的spine
function M:update_cur_selected(id)
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
	local spineName=cfg.hero_spine
	if self.m_selected_hero_sp_trans and spineName then
		if not self.m_selected_hero_sp_trans.gameObject.activeSelf then
			self.m_selected_hero_sp_trans.gameObject:SetActive(true)
		end
		if id==716 or id==402 then
			UIUtil.setLocalPosition(self.m_selected_hero_sp_trans,nil,-53)
		else
			UIUtil.setLocalPosition(self.m_selected_hero_sp_trans,nil,0)
		end
		GameUtil:updateSpineLoadSet(self.m_selected_hero_sp_trans, "RoleSpine/" .. spineName, "idle", 0, true)
		self.cur_skin_name="Texture/HeroIcon/a_name_"..id

		if self.preSide then
			self:setObjectVisible("own_curTurn_hero_name",true)
			local skin_name_img=GameUtil:updateResourcesImg(self.own_curTurn_hero_name_img,self.cur_skin_name)
			skin_name_img:SetNativeSize()
		else
			self:setObjectVisible("other_curTurn_hero_name",true)
			local skin_name_img=GameUtil:updateResourcesImg(self.other_curTurn_hero_name_img,self.cur_skin_name)
			skin_name_img:SetNativeSize()
		end
	end
end


function M:update_Heros(offset, heros,isRival)
	--if heros==nil then
	--	return
	--end
	--local hero_num=table.nums(heros)
	local obj=nil
	for i = 1, 6 do
		local notEmpty=false
		local hero_data=nil
		if heros~=nil then
			hero_data= heros[i]
			notEmpty=hero_data~=nil and table.nums(hero_data)>0
		end

		obj=self:findGameObject("hero_"..i+offset).transform
		UIUtil.setObjectVisible(obj,not notEmpty,"no_panel")
		UIUtil.setObjectVisible(obj,notEmpty,"content")
		if notEmpty then
			local lua_behaviour=UIUtil.findLuaBehaviour(obj)
			local _isRival=isRival
			GameUtil:updateItemElement(obj, {RewardUtil.REWARD_TYPE_KEYS.HEROS,hero_data.tid,0,hero_data.oid}, false, false,
					function()
						if self.m_model.is_inBanState and _isRival then
							if self.cur_ban_select_image_go~=nil then
								self.cur_ban_select_image_go:SetActive(false)
							end
							self.cur_ban_select_image_go=lua_behaviour:FindGameObject("select_image")
							self.cur_ban_select_image_go:SetActive(true)
							self:updateMsg("selectBan",{oid=hero_data.oid})
						end
					end,nil,false)

			LuaBehaviourUtil.setObjectVisible(lua_behaviour,"lv_bg_img",false)

			if hero_data.ban==1 then
				Logger.logWarning("ban hero oid ---------------"..hero_data.oid)
				UIUtil.setObjectVisible(obj,true,"content/ban_image")
			else
				UIUtil.setObjectVisible(obj,false,"content/ban_image")
			end

		--else
		--	UIUtil.setObjectVisible(obj,true,"content")
		--	UIUtil.setObjectVisible(obj,true,"no_panel")
		end
	end
end

function M:SetBanHeroEffect(show)
	for i = 1, 6 do
		local obj=self:findGameObject("hero_"..i+10).transform
		UIUtil.setObjectVisible(obj,show,"UI_RTAMainPop_heros")
	end

end


function M:Selecting_blink(isOwn)
	local cur_step=self.m_model.m_cur_step
	local index1,index2=-100,-100
	if cur_step==1 then
		index1=1
	elseif cur_step==2 or cur_step==3 then
		index1=1
		index2=2
	elseif cur_step==4 or cur_step==5 then
		index1=2
		index2=3
	elseif cur_step==6 or cur_step==7 then
		index1=3
		index2=4
	elseif cur_step==8 or cur_step==9 then
		index1=4
		index2=5
	elseif cur_step==10 or cur_step==11 then
		index1=5
		index2=6
	elseif cur_step==12 then
		index1=6
	end

	if not isOwn then
		self:StartBlinking(index1+10)
		self:StartBlinking(index2+10)
	else
		self:StartBlinking(index1)
		self:StartBlinking(index2)
	end
end

function M:StartBlinking(index)
	if index>0 then
		local obj=self:findGameObject("hero_"..index).transform
		self.blinking_trans[#self.blinking_trans+1]=obj
		UIUtil.setObjectVisible(obj,true,"UI_RTAMainPop_heros")
	end
end

function M:init_selectNode_rightPart()
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn)
		UIUtil.setObjectVisible(tog_btn.transform, i==1,"UI_ShareLv_Xuanze_01") --默认第一个
		UIUtil.addToggleListener(tog_btn, function(is_on, data)
			if is_on then
				if data == 9 then
					self:updateMsg("tab_btn", 100) --SP处理
				else
					self:updateMsg("tab_btn", data - 1)
				end

				UIUtil.setObjectVisible(tog_btn.transform, true,"UI_ShareLv_Xuanze_01")
			else
				UIUtil.setObjectVisible(tog_btn.transform, false,"UI_ShareLv_Xuanze_01")
			end
		end, i, self.m_uiName)
	end
	self:updateHerosScroll(false)
end

function M:updateHerosScroll(keepOffset)

	keepOffset=keepOffset==nil and true or false
	local data = self.m_model.hero_list

	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("heros_scroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			one_line_count = 3,
			loop_scroll_object = list_scroll,
			init_cell = function(index, cell_object)
				local function callback()
					local cell_data = self.m_list_scroll.m_show_data[index]
					local itemNode = ResourceUtil:LoadUIGameObject("Main/MainHeroNodeCell", Vector3.zero, nil)
					local canvas_group = itemNode:GetComponent("CanvasGroup")
					canvas_group.blocksRaycasts = false

					itemNode.name = "cell_content"
					itemNode.transform:SetParent(cell_object.transform, false)
					if cell_data then
						--self.hero_tab[cell_data] = itemNode
						self:listHandle(itemNode, index)
						itemNode:SetActive(true)
					else
						itemNode:SetActive(false)
					end
				end
				if index <= 9 then
					self.m_control:setOnceTimer(index <= 9 and  (0.033*index) or 0, callback)
				else
					callback()
				end
			end,
			update_cell = function(index, cell_object, cell_data)
				local content_tran = UIUtil.findTrans(cell_object.transform, "cell_content")
				if not IsNull(content_tran) then
					content_tran.gameObject:SetActive(true)
					--local data = cell_data
					--self.hero_tab[cell_data] = content_tran
					self:listHandle(content_tran, index)
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local oid = self.m_model:getHeroDataByIndex(index)
				local data, _ = UserDataManager.hero_data:getHeroDataById(oid)
				local isForbidden=self.m_model:judgeForbidden(data.id)
				if self.m_model:judgeSelected(data.id) or isForbidden then
					return
				end
				local content_tran = UIUtil.findTrans(cell_object.transform, "cell_content")
				if content_tran then
					if not IsNull(self.select_cell_obj) then
						local LuaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
						LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",false)
					end
					self.select_cell_obj = content_tran
					local LuaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
					LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",true)

					if oid ~= self.m_model.cur_seclect_hero_oid then
						self:updateMsg("select_hero", {oid = oid,index = index})
					end
				end
			end,
			ui_name = self.m_uiName,
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data, keepOffset)
	end
end

function M:listHandle(obj, id)
	local oid = self.m_model:getHeroDataByIndex(id)
	if oid == nil then
		return
	end
	local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
	GameUtil:updateHeroContent(obj, oid)

	if LuaBehaviour then
		--local content_tran = UIUtil.findTrans(obj.transform, "cell_content")
		--if not IsNull(obj) then
		--	local btn=content_tran:GetComponent("Button")
		--	btn.enabled=false
		--end

		if oid == self.m_model.cur_seclect_hero_oid then
			--self.select_HeroItem = obj
			--self.select_cell_obj = obj
			--self.m_model.m_select_index = id
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",true)
		else
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",false)
		end
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",false)
		local isForbidden=self.m_model:judgeForbidden(data.id)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock_img",false)
		if isForbidden then
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock_img",true)
			LuaBehaviourUtil.setTextByLanKey(LuaBehaviour,"lock_text","arena_str_0039")
		else
			local isInSelectedIds=self.m_model:judgeSelected(data.id)
			if isInSelectedIds then
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock_img",true)
				LuaBehaviourUtil.setTextByLanKey(LuaBehaviour,"lock_text","arena_rta_str_0015")
			end

		end
	end
end


function M:set_selected_hero(cell_object,hero_id)
	local itemData = RewardUtil:getProcessRewardData({ RewardUtil.REWARD_TYPE_KEYS.HEROS,hero_id, 1})
	GameUtil:updateItemElementByData(cell_object, itemData)
end

function M:enterBanUI(end_ts)
	self:setObjectVisible("selected_hero_spine",false)

	self:setObjectVisible("ban_select",true)
	local select_node_go=self:findGameObject("select_node")
	local behaviour=UIUtil.findLuaBehaviour(select_node_go.transform)
	behaviour:RunAnim("select_node_ani",function()  end)
	self:setBanState(true)
	self:SetBanHeroEffect(true)
	self.m_control:setOnceTimer(2,function()
		self:startBanturn(end_ts)
	end)
end

function M:onMySelectionAni()
	--self.mySelectionAni:Play()
	self.curAni=self.mySelectionAni
end

function M:onOtherSelectionAni()
	--self.otherSelectionAni:Play()
	self.curAni=self.otherSelectionAni
end

function M:stopSelectionAni()
	if self.curAni~=nil then
		self.curAni:Stop()
	end
end

function M:addBattleVS()
	local BattleVSNode = CustomRequire("UI.Arena.ArenaRTA.BattleVSNode")
	self.m_battle_vs_node = BattleVSNode.new(self.m_control)
end

function M:removeBattleVS()
	if self.m_battle_vs_node then
		self.m_battle_vs_node:destroy()
		self.m_battle_vs_node = nil
	end
end

function M:UnRegisterEvent()
	EventDispatcher:unRegisterEvent("RTAMainTime")
	EventDispatcher:unRegisterEvent("SelectTime")
	EventDispatcher:unRegisterEvent("banSelectTime")
end

function M:destroy()
	EventDispatcher:unRegisterEvent("RTAMainTime")
	EventDispatcher:unRegisterEvent("SelectTime")
	EventDispatcher:unRegisterEvent("banSelectTime")

	self:removeBattleVS()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M