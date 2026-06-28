local M = class("FivelinesControl",LikeOO.OOControlBase)

function M:onEnter()
	if self.m_model.m_data.status == 0 then
		--把激活按钮隐藏掉
		self.m_view:refreshUI();
		self.m_view:setObjectVisible("battle_btn", false);
		self.m_view:setObjectVisible("saodang_btn", false);
	end
	--测试激活
	--self.m_model.m_data.status = 0
	SceneManager:changeScene(SceneManager.SceneID.WuXingZhenScene, self.m_model.m_data )
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.OPEN_VIEW, {self, self.openViewEvent})
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	self.m_guide_file_name = "UI.Fivelines.Guide"
	self.netToReward = false
	SceneManager:getCurSceneModel():setPackagePosition(self.m_view.relic_formation_btn);
end

function M:startGuide()
	UserDataManager.guide_data:setAnyTeamGuide(41, 2)
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		--self:openView("Loading.BattleLoading", {callfunc = function(open_flag)
		--	if open_flag == "open_view" then
		--		SceneManager:setData("show_loading_black", true)
				EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE)
				self:closeView()
		--		if not self:hasChild("Main.Outskirts") then
		--			self:updateMsg("close_battle_loading", nil, "parent")
		--		end
		--	end
		--end })
	elseif msg == "click_element" then
		local def_count = self.m_model:getDefCount()
		if data and data ~= "" then
			if data <= def_count then
				self:openView("Fivelines.FiveLinesDeffDetail", {index = tonumber(data), cur_floor = self.m_model.cur_floor, element = self.m_model.m_data.cur_element })
				audio:SendEvtUI('Play_UI_EnemySelect')
			else
				if SceneManager.curScene ~= nil then
					SceneManager.curScene:MoveTo()
				end
			end
		end
		SceneManager.curScene.wxCameraController:LockMove(true)
	elseif msg == "update_data" then
		self:closeView()
	elseif msg == "fly_yiwu" then
		self.m_view:tantanBag();
	elseif msg == "stamp_btn" then
		self:openView("Fivelines.FiveLinesRestraintPop", self.m_model.m_data.cur_element)
	elseif msg == "relic_formation_btn" then
		self:openView("MazeStage.MazeStageRelicFormationShow", {data = self.m_model.m_data})
	elseif msg == "rank_btn" then
		self:openView("Fivelines.FiveLinesRank")
	elseif msg == "reset_btn" then
		local params = {
			on_ok_call = function(msg)
				self:netReset()
			end,
			no_close_btn = false,
			tow_close_btn = true,
			text = Language:getTextByKey("是否重置？")
		}
		self:openView("Pops.CommonPop", params)
	elseif msg == "refresh_data" then
		self:getNetData()
		self.netToReward = false
	elseif msg == "saodang_btn" then
		--点击扫荡
		self.m_model:getNetData("five_element_sweep", nil, function( data )
			--服务器返回值
			--'reward': {},
			--'remain_times': 0,
			--"open_times": 0,
			--"four_tower_id": 0,
			
			local params = {
				open_times = data.open_times,
				remain_times = data.remain_times,
				reward = data.finish_gift,
				finish = false,
			}
			--发送到五行阵主界面更新奖励
			static_rootControl:updateMsg("five_mopping", params , "Fivelines")
		end)
	elseif msg == "five_over" then
		self.m_model.floor = data.floor;
		self.m_model.finish = data.finish;
		--self.m_model:updateData()
		self.m_view:refreshUI()
		SceneManager:getCurSceneModel():resetShitou()
	elseif msg == "openRewardView" then
		if self.m_model.m_data.floor == 0 then
			self.m_model:updateData()
			self.m_view:refreshUI()
		else
			data.finish = self.m_model.finish;
			data.first_reward = self.m_model.first_reward;
			self:openView("Fivelines.FiveLinesRewardPop", data)
		end
	elseif msg == "five_mopping" then
		data.finish = self.m_model.finish
		--五行阵扫荡完成
		self.m_model:updateTimeData(data);
		self.m_view:refreshUI();
		self:openView("Fivelines.FiveLinesRewardPop", data)
	elseif msg == "fly_to_target" then
		--self.m_view:moveHeirloom(data)
	elseif msg == "battle_end_refresh_ui" then
		if data ~= nil and data.data ~= nil then
			self.m_model.first_reward = data.data.first_reward;
		end
		self:getNetData( function()
			--SceneManager:setData("show_loading_black", true)
			SceneManager:changeScene(SceneManager.SceneID.WuXingZhenScene, self.m_model.m_data)
			--if data and data.data and next(data.data.reward or {}) ~= nil then
			--	RewardUtil:rewardTipsByData(data.data.reward)
			--end
			self.m_view:updateQuestSpecial()
		end)
		--if data and data.data and data.data.reward then
		--	self.m_model.m_reward = data.data.reward
		--end
	elseif msg == "battle_start_openDetail" then
		--战斗数据
		if data.index == 0 then -- boss
			audio:SendEvtUI("UI_SiXiangZhen_Boss")
		end
		self.m_model.m_param_battle_data = data;
		self:updateMsg("battle_start", { data = self.m_model.m_param_battle_data.fightData, index = data.index }, "Fivelines")
		--self:openView("Fivelines.FiveLinesDeffDetail", { data = self.m_model.m_param_battle_data.fightData, index = data.index })
	elseif msg == "battle_start" then
		if data == nil then
			data = { data = self.m_model.m_param_battle_data.fightData, index = self.m_model.m_param_battle_data.index }
		end
		local mood_shadow_stage_config = ConfigManager:getCfgByName("mood_shadow_stage")
		local mood_shadow_stage_config_item = mood_shadow_stage_config[self.m_model.cur_floor]
		if mood_shadow_stage_config_item == nil then
			Logger.logError(" 活动未开启 ")
		else
			local boss_pos = 0;
			local boss_size = 1;
			if data.index == 0 then
				local stage_battle_active = ConfigManager:getCfgByName("stage_battle_active")
				local active_stage_item = stage_battle_active[mood_shadow_stage_config_item.stage_battle]
				boss_pos = active_stage_item.boss_position
				boss_size = active_stage_item.boss_size_mode
			end
			self:openView("Formation", {mode = GlobalConfig.BATTLE_MODE.FIVE_ARRAY,
										def_data = data.data,
										assist_heros = self.m_model.m_data.assist_heros,
										five_pos = data.index, --五行阵中的位置
										boss_pos = boss_pos,
										boss_size = boss_size,
										boss_id = self.m_model.cur_floor,
										heirlooms = self.m_model.m_data.heirlooms,
										version = self.m_model.m_data.version })
		end
	elseif msg == "enter_next_floor" then
		--self.m_model:getNetData("five_element_enter_next_floor",nil, function( data )
		--	SceneManager.curScene:enterNext( data )
		--end);
		--self.m_view.content_node:SetActive(false)
	elseif msg == "help_btn" or  msg == "hint_btn" then
		self:openHelpPop()
	elseif msg == "initSence" then
		
	elseif msg == "guide_check" then
		self.m_guide:checkGuide()
	elseif msg == "updateElem" then
		self.m_view:updateElemIcon()
	elseif msg == "auto_btn" then
		SceneManager.curScene:autoFight(#self.m_model.m_data.battle_logs);
	elseif msg == "showView" then
		self.m_view.content_node:SetActive(true)
		self.m_view:showEffectTX()
	elseif msg == "battle_btn" then
		--现在改成激活按钮 
		self.m_model:getNetData("five_element_enable",nil, function( server_data )
			--把激活按钮隐藏掉
			self.m_view:setObjectVisible("battle_btn", false);
			self.m_model.m_data = server_data;
			self.m_model:updateData();
			self.m_view:refreshUI();
			self.m_view:setObjectVisible("saodang_btn", false);
			--激活
			SceneManager.curScene:activeScene( self.m_model.m_data );
		end);
		--SceneManager.curScene:autoFight(#self.m_model.m_data.battle_logs);
	elseif msg == "quest_special_btn" then
		self:openView("Task.TaskMainChapter", {quest_type = 44})
	end
end

function M:netReset()
	local function callfunc()
		self.m_view:refreshUI()
	end
	self.m_model:getNetData("five_element_reset",nil, callfunc)	
end

function M:getNetData( callback_net )
	local function callback(requs)
		if requs then
			self.m_model.m_data = requs
		end
		self.m_model:updateData()
		self.m_view:refreshUI()
		if callback_net ~= nil then
			callback_net()
		end
	end
	--self.m_model:getNetData("five_element_index", nil, callback, nil, true)
	self.m_model:getNetData("mood_shadow_train_index", nil, callback, nil, true)
end

function M:getRewardNetData()
	local function callback(requs)
		RewardUtil:rewardTipsByData(requs.reward)
		self.m_model.m_data.floor = requs.floor;
		self.m_model:updateData()
		self.m_view:refreshUI()
	end
	self.m_model:getNetData("receive_rewards", nil, callback)
end

function M:openHelpPop()
    local params = {
		title = "tid#tower1",
        content = "tid#tower2"
	}
    self:openView("Pops.CommonFiveLineHelpPop", params)
end

function M:closeViewEvent(event, data)
	local view_name = data.name or ""
	if view_name == "Pops.CommonRewardPop" then
		
	end
end

function M:openViewEvent(event, data)
	local view_name = data.name or ""
	if view_name == "Pops.CommonRewardPop" then
		if SceneManager.curScene ~= nil then
			--不用加载完成自动打开
			SceneManager.curScene.noLoadFinishAutoMove = false;
		end
	end
end

function M:dataUpdateEvent(event, data)
	local curEvent = data.event
	if curEvent == "quest_special_update" then
		self.m_view:updateQuestSpecial()
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.OPEN_VIEW, {self, self.openViewEvent})
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	M.super.destroy(self)
	SceneManager:clear();
	
end

function M:AutoBtn()
	if self.m_model.m_five_element_auto == 0 then
		self.m_model.m_five_element_auto = 1
	else
		self.m_model.m_five_element_auto = 0
	end
	UserDataManager.local_data:setUserDataByKey("five_element_auto", self.m_model.m_five_element_auto)
	self.m_view:updateAutoImg()
end

return M