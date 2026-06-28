---@class FormationControl : OOControlBase
---@field m_view FormationView
---@field m_model FormationModel
local M = class("FormationControl",LikeOO.OOControlBase)

function M:onEnter()
	self:enterCallBack( function()
		self:updateMsg("close_battle_loading",nil,"parent")
		audio:SendEvtUI("Out_Battle")
		if self.m_model then
			local util_item = BattleModeUtil[self.m_model.m_mode]
			if util_item and util_item.formationControlSceneLoadFinish then
				util_item.formationControlSceneLoadFinish(self)
			end
		end
		end);
	self.isShowFormation = false;
	self.clickNextTeam = false;
	--进入布阵界面，先不让点击
	self.m_view:lockTouch();

	EventDispatcher:registerEvent("refreshHelperUI", {self, self.refreshHelperUI})
end

function M:openTransition()
	-- 因为界面打开延时0.1秒，隐藏order低的界面时会闪现主界面挂机角色，故上阵界面延时0.2s（其他界面可根据动画延时。但是上阵界面和角色资源加载挂钩只能代码延时处理）
	self:setOnceTimer(0.2,function()
		M.super.openTransition(self)
		if self.m_model.m_params.enter_call_func ~= nil then
			self.m_model.m_params.enter_call_func();
		end
	end)
end

function M:runStory( callback )
	--战斗前的逻辑
	--场景剧情不是空
	if SceneManager:getCurSceneView().story ~= nil then
		--0 先播放别的剧情
		--1 先播放我
		if SceneManager:getCurSceneView().story.playIndex == 0 then
			--播放剧情
			self:formation_play_drama( function()
				--播放站立对话
				SceneManager:getCurSceneView():runStory(function()
					if callback ~= nil then
						callback();
					end
				end)
			end)
		else
			--先播放站立对话
			SceneManager:getCurSceneView():runStory(function()
				--再播放 drama
				self:formation_play_drama( function()
					if callback ~= nil then
						callback();
					end
				end)
			end)
		end
	end
end


--播放布阵前的剧情
function M:formation_play_drama( callback_drama )
	local stage_cfg = GameUtil:getBattleStageCfg()
	if stage_cfg.open_event ~= 0 then
		local function callback()
			if callback_drama ~= nil then
				callback_drama()
			end
		end
		self:openView("Guide.GuideDrama", {dialog_id = stage_cfg.open_event, callback = callback})
	else
		if callback_drama ~= nil then
			callback_drama()
		end
	end
end



function M:enterCallBack( callbcak )

	-- STAGE = 1, -- 推图
	-- TOWER = 2, -- 爬塔
	-- RACE_TOWER = 3, -- 种族塔
	-- MAZE = 4, -- 迷宫
	-- LOCAL_ARENA = 5, -- 普通竞技场
	-- MULT_FORMATION = 10, -- 多编队
	-- HIGH_ARENA = 11, -- 高阶竞技场
	-- HIGH_ARENA_DEFENSE = 12, -- 高阶竞技场防守阵容
	-- LOCAL_ARENA_DEFENSE = 13, -- 竞技场防守阵容
	-- WORLD_BOSS = 14, -- 世界boss
	self.m_view:runAnim("formation_UI_start");
	self.m_guide_file_name = "UI.Formation.Guide"

	self:setOnceTimer(0.1, function()
		if SceneManager:getCurSceneView() ~= nil and SceneManager:getCurSceneView().cameraController ~= nil then
			SceneManager:getCurSceneView().cameraController:BlackScreen(false);
		end
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOWER or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER then
			SceneManager:changeScene(SceneManager.SceneID.TianjiLouFightScene, {race = self.m_model.m_race}, true)
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI  then
			SceneManager:changeScene(SceneManager.SceneID.TianjiLouFightScene, {race = 0}, true)
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER  then
			SceneManager:changeScene(SceneManager.SceneID.TianjiLouFightScene, {version = self.m_model.version}, true)

		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO then
			SceneManager:changeScene(SceneManager.SceneID.TianjiLouFightScene, {}, true)

		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MAZE then
			SceneManager:changeScene(SceneManager.SceneID.MiGongFightScene)
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE then
			SceneManager:changeScene(SceneManager.SceneID.GuJianQiTanFightScene)
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FOUR_TOWER
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.YINYANG_TOWER
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WD_TOWER
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD then
			SceneManager:changeScene(SceneManager.SceneID.WuXingZhenFightScene, {mode = self.m_model.m_mode})
		elseif self.m_model.m_mode == Battle.BattleGlobalConfig.BATTLE_MODE.LEGEND then
			SceneManager:changeScene(SceneManager.SceneID.LegendScene, {legend_stage_id = self.m_model.m_battle_id})
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNION_BOSS then
			SceneManager:changeScene(SceneManager.SceneID.BossScene,{state = 2, mode = self.m_model.m_mode, m_boss_id = self.m_model.m_boss_id, m_boss_max_hp = self.m_model.m_boss_max_hp, m_boss_hp_cid = self.m_model.m_boss_hp_cid })
			SceneManager:getCurSceneModel():setBossState(2);
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
			SceneManager:changeScene(SceneManager.SceneID.ActiveBossScene,{state = 2, mode = self.m_model.m_mode, m_boss_id = self.m_model.m_boss_id, m_boss_max_hp = self.m_model.m_boss_max_hp, m_boss_hp_cid = self.m_model.m_boss_hp_cid })
			SceneManager:getCurSceneModel():setBossState(2);
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE then
			SceneManager:changeScene(SceneManager.SceneID.HeroTrainScene,{state = 2, mode = self.m_model.m_mode, m_boss_id = self.m_model.m_boss_id })
			SceneManager:getCurSceneModel():setBossState(2);
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HERO_BOSS_PVE then
			SceneManager:changeScene(SceneManager.SceneID.HeroTrainScene,{state = 2, mode = self.m_model.m_mode, m_boss_id = self.m_model.m_boss_id})
			SceneManager:getCurSceneModel():setBossState(2);
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HERO_BOSS_PVP then
			local level = UserDataManager:getBattleStage();
			--local level = 1502 --写死
			local common = { param = level }
			SceneManager:changeScene(SceneManager.SceneID.FightScene, { mode = self.m_model.m_mode, common = common, raid_sort = self.m_model.m_raid_sort, max_time = GlobalTools.base60}, self.m_model.new_chapter)
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RAID then
			local level = UserDataManager:getBattleStage();
			local common = { param = level }
			SceneManager:changeScene(SceneManager.SceneID.FightScene, { mode = self.m_model.m_mode, common = common, raid_sort = self.m_model.m_raid_sort }, false)
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.QIMENDUNJIA then
			SceneManager:changeScene(SceneManager.SceneID.QiMenDunJiaScene)
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
			local common = { param = self.m_model.m_stage_id }
			SceneManager:changeScene(SceneManager.SceneID.FightScene,{state = 2, 
																	  mode = self.m_model.m_mode, 
																	  common = common,
																	  m_boss_id = self.m_model.m_boss_id,
																	  m_boss_max_hp = self.m_model.m_boss_max_hp,
																	  m_move_camera = self.m_model.m_move_camera,
			})
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HERO_FATE then
			local common = { param = self.m_model.m_battle_id, battle_scene = self.m_model.m_cur_stage_cfg.battle_scene} --单独新增场景id
			SceneManager:changeScene(SceneManager.SceneID.FightScene, { mode = self.m_model.m_mode, common = common, raid_sort = self.m_model.m_raid_sort }, false)
		else
			local level = UserDataManager:getBattleStage();
			local common = { param = level }
			SceneManager:changeScene(SceneManager.SceneID.FightScene, { mode = self.m_model.m_mode, common = common, raid_sort = self.m_model.m_raid_sort }, self.m_model.new_chapter)
		end
		if self.m_model.m_mode == 3 or self.m_model.m_mode == 4 then
			SceneManager:scenestart()
		end
		self:handle_arrayingPlayers( callbcak )
		local battleConfig = require("Battle.battleConfig")
		if battleConfig ~= nil and battleConfig.useMe == true then
			local story = battleConfig.battle_story
			if story ~= nil and story.story_id ~= 0 then
				--story_type: 0为引导，1为主线，2为江湖剧情
				local is_guide = story.story_type == 0
				local story_type = 0
				if story.story_type == 2 then
					story_type = GlobalConfig.WORLD_MAP_EVENT.REGIONAL_EVENT
				end
				self:openView("Guide.GuideDrama", {dialog_id = story.story_id, dialogue_type = story_type, guide = is_guide, callback = nil})
			end
		end
	end)
end


function M:handle_arrayingPlayers( callbcak )
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
		if self:isStoryLevel() then
			local params = {};
			params.s_id = UserDataManager:getBattleStage()
			self.m_model:getNetData("scenario_index",params, function( data )
				self:arrayingStoryPlayers( callbcak )
			end)
		else
			self:arrayingPlayers( callbcak )
		end
	else
		self:arrayingPlayers( callbcak )
	end
end

--是否是剧情关
function M:isStoryLevel()
	--加载剧情关配置
	--local scenario_config = ConfigManager:getCfgByName("scenario_config");
	--for k,v in pairs(scenario_config) do
	--	if tonumber(k) == UserDataManager:getBattleStage() then
	--		return true;
	--	end
	--end
	return false;
end


function M:startGuide()

end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		if self.m_model.m_bottom_type == 1 then
			self:updateMsg("bottom_return2")
			if self.m_model.m_mult_team_edit_flag == true then
				self.m_model.m_mult_team_edit_flag = false
				self.m_view:refreshMultTeamToggles(true)
				self:updateMsg("open_multi_formation_btn")
			end
			return
		end
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RAID then
			SceneManager:changeScene(SceneManager.SceneID.HangUpScene)
			self:closeView()
		else
			if self.m_model.m_from_view == "WorldMapMain" then
				SceneManager:changeScene(UserDataManager.cur_map_id)
				self:closeView()
			else
				if 	self.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
					self:updateMsg("refreshPetModel", nil, "PetBreeding.PetArenaMain")
				end
				local mode_util_item = BattleModeUtil[self.m_model.m_mode]
				if mode_util_item and mode_util_item.formationControlClose then
					mode_util_item.formationControlClose(self)
				else
					if self.m_model.m_params.back_scene ~= nil and self.m_model.m_params.back_scene >= SceneManager.SceneID.WorldScene1 and self.m_model.m_params.back_scene <= SceneManager.SceneID.WorldScene9 then
						self:openView("WorldMap.WorldMapMain", {default_scene = self.m_model.m_params.back_scene})
					else
						self:updateMsg("common_refresh", nil, "parent")
						SceneManager:changeScene(SceneManager.SceneID.HangUpScene)
					end
					self:closeView()
				end
			end
		end
	elseif msg == "reset_mult_edit_flag" then
		self.m_model.m_mult_team_edit_flag = false
		self.m_view:refreshMultTeamToggles(true)
	elseif msg == "talk" then
		--纯对话
		local function callback(event_data)
			if data.callback then
				data.callback(event_data)
			end

			--剧情关
			--向服务器发送完成对话
			local params = {}
			params.s_id = UserDataManager:getBattleStage();
			params.node_id = data.node_id;
			self:getNetData("scenario_finish",params);
			
			if data.heirloom_reward and #data.heirloom_reward > 0 then
				self:openView("Pops.RelicReward", {heirlooms = data.heirloom_reward})
			end
		end
		self:openView("Guide.GuideDrama", {dialog_id = data.talk_id, callback = callback, choise = data.choise, choise_id = data.choise_id})
	elseif msg == "talkBattle" then
		--对话 + 战斗
		local function callback(event_data)
			if data.callback then
				data.callback(event_data)
			end
			--剧情关
			--向服务器发送完成对话
			self.m_model.node_id = data.node_id
			self:getBattleStart();
			
			if data.heirloom_reward and #data.heirloom_reward > 0 then
				self:openView("Pops.RelicReward", {heirlooms = data.heirloom_reward})
			end
		end
		self:openView("Guide.GuideDrama", {dialog_id = data.talk_id, callback = callback, choise = data.choise, choise_id = data.choise_id})
	elseif msg == "test_battle" then
		self:openView("GamePanel", data)
	elseif msg == "add_value_info_btn" then
		self.btn_trans = self.m_view:findGameObject("add_value_info_btn")
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
			local difficulty_reduce = self.m_model.m_difficulty_reduce
			local tips_str = Language:getTextByKey("fb_str_0032", difficulty_reduce)
			GameUtil:lookInfoTips(self.m_control, {click_transform = self.btn_trans.transform, msg = tips_str, text_anchor_value = "MiddleLeft"} )
			return
		end
		GameUtil:lookInfoTips(self.m_control, {click_transform = self.btn_trans.transform, msg = Language:getTextByKey("fb_str_0031"), text_anchor_value = "MiddleLeft"} )
	elseif msg == "lock_formation" then
		self.m_view:lockTouch();
	elseif msg == "un_lock_formation" then
		self.m_view:unlockTouch();
	elseif msg == "exit_story_btn" then
		SceneManager:changeScene(SceneManager.SceneID.HangUpScene)
		self:closeView()
	elseif msg == "h_close_btn" then
		self:updateMsg(99999)	
 	elseif msg == "click_card" then 
		self:setGoInToBattle(data)  
		self.m_guide:checkGuide()
	elseif msg == "click_pet_card" then
		self:setPetInToBattle(data)
	elseif msg == "drag_card" then
		local hero_id = data.heroid
		if not self.m_model:inquireInTeams(hero_id) and not self:heroCanGoToBattle(hero_id) then
			return
		end
		self.m_view:lockTouch("go_drag_battle")
		SceneManager:getCurSceneView():goDragBattle(hero_id, function()
			if self.m_model then
				self.m_view:unlockTouch("go_drag_battle")
			end
		end)
	elseif msg == "start_btn" or msg == "start_btn2" then
		self.m_view:playTiaoZhan()
		Logger.log("start_btn111111111111111111111111111111111")
		local mode_util_item = BattleModeUtil[self.m_model.m_mode]
		if mode_util_item and mode_util_item.formationControlStartBattle then
			Logger.log("start_btn222222222222222222222")
			mode_util_item.formationControlStartBattle(self)
		else
			audio:SendEvtUI("Ui_Fight")
			if self.m_model.m_mult_team_flag then
				if self.m_model.m_formation_index >= self.m_model.m_team_nums or self.m_model.m_auto_battle_flag or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR then
					self:getBattleStart()
				else -- 下一队
					if self.clickNextTeam == false then
						self.m_view:nextBtnStatus()
						self.clickNextTeam = true;
						self:setOnceTimer(3, function()
							self.clickNextTeam = false;
						end)
					end
				end
			else
				self:getBattleStart()
			end
		end

	elseif msg == "hint_btn" then
		self:openView("Pops.Restraint_Pop")
	elseif msg == "showFormation" then
		local info = UserDataManager.guide_data:getCurGuideInfo()
		local can_auto = true
		if info and info.key == "Formation" then
			can_auto = false
		end
		if can_auto and self.m_model.m_auto_battle_flag and ((self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.MULT_STAGE and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.GU_JIAN_MULT) or self.m_model.m_is_first) then
			self.m_model.m_is_first = false
			self:updateMsg("start_btn")
		end
		self.m_view:unlockTouch();
		if self.isShowFormation == false then
			self.m_view:runAnim("formation_UI_in",handler(self,self.RunAnimEnter));
			self.m_guide:checkGuide()
			self.isShowFormation = true;
		end
	elseif msg == "hideFormation" then
		if self.isShowFormation == true then
			self.m_view:runAnim("formation_UI_out");
			self.isShowFormation = false;
		end
	elseif msg == "reset_btn" then													 
		self:removeAllHero()
	elseif msg == "updatePlayerPosData" or msg == "updatePlayerPosGuide" then
		table.merge(self.m_model.main_team, data)
		self:updateMsg("refreshUI",nil, "Formation.MultiFormation")
		--if self.m_view.m_multi_formation_node then
		--	self.m_view.m_multi_formation_node:refreshUI()
		--end
		self.m_view:refreshUI()
		self.m_view:updateBuffLv(self.m_model:getAddBuffLv(), false)
		self.m_model.m_team_changed_flag = true
		self.m_view:refreshUnionWarSelectTeamRedPoint()
	elseif msg == "save_btn" then
		if self.m_model.m_mult_team_edit_flag then
			self.m_view:refreshMultTeamToggles(true)
			self:saveFormation()
		elseif self.m_model.m_mult_team_flag then
			if self.m_model.m_formation_index >= self.m_model.m_team_nums then
				self:saveFormation()
			else -- 下一队
				self.m_view:nextBtnStatus()
			end
		else
			self:saveFormation()	
		end
		self.m_view:setObjectVisible("save_btn", false)
		self.m_view:setObjectVisible("bottom_return", true)
	elseif msg == "goDownBattle" then
		self:setGoInToBattle(data)
	elseif msg == "hero_buff_btn" or msg == "h_hero_buff_btn" then
		local res1, res2, race1, race2 = self.m_model:checkArray()
		self:openView("Pops.FetterBuffPop", {buff_lv = res1, demon_num = res2})     
	elseif msg == "enemy_buff_btn" or msg == "h_enemy_buff_btn" then
		local res1, res2, race1, race2 = self.m_model:checkEnemyArray()
		self:openView("Pops.FetterBuffPop", {buff_lv = res1, demon_num = res2})
	elseif msg == "relic_info_btn" then
		self:openView("MazeStage.MazeStageRelicFormationShow", {data = {heirlooms = self.m_model.m_heirlooms, assist_heros = self.m_model.m_assist_heros}})
	elseif msg == "mult_team_click" then
		self:changeMultTeam(data)
	elseif msg == "hero_deployment" then
		self:openView("Formation.Deployment", {deployment_id = self.m_model.m_atk_deployment})
	elseif msg == "click_select_deployment" then
		self.m_model:updateAtkDeployment(data.cell_data.id)
		self:updateDeployment()
		if SceneManager:getCurSceneView() and SceneManager:getCurSceneView().updateDeployment then
			SceneManager:getCurSceneView():updateDeployment(self.m_model.m_atk_deployment, self.m_model.m_def_deployment)
		end
	elseif msg == "load_scene_finish" then
		--self.m_guide:checkGuide()
	elseif msg == "buzhen_btn" then
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then  --宠物斗技
			self.m_view:setCloseText(false)
			self.m_model.m_bottom_type = 1
			self.m_model.show_pet_bl = true
			if SceneManager:getCurSceneView().SetCameraHeight then
				SceneManager:getCurSceneView():SetCameraHeight(self.m_model.m_bottom_type)
			end
			SceneManager:getCurSceneView().canDownFlag = false -- 可拖下阵
			self.m_view:switchBottomObjType()
			self:updateMsg("hide_multi_formation_btn")
		else
			self.m_view:setCloseText(false)
			self.m_model.m_bottom_type = 1
			self.m_model.temp_team = table.copy(self.m_model.main_team)
			if SceneManager:getCurSceneView().SetCameraHeight then
				SceneManager:getCurSceneView():SetCameraHeight(self.m_model.m_bottom_type)
			end
			SceneManager:getCurSceneView().canDownFlag = true -- 可拖下阵
			self.m_view:switchBottomObjType()
			self:updateMsg("hide_multi_formation_btn")
		end
	elseif msg == "bottom_return" then
		self.m_model.m_bottom_type = 0
		if SceneManager:getCurSceneView().SetCameraHeight then
			SceneManager:getCurSceneView():SetCameraHeight(self.m_model.m_bottom_type)
		end
		SceneManager:getCurSceneView().canDownFlag = false
		self.m_view:switchBottomObjType()
		self.m_view:setCloseText(true)
		self.m_model:setUnionWarTeam()
		self.m_view:refreshRedPoint()
		self.m_view:updateUnionWarSelectTeamTog()
	elseif msg == "bottom_return2" then
		if self.m_model.m_bottom_type == 0 then return end
		self.m_view:setCloseText(true)
		if self.m_model:checkTeamChange() == true then
			if not self.m_model:isUnionWarTeams() then
				for k,v in pairs(self.m_model.main_team) do
					if v and #v > 0 then
						self:sendState(v, k, false)
					end
				end
				self.m_model.main_team = table.copy(self.m_model.temp_team)
				for k,v in pairs(self.m_model.main_team) do
					if v and #v > 0 then
						self:sendState(v, k, true)
					end
				end
			else
				--公会战保存提示
				local params =
				{
					on_ok_call = function(msg)
						self:requestSaveUnionWarTeam()
						self:updateMsg("bottom_return")
					end,
					on_cancel_call = function(msg)
						self:cancelSaveUnionWarTeam()
					end,
					tow_close_btn = true,
					ok_text = Language:getTextByKey("UnionWar_str_036"),
					cancel_text = Language:getTextByKey("UnionWar_str_037"),
					text = Language:getTextByKey("UnionWar_str_035")
				}
				self:openView("Pops.CommonPop", params)
			end
			self.m_view:updateLoopScroll()
		end
		if self.m_model.m_sel_formation_index then
			self.m_model.m_sel_formation_index = nil
			self.m_view:updateLoopScroll()
		end
		
		self.m_model.m_formation_id = 0
		self.m_model.m_bottom_type = 0
		if SceneManager:getCurSceneView().SetCameraHeight then
			SceneManager:getCurSceneView():SetCameraHeight(self.m_model.m_bottom_type)
		end
		SceneManager:getCurSceneView().canDownFlag = false
		self.m_view:switchBottomObjType()
	elseif msg == "array_btn" then
		self:openView("Formation.PassLineupPop", { mode = self.m_model.m_mode, five_pos = self.m_model.m_five_pos})
	elseif msg == "show_black_line" then
		self.m_view:runAnim("black_line_1")
		audio:SendEvtUI("UI_StoryStart")
		audio:PauseMusicBusVol()
	elseif msg == "hide_black_line" then
		self.m_view:runAnim("black_line_2")
		audio:ResumeMusicBusVol()
	elseif msg == "switch_multi_formation_btn" then
		self.m_view:switchMultiFormationBtn()	
 	elseif msg == "open_multi_formation_btn" then
		audio:SendEvtUI("Play_UI_BuZhen")
		self:openView("Formation.MultiFormation", data)
		--self.m_view:openMultiFormationNode()
		--self:updateMsg("bottom_return2")
	elseif msg == "hide_multi_formation_btn" then
		--self.m_view:closeMultiFormationNode()
		self:updateMsg(99999, nil, "Formation.MultiFormation")

		--self.m_model:resetMainTeam()
		--self:arrayingLeftPlayers()
		--self.m_view:refreshUI()
	elseif msg == "formation_edit_btn" then
		self.m_model.m_mult_team_edit_flag = true
		self.m_model:changeMultiFormation(data.index)
		self:arrayingLeftPlayers()
		self.m_view:refreshUI()
		self.m_view:updateBuffLv(self.m_model:getAddBuffLv(), false)
		--if self.m_view.m_multi_formation_node then
		--	self.m_view.m_multi_formation_node:showTeamEdit(data.index, self.m_model.main_team)
		--end
		self.m_view:setObjectVisible("save_btn", true)
		self.m_view:setObjectVisible("bottom_return", false)
		--self.m_view:closeMultiFormationNode()
		self.m_view:refreshSaveBtn()
		self:updateMsg("buzhen_btn")
		
		self.m_view:refreshMultTeamToggles(false)
	elseif msg == "set_team" then
		self.m_model:changeTeamByMultiFormation(data.index)
		self:arrayingLeftPlayers()
		self.m_view:refreshUI()
		self.m_view:updateBuffLv(self.m_model:getAddBuffLv(), false)
		--self.m_view:closeMultiFormationNode()
		self:updateMsg(99999, nil, "Formation.MultiFormation")
	elseif msg == "formation_rename_btn" then
		self:openEditFormationName(data)
	elseif msg == "team_edit_cancel_btn" then
		self.m_view:lockTouch()
		self.m_model:resetMainTeam()
		self:setOnceTimer(0.4, function()
			self.m_view:unlockTouch()
			self:arrayingLeftPlayers()
			self.m_view:refreshUI()
			self.m_view:updateBuffLv(self.m_model:getAddBuffLv(), false)

			if self:hasChild("Formation.MultiFormation") then
				self:updateMsg("showFormationList", nil, "Formation.MultiFormation")
			else
				self:openView("Formation.MultiFormation")
			end
			--if self.m_view.m_multi_formation_node then
			--	self.m_view.m_multi_formation_node:showFormationList()
			--else
			--	self:openView("Formation.MultiFormation", data)
			--	--self.m_view:openMultiFormationNode()
			--end
			if data and data.set_team_success then
				self.m_view:updateMultiFormationBtnLoopScroll()
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
			end
		end)
		self.m_model.m_bottom_type = 0
		if SceneManager:getCurSceneView().SetCameraHeight then
			SceneManager:getCurSceneView():SetCameraHeight(self.m_model.m_bottom_type)
		end
		self.m_view:switchBottomObjType()
		self.m_view:refreshSaveBtn()
	elseif msg == "team_edit_ok_btn" then
		self:saveFormationTeam()
	elseif msg == "multi_formation_btn" then
		local can_change = self.m_model:changeTeamByMultiFormation(data.index)
		if can_change then
			self:arrayingLeftPlayers()
			self.m_view:refreshUI()
			self.m_view:updateBuffLv(self.m_model:getAddBuffLv(), false)
		else
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_1080"), delay_close = 2})

		end
	elseif msg == "battle_end_refresh_ui" then
		if SceneManager:getCurSceneView() ~= nil then
			SceneManager:getCurSceneView().plyMgr:destroy();
			self:handle_arrayingPlayers()
			SceneManager:continue()
		end	
	elseif msg == "updateDeploymentTx" then
		self.m_view:playDeployementTx()
	elseif msg == "createHelperUI" then
		self.m_view:createHelperUI(data.player)
	elseif msg == "removeHelperUI" then
		self.m_view:removeHelperUI(data.player)
	elseif msg == "open_race_btn" then
		if self.m_model.race_toggle_type == true then
			self.m_model.race_toggle_type = false
		else
			self.m_model.race_toggle_type = true
		end
		self.m_view:switchRaceBtnList()
	elseif msg == "mining_tab_click" then
		self:changeMiningTeam(data)
	elseif msg == "skip_select_btn" then
		self.m_model:switchFormationSkipBattle()
		self.m_view:refreshFormationSkipBattleBtn()
	elseif msg == "high_arena_btn" then
		local params = {}
		params.mult_main_teams = self.m_model.mult_main_teams
		params.def_data = self.m_model.m_def_data
		params.mode = self.m_model.m_mode
		params.battle_id_tab = self.m_model.m_battle_id_tab
		params.assist_heros = self.m_model.m_assist_heros
		params.mult_solts = self.m_model.m_mult_solts

		params.layer=self.m_model.m_layer
		self:openView("Formation.HighArenaTeamPop", params)
	elseif msg == "set_click" then
		self.m_model.can_click = data
	elseif msg == "close_sync_load_big_loading" then --场景加载完成后的回调
		if self.m_model:isUnionWarTeams() and self.m_model:getSaveTeamBtnShow() then -- 帮会战布阵视角默认切换
			if SceneManager:getCurSceneView().SetCameraHeight then
				SceneManager:getCurSceneView():SetCameraHeight(self.m_model.m_bottom_type)
			end
		end
	elseif msg == "high_arena_exchange_team" then
		if data and data.mult_main_teams then
			self.m_model:setMultTeamData(data.mult_main_teams)
		end
		if data and data.mult_solts then
			self.m_model:setWeaMultSolt(data.mult_solts)
		end
		self:changeMultTeamRefresh()
	elseif msg == "weapon_mask_btn" then --关闭法宝选择页面
		self.m_view:hideSelectType()
	elseif msg == "switch_weapon" then --选择法宝
		audio:SendEvtUI("UI_Tab_N5")
		self:useWeapon(data)
	elseif msg == "guildwar_tog_test" then --帮会模拟战勾选
		local issim = UserDataManager.local_data:getUserDataByKey("simulated_battle_flag")
		if issim == true then
			self.m_view:refreshGuildWarTogSelect(false)
		else
			self.m_view:refreshGuildWarTogSelect(true)
		end
	elseif msg == "weapon_hint_btn" then --布阵法宝弹窗
		self.m_view:formationWeapopPop()
	elseif msg == "heaven_no_btn" then --点击"暂无阵法"
		--if self.m_view.m_heros_active_heaven_nil and self.m_view.m_heros_active_heaven_nil == true then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("heavenEarth_text_004"), delay_close = 2})
		--	return
		--end
		--self.m_view:showActiveHeavenHeroes()
	--elseif msg == "active_heros_close" then
	--	self.m_view:closeActiveHeavenHeroes()
	elseif msg == "click_heaven_cell" then --点击阵法图标
		local id = data.id
		if id ~= self.m_model.m_select_heaven_id then
			self.m_model.m_team_changed_flag = true
			self.m_model:setHeavenID(id)
			self.m_view:resetHeroCombat()
		end
	elseif msg == "check_heaven_cell" then --点击阵法详情
		self.m_view:showHeavenDetail(data)
	elseif msg == "heaven_detail_pop_close" then --关闭阵法详情
		self.m_view:closeHeavenDetail()
	elseif msg == "pet_cell" then
		self.m_view:setCloseText(false)
		self.m_model.m_bottom_type = 1
		self.m_model.show_pet_bl = true
		if SceneManager:getCurSceneView().SetCameraHeight then
			SceneManager:getCurSceneView():SetCameraHeight(self.m_model.m_bottom_type)
		end
		SceneManager:getCurSceneView().canDownFlag = false -- 可拖下阵
		self.m_view:switchBottomObjType()
		self:updateMsg("hide_multi_formation_btn")
	elseif msg == "pet_bottom_return" then
		local function ok_func()
			self.m_model.m_bottom_type = 0
			if SceneManager:getCurSceneView().SetCameraHeight then
				SceneManager:getCurSceneView():SetCameraHeight(self.m_model.m_bottom_type)
			end
			SceneManager:getCurSceneView().canDownFlag = false
			self.m_view:switchBottomObjType()
			self.m_view:setCloseText(true)
			self.m_model:setUnionWarTeam()
			self.m_view:refreshRedPoint()
			self.m_view:updateUnionWarSelectTeamTog()
			self.m_model.show_pet_bl = false
		end
		if self.m_model:checkPetSkillType() == false then
			local params =
			{
				on_ok_call = function(msg)
				
				end,
				new_cancel_call = function(msg)
					ok_func()
				end,
				tow_close_btn = true,
				ok_text = Language:getTextByKey("pet_evo_lv_0032"), 
				cancel_text = Language:getTextByKey("pet_evo_lv_0033"),
				text = Language:getTextByKey("pet_evo_lv_0034")
			}
			self:openView("Pops.CommonPop", params, nil, true)	
		else
			ok_func()
		end
	elseif msg == "click_suppress_btn" or msg == "left_diban_img" or msg == "right_diban_img" then
		self.m_view:setCombatSuppressFxUi(true)
		self.m_view:runBackAnim(handler(self,self.RunAnimEnd))
	elseif msg == "btn_revert" then
		self.m_model.is_current_leve_type = self.m_model.is_current_leve_type == 1 and 2 or 1
		self.m_view:UpdateRevertView()
	elseif msg == "refreshCombatSuppressTips" then
		self.m_view:resetCombatSuppressPos()
		self.m_view:setCombatSuppressFxUi()
	elseif msg=="update_lock_hero" then
		self.m_model.m_forbidden_hero_ids=data
		self.m_model.m_team_changed_flag = true
		local oid=nil
		for k,id in pairs(data)do
			oid=self.m_model:getHeroOidInMainTeam(id)
			if oid~=nil then
				self:goDownBattleByOid(oid)
				oid=nil
			end
		end
		self.m_model:updateTeam_ban()
		self.m_view:refreshZFLianSaiView()

	elseif msg=="endit_forbidden1" or msg=="endit_forbidden2" then
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ZF_ARENA_MUL then
			return
		end
		self:openView("Arena/ArenaPeak/ForbiddenHero",
				{lock_hero_data=self.m_model.m_forbidden_hero_ids,
				 main_team=self.m_model.main_team,
				 mult_main_teams=self.m_model.mult_main_teams,
				 ban_num=self.m_model.m_ban_num
				})
	elseif msg=="limit_icon" then
		local param={
			click_transform = self.m_view.limit_icon_trans,
			title=Language:getTextByKey(self.m_model.m_limit_cfg.rule_name),
			msg=Language:getTextByKey(self.m_model.m_limit_cfg.rule_desc)
		}
		GameUtil:lookInfoTips(self.m_control, param)

	elseif msg=="support_btn" then
		GameUtil:lookInfoTips(self,
				{click_transform =self.m_view.support_btn_trans, msg =Language:getTextByKey("supportSys_str_0007")})
	elseif msg=="recommend_btn" then
		self:openView("HeroBag.HeroTeamRecommendPop")
	end
end

function M:saveFormationTeam()
	local team = {}
	for i = 1, 5 do
		team[i]= self.m_model.main_team[i] or ""
	end
	local function callfunc()
		--if self.m_view.m_multi_formation_node then
		--	self.m_view.m_multi_formation_node:showFormationList()
		--end
		self:updateMsg("showFormationList", nil, "Formation.MultiFormation")

		self.m_view:updateMultiFormationBtnLoopScroll()
	end
	self.m_model:getNetData("hero_set_team",{type = "formation", index = self.m_model.m_sel_formation_index,team = team, deployment = self.m_model.m_atk_deployment}, callfunc,false,nil, GlobalConfig.POST)
end


function M:arrayingStoryPlayers( callbcak )
	if SceneManager:getCurSceneView() ~= nil then
		SceneManager:getCurSceneView():arrayingStoryPlayers(callbcak)
	end
end


function M:arrayingPlayers( callbcak )
	if SceneManager:getCurSceneModel() ~= nil then
		if self.m_model.m_def_data then
			self.m_model.m_def_data.formation_index = self.m_model.m_formation_index
		end
		local other_heros = self.m_model.m_other_heros
		local ext_data = {stage_id = self.m_model.m_stage_id,
						  battle_id = self.m_model.m_battle_id, 
						  race = self.m_model.m_race, 
						  formation_index = self.m_model.m_formation_index,
						  atk_deployment = self.m_model.m_atk_deployment or 1, 
						  def_deployment = self.m_model.m_def_deployment or 1, 
						  other_heros = other_heros, 
						  boss_pos = self.m_model.m_boss_pos, 
						  boss_size = self.m_model.m_boss_size,
						  m_pet = self.m_model:getCurPet(),
						  d_pet = self.m_model.m_def_pet,
						  fair = self.m_model.m_fair_fulwin, 
						  version = self.m_model.version,
						  open_id = self.m_model.open_id,
						  m_stage_cfg = self.m_model.m_cur_stage_cfg,} --仅限入梦铃
		SceneManager:getCurSceneModel():arraying_players(self.m_model.main_team, self.m_model.m_mode, self.m_model.m_def_data, self.m_model.m_assist_heros, self.m_model.m_legend_heros, ext_data,self.m_model.m_show_def_data, callbcak)
		self:updateDeployment()
	end
end

function M:arrayingLeftPlayers()
	for k,v in pairs(self.m_model.m_temp_main_team or {}) do
		if v and #v > 0 then
			self:sendState(v, k, false)
		end
	end
	local has_die_hero = false
	if self.m_model.main_team then
		for k,v in pairs(self.m_model.main_team) do
			if v and #v > 0 then
				if self.m_model:heroIsDie(v) then
					self.m_model.main_team[k] = ""
					has_die_hero = true
				else
					self:sendState(v, k, true)
				end
			end
		end
	end
	if has_die_hero then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0561"), delay_close = 2})
	end
	self:updateDeployment()
end

function M:updateDeployment()
	self.m_view:updateDeployment()
end

function M:changeMultTeam(index)
	if self.m_model:showUnionWarTeamsMultBtn() then
		self:changeUnionWarTeam(index)
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA_DEFENSE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA then
		local top_arena_races = self.m_model.m_top_arena_races or {}
		local races = GameUtil:getRacesByTopArenaRaceTeamIdx(index, top_arena_races)
		if next(races) ~= nil and self.m_model:CanInsertRace7(races) == true then --上元
			table.insert(races, 7)
		end
		if races then
			self.m_model.m_races = races
			self.m_view:refreshRacesIcon()
			self.m_view:updateRaceToggle()
		end
		self.m_model:changeMultTeamData(index)
		self:changeMultTeamRefresh()
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA_DEFENSE then
		local top_arena_races = self.m_model.m_top_arena_races or {}
		local races = top_arena_races[index]
		if next(races) ~= nil and self.m_model:CanInsertRace7(races) == true then --五行联赛第三队不能上元
			table.insert(races, 7)
		end
		if races then
			self.m_model.m_races = races
			self.m_view:refreshRacesIcon()
			self.m_view:updateRaceToggle()
		end
		self.m_model:changeMultTeamData(index)
		self:changeMultTeamRefresh()	
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI
	then
		self.m_model:changeMultTeamData(index)
		self.m_model:initStageBattleId()
		self:changeMultTeamRefresh()
		
	else
		self.m_model:changeMultTeamData(index)
		self:changeMultTeamRefresh()
		self.m_view:setEnemyBuffLv()
	end

end

function M:changeUnionWarTeam(index)
	if self.m_model:checkUnionTeamChange(index) == true then --切换页签检测当前队伍是否改变
		self.m_model:setUnionWarTeam() --保存改变
	end
	self.m_model:changeUnionWarTeamData(index)
	self:changeMultTeamRefresh()
end

function M:changeMultTeamRefresh()
	self:handle_arrayingPlayers()
	self.m_view:resetHeroCombat()
	self.m_view:refreshUI()
	self.m_view:updateBuffLv(self.m_model:getAddBuffLv(), false)
end

function M:changeMiningTeam(index)
	local races = GameUtil:getRacesByRegionId(index)
	if races then
		self.m_model.m_races = races
	end
	
	if self.m_model:checkMiningDefenseTeamChange(index) == true then --切换页签检测当前队伍是否改变
		self.m_model:seMiningDefenseTeam() --保存改变
	end
	self.m_model:changeMiningDefenseTeamData(index)
	self:handle_arrayingPlayers()
	self.m_view:resetHeroCombat()
	self.m_view:updateRaceToggle()
	self.m_view:refreshUI()
	self.m_view:updateBuffLv(self.m_model:getAddBuffLv(), false)
end

--设置上阵
function M:setGoInToBattle(data)
	local hero_id = data.heroid
	if self.m_model:inquireInTeams(hero_id) then --检查是否在队伍中
		--在队伍中-下阵
		local pos_key = self.m_model:removeTeams(hero_id)
		self.m_view:updateLoopScroll()
		self:sendState(hero_id, pos_key, false)
		audio:SendEvtUI("Play_UI_Hero_Down")
		self:updateMsg("refreshUI", nil, "Formation.MultiFormation")
		self.m_model.m_team_changed_flag = true
	else
		if not self:heroCanGoToBattle(hero_id) then
			return
		end
		--不在队伍中-可以上阵
 		if self.m_model:inquireVacancy(hero_id) then --检查空位
			if self.m_model:isUnionWarTeams() then
					self:addTeam(hero_id)
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MINING_DEFENSE then
				self:addTeam(hero_id)
			else
				self:addTeam(hero_id)
			end
		else
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0473"), delay_close = 2})
		end	
	end
	self.m_view:updateBuffLv(self.m_model:getAddBuffLv(), false)
end


function M:goDownBattleByOid(hero_id)
	if self.m_model:inquireInTeams(hero_id) then --检查是否在队伍中
		--在队伍中-下阵
		local pos_key = self.m_model:removeTeams(hero_id)
		--self.m_view:updateLoopScroll()
		self:sendState(hero_id, pos_key, false)
		audio:SendEvtUI("Play_UI_Hero_Down")
		self:updateMsg("refreshUI", nil, "Formation.MultiFormation")
	end
end

--设置宠物上阵
function M:setPetInToBattle(data)
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
		local pet_id = data
		if self.m_model:inquireInTeams(pet_id) then --检查是否在队伍中
			--在队伍中-下阵
			local pos_key = self.m_model:removeTeams(pet_id)
			self.m_view:updateLoopScroll()
			self:sendState(pet_id, pos_key, false)
			audio:SendEvtUI("Play_UI_Hero_Down")
			self:updateMsg("refreshUI", nil, "Formation.MultiFormation")
			self.m_model.m_team_changed_flag = true
		else
			if not self:petCanGoToBattle(pet_id) then
				return
			end
			--不在队伍中-可以上阵
			 if self.m_model:inquireVacancy(pet_id) then --检查空位
				self:addTeam(pet_id)
			else
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("petard_text_0029"), delay_close = 2})
			end	
		end
		self.m_view:updateBuffLv(self.m_model:getAddBuffLv(), false)
	else	
		local cur_pet = self.m_model:getCurPet()
		if cur_pet ~= 0 and cur_pet ~= "" then --位置上有宠物
			if cur_pet == data then--在队伍中-下阵
				self.m_model:removePetInTeam(data)
				self:sendState(data,1, false,true)
			end
		else --位置上没有宠物
			if self.m_model:checkPetIsInTeam(data) == false then
				self.m_model:addPetInTeam(data)
				self:sendState(data,1, true,true)
			end
		end
	end
	self.m_model.m_team_changed_flag = true
	self.m_view:updatePetLoopScroll()
	self.m_view:refreshUI()
end


function M:petCanGoToBattle(pet_id)
	--检查是否有同名宠物
	if self.m_model:checkPetIsInTeamByPetDouji(pet_id) then
		GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("petard_text_0028"), delay_close = 2})
		return false
	end
	return true
end


function M:heroCanGoToBattle(hero_id)
	local is_die = self.m_model:heroIsDie(hero_id)
	if is_die then
		GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0352"), delay_close = 2})
		return false
	end

	if self.m_model:inquireApostleTimes(hero_id) then
		GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0353"), delay_close = 2})
		return false
	end

	--检查是否有同名英雄
	if self.m_model:checkIsInTeam(hero_id) then
		GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0251"), delay_close = 2})
		return false
	end

	if self.m_model:checkJobIsInTeam(hero_id) then
		GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_1140"), delay_close = 2})
		return false
	end

	if self.m_model:inquireApostleInTeam(hero_id) then
		GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0354"), delay_close = 2})
		return false
	end

	if (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT) and self.m_model:inquireApostleInMultTeam(hero_id) then
		GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0354"), delay_close = 2})
		return false
	end
	
	--种族塔英雄数量检测
	if self.m_model:checkIsCanInToUp() == false then
		GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("budo_str_009"), delay_close = 2})
		return false
	end
	
	--奇门遁甲检查是否在打扫战场
	if self.m_model:checkIsLockHids(hero_id) then
		GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("fb_str_0035"), delay_close = 2})
		return false
	end
	
	-- 英雄的职业是否被禁用
	if self.m_model:checkIsLockJob(hero_id) then
		GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("fylt_str_0089"), delay_close = 2})
		return false
	end

	--已经参与助战系统的英雄不能上阵
	if self.m_model:checkIsInSupport(hero_id) then
		GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("supportSys_str_0005"), delay_close = 2})
		return false
	end

	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WD_TOWER then
		local can_use, race_key, limit_num = self.m_model:checkRaceNumsByHeroId(hero_id)
		if can_use == false then
			local race_text = Language:getTextByKey(GlobalConfig.TYPE_HERO_RACE[race_key].name)
			if race_key == 7 then
				GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("huashan_sword_text0015", race_text, limit_num), delay_close = 2})
			else
				GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("wdtower_text_0003", race_text, limit_num), delay_close = 2})
			end
			return false
		end
		return true
	end 
	return true
end

function M:addTeam(hero_id)
	local pos_key = self.m_model:addTeams(hero_id)
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
		self.m_view:updatePetLoopScroll()
		self:sendState(hero_id, pos_key, true)
	else
		self.m_view:updateLoopScroll()
		self:sendState(hero_id, pos_key, true)
		self.m_view:updatePlayShangZhenEffect(hero_id)
	end
	audio:SendEvtUI("Play_UI_Hero_Up")
	self:updateMsg("refreshUI", nil, "Formation.MultiFormation")
	self.m_model.m_team_changed_flag = true
end

function M:removeAllHero()
	self.m_model:removeAll()
	self:handle_arrayingPlayers()
	self.m_view:updateAllState()
	self.m_view:updateBuffLv(self.m_model:getAddBuffLv(), false)
end

--
function M:sendState(heroid, heroPos, isAdd, is_pet)
	if SceneManager:getCurSceneView() ~= nil then
		self.m_view:lockTouch("go_in_or_out_battle")
		SceneManager:getCurSceneView():go_in_or_out_battle(heroid, heroPos, isAdd, is_pet ,function()
			if self.m_view then
				self.m_view:unlockTouch("go_in_or_out_battle")
				--self:updateFootEffect()
			end
		end)
	end
end




function M:updateFootEffect()
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
		for i = 0, SceneManager.curScene.plyMgr.hero_list.Count - 1 do
			local c_player = SceneManager.curScene.plyMgr.hero_list:get(i)
			local cfg = UserDataManager.hero_data:getHeroConfigByCid(c_player.heroData.id) 
			local bl = self.m_model:isAdditionRace(cfg.race)
			if c_player.footUI then
				c_player.footUI:UpdateEffect(bl)
			end
		end
	end
end

function M:sendData()
	local team = {}
	for i = 1, 5 do
		team[i]= self.m_model.main_team[i] or ""
	end
	local function callfunc()
		self:getBattleStart()
	end
	self.m_model:getNetData("hero_set_team",{type = "main", index = 0,team = team}, callfunc,false,nil, GlobalConfig.POST)	
end

function M:updatePlayerPostion( data )
	
end


function M:getBattleStart()
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER and self.m_model:getRaceTowerAttackNum() == false then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0773"), delay_close = 2})
		return
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNIONWAR then  --帮会战没有模拟战次数
		local issim = UserDataManager.local_data:getUserDataByKey("simulated_battle_flag", false)
		if self.m_model.m_params.gvg_data.remain_mock_times  <= 0 and issim then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("UnionWar_str_101"), delay_close = 2})
			return
		end

	elseif (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO) and self.m_model:getXiaKeDaoLoseNum() then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_1134"), delay_close = 2})
		return
	end
	local function endCallback()
		if self.m_model.m_mult_team_flag and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.UNIONWAR and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR then
			self:getMultBattleStart()
		else
			self:getOneBattleStart()
		end
	end
	local is_not_full_mult_team, not_full_index = self.m_model:inquireVacancyMultTeam()
	if (self.m_model:inquireVacancyMultTeam() and self.m_model.m_mult_team_flag ) or self.m_model:isHaveInToHero() == true and not self.m_model:isUnionWarTeams() and self.m_model:needFormationTipsFlag() then
		local text_str =  Language:getTextByKey("mult_stage_text004", not_full_index)
		if is_not_full_mult_team and not_full_index then
			local team_index_str =  Language:getTextByKey("num_str_000" .. not_full_index) 
			text_str =  Language:getTextByKey("mult_stage_text004", team_index_str)
		else
			text_str =  Language:getTextByKey("new_str_0621")
		end
		local params =
		{
			on_ok_call = function(msg)
				self:updateMsg("buzhen_btn")
			end,
			new_cancel_call = function(msg)
				endCallback()
			end,
			tow_close_btn = true,
			ok_text = Language:getTextByKey("game_panel_4"), 
			cancel_text = Language:getTextByKey("game_panel_1"),
			text = text_str
		}
		self:openView("Pops.CommonPop", params, nil, true)	
	else
		endCallback()
	end
end

function M:getOneBattleStart()
	local can_battle = false
	local full_apostle = true
	local team = {}
	for i = 1, 5 do
		team[i]= self.m_model.main_team[i] or ""
		if team[i] ~= "" then
			local hero_data = self.m_model:getHero(team[i])
			if not hero_data.apostle_flag and not hero_data.mastor_apostle_flag and not hero_data.novice_apostle_flag then
				full_apostle = false
			end
			can_battle = true
		end
	end

	if not self.m_model:isUnionWarTeams() then
		if not can_battle then
			self:updateMsg("buzhen_btn")
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0152"), delay_close = 2})
			return
		end
		if full_apostle then
			self:updateMsg("buzhen_btn")
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0636"), delay_close = 2})
			return
		end
	end
	
	local function callfunc(response)
		if response.update then
			if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE then
				self:updateMsg("update_data", response, "Activities.WorldBoss.HeroBossTrainPop")
				GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA then
				self:updateMsg("refresh_ui", response, "Arena.ArenaHigher.ArenaHigherChallenge")
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0895"), delay_close = 2})
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD then
				self:updateMsg("refresh_ui", response, "HuashanSword.HuashanSwordChallenge")
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0895"), delay_close = 2})
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LEGEND then
				self:updateMsg("refresh_data", response, "Legend")
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
			end
			self:closeView()
			return
		end
		if response["end"] then
			if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY then
				self:updateMsg("update_data", response, "Fivelines")
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW then
				self:updateMsg("update_data", response, "EvilShadow.EvilShadowBattle")
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD then
				self:updateMsg("update_data", response, "Dragonsword.DragonswordBattle")
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS then
				self:updateMsg("update_data", response, "ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsBattle")
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE then
				self:updateMsg("update_data", response, "Chivalry.ChivalryBattle")
			end
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
			self:closeView()
			return
		end
		if self.m_model:showFormationSkipBtn() and self.m_model.m_formation_skip_battle == 1 then -- 跳过战斗
			self:openView("Settlement", { result = response.result, mode = self.m_model.m_mode, battle_data = response, skip_battle = 1})
			self:closeView()
			return
		end
		local params = {
			data = response,
			battle_config_id = self.m_model.m_params.battle_config_id,
			mode = self.m_model.m_mode,
			reward = response.rewards_list,
			boss_hp =  self.m_model.boss_hp,
			battle_id = self.m_model.m_battle_id,
			boss_id = self.m_model.m_boss_id,
			floor = self.m_model.m_floor,
			five_pos = self.m_model.m_five_pos,
			bio_id = self.m_model.m_bio_id,
			chapter_id = self.m_model.m_chapter_id,
			stage_id = self.m_model.m_stage_id,
			battle_type = self.m_model.m_params.type,
			node_id =  self.m_model.node_id,
			race = self.m_model.m_race,
			version = self.m_model.version,
			m_server_hp_coef = self.m_model.m_server_hp_coef,
			m_server_dps_coef = self.m_model.m_server_dps_coef,
			raid_sort = self.m_model.m_raid_sort,
			--是否是奇遇
			m_type = self.m_model.m_params.type,
			legend_data = self.m_model.m_params.legend_data,
			budo_floor = self.m_model.m_budo_floor,
			m_boss_max_hp = self.m_model.m_boss_max_hp,
			m_boss_hp_cid = self.m_model.m_boss_hp_cid,
			m_formation_index = self.m_model.m_formation_index,
			region_id = self.m_model.m_params.region_id,
			legend_heros = self.m_model.m_legend_heros,
			cell_id = self.m_model.m_params.cell_id,
			star = self.m_model.m_params.star,
			races = self.m_model.m_races,
			lock_hids = self.m_model.m_lock_hids,
			wall_coef = self.m_model.m_params.wall_coef,
			combat_gve_battle = self.m_model.m_combat_gve_battle,
			difficulty_reduce = self.m_model.m_difficulty_reduce,
			boss_max_hp = self.m_model.m_boss_max_hp,
			gve_version = self.m_model.m_gve_version,
			def_data = self.m_model.m_def_data,
			raccon_hero_id = self.m_model.m_raccon_hero_id,
			open_id = self.m_model.open_id,
			special_open_id = self.m_model.m_special_open_id,
			special_version = self.m_model.m_special_version,
			cur_stage_cfg = self.m_model.m_cur_stage_cfg ,
			layer=self.m_model.m_layer,
			--剑出鸿蒙
			rta_wendaoBNum=self.m_model.m_wendaoBNum,
			rta_score=self.m_model.m_rta_score,
			rta_preScore=self.m_model.m_preScore,
			rta_result=self.m_model.m_rta_result,
		}
		if (self.m_model.m_mode ==  GlobalConfig.BATTLE_MODE.MAZE or self.m_model.m_mode ==  GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE) and self.m_model.m_params.def_data then
			params.maze_type = self.m_model.m_params.def_data.type
		end
		self:closeView("Settlement")
		self:openView("GamePanel", params)
		self:closeView()
	end
	local mode_util_item = BattleModeUtil[self.m_model.m_mode]
	if mode_util_item and mode_util_item.formationControl then
		mode_util_item.formationControl(self, team, callfunc)
	else
		Logger.logError(self.mode, "getOneBattleStart mode is error : ")
	end
end

function M:callFunc(response)
	if response.update then
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE then
			self:updateMsg("update_data", response, "Activities.WorldBoss.HeroBossTrainPop")
			GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA then
			self:updateMsg("refresh_ui", response, "Arena.ArenaHigher.ArenaHigherChallenge")
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0895"), delay_close = 2})
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD then
			self:updateMsg("refresh_ui", response, "HuashanSword.HuashanSwordChallenge")
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0895"), delay_close = 2})
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LEGEND then
			self:updateMsg("refresh_data", response, "Legend")
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
		end
		self:closeView()
		return
	end
	if response["end"] then
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY then
			self:updateMsg("update_data", response, "Fivelines")
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW then
			self:updateMsg("update_data", response, "EvilShadow.EvilShadowBattle")
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD then
			self:updateMsg("update_data", response, "Dragonsword.DragonswordBattle")
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS then
			self:updateMsg("update_data", response, "ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsBattle")
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE then
			self:updateMsg("update_data", response, "Chivalry.ChivalryBattle")
		end
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
		self:closeView()
		return
	end
	if self.m_model:showFormationSkipBtn() and self.m_model.m_formation_skip_battle == 1 then -- 跳过战斗
		self:openView("Settlement", { result = response.result, mode = self.m_model.m_mode, battle_data = response, skip_battle = 1})
		self:closeView()
		return
	end
	local params = {
		data = response,
		battle_config_id = self.m_model.m_params.battle_config_id,
		mode = self.m_model.m_mode,
		reward = response.rewards_list,
		boss_hp =  self.m_model.boss_hp,
		battle_id = self.m_model.m_battle_id,
		boss_id = self.m_model.m_boss_id,
		floor = self.m_model.m_floor,
		five_pos = self.m_model.m_five_pos,
		bio_id = self.m_model.m_bio_id,
		chapter_id = self.m_model.m_chapter_id,
		stage_id = self.m_model.m_stage_id,
		battle_type = self.m_model.m_params.type,
		node_id =  self.m_model.node_id,
		race = self.m_model.m_race,
		version = self.m_model.version,
		m_server_hp_coef = self.m_model.m_server_hp_coef,
		m_server_dps_coef = self.m_model.m_server_dps_coef,
		raid_sort = self.m_model.m_raid_sort,
		--是否是奇遇
		m_type = self.m_model.m_params.type,
		legend_data = self.m_model.m_params.legend_data,
		budo_floor = self.m_model.m_budo_floor,
		m_boss_max_hp = self.m_model.m_boss_max_hp,
		m_boss_hp_cid = self.m_model.m_boss_hp_cid,
		m_formation_index = self.m_model.m_formation_index,
		region_id = self.m_model.m_params.region_id,
		legend_heros = self.m_model.m_legend_heros,
		cell_id = self.m_model.m_params.cell_id,
		star = self.m_model.m_params.star,
		races = self.m_model.m_races,
		lock_hids = self.m_model.m_lock_hids,
		wall_coef = self.m_model.m_params.wall_coef,
		combat_gve_battle = self.m_model.m_combat_gve_battle,
		difficulty_reduce = self.m_model.m_difficulty_reduce,
		boss_max_hp = self.m_model.m_boss_max_hp,
		gve_version = self.m_model.m_gve_version,
		def_data = self.m_model.m_def_data,
		raccon_hero_id = self.m_model.m_raccon_hero_id,
		open_id = self.m_model.open_id,
		special_open_id = self.m_model.m_special_open_id,
		special_version = self.m_model.m_special_version,
		cur_stage_cfg = self.m_model.m_cur_stage_cfg ,
		layer=self.m_model.m_layer
	}
	if (self.m_model.m_mode ==  GlobalConfig.BATTLE_MODE.MAZE or self.m_model.m_mode ==  GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE) and self.m_model.m_params.def_data then
		params.maze_type = self.m_model.m_params.def_data.type
	end
	self:closeView("Settlement")
	self:openView("GamePanel", params)
	self:closeView()
end

function M:getMultBattleStart()
	local teams, can_set = self.m_model:getMultTeamParam()
	local deployments = {}
	if not can_set then
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mult_stage_text005"), delay_close = 2})
		else
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0244"), delay_close = 2})
		end
		return
	end
	local requested=false
	local function callfunc(response)
		requested=false
		-- self:updateMsg("battle",{data = response, mode = self.m_model.m_mode},"parent")
		if self.m_model:showFormationSkipBtn() and self.m_model.m_formation_skip_battle == 1 then -- 跳过战斗
			self:openView("Settlement", { result = response.result, mode = self.m_model.m_mode, battle_data = response, skip_battle = 1})
			self:closeView()
			return
		end

		self:openView("GamePanel", {data = response, mode = self.m_model.m_mode, battle_id_tab = self.m_model.m_battle_id_tab, stage_id = self.m_model.m_stage_id,team_nums=self.m_model.m_team_nums})
		self:closeView()
	end

	local mode_util_item = BattleModeUtil[self.m_model.m_mode]
	if mode_util_item and mode_util_item.formationControl then
		if not requested then
			requested=true
			mode_util_item.formationControl(self, teams, callfunc, deployments)
		end
	else
		Logger.logError(self.mode, "getMultBattleStart mode is error : ")
	end
end

--通用
function M:saveFormation()
	if self.m_model.m_formation_id > 0 then
		local can_set = false
		local team = {}
		for i = 1, 5 do
			team[i]= self.m_model.main_team[i] or ""
			if team[i] ~= "" then
				can_set = true
			end
		end
		if not can_set then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0244"), delay_close = 2})
			return
		end
		local function callfunc()
			self.m_view:setCloseText(true)
			self:updateMsg("team_edit_cancel_btn", {set_team_success = true})
		end
		local params = {
			type = "formation", index = self.m_model.m_formation_id,team = team, deployment = self.m_model.m_atk_deployment
		}
		if self.m_model.m_mult_team_flag == true then
			params.relics = self.m_model.m_mult_solts
		else
			params.relic = self.m_model.m_solts
		end
		if self.m_model.m_mult_team_flag == true then
			params.battle_pet = self.m_model.m_battle_pet
		else
			params.battle_pets = self.m_model.m_mult_battle_pets
		end
		self.m_model:getNetData("hero_set_team",params, callfunc,false,nil, GlobalConfig.POST)
	else
		local util_item = BattleModeUtil[self.m_model.m_mode]
		if util_item and util_item.formationControlSaveTeam then
			util_item.formationControlSaveTeam(self)
		else
			self:updateMsg("bottom_return")
		end
	end
end

---- 种族竞技场防守阵容
function M:raceArenaSetDefendTeam()
	local can_set = false
	local team = {}
	for i = 1, 5 do
		team[i]= self.m_model.main_team[i] or ""
		if team[i] ~= "" then
			can_set = true
		end
	end
	if not can_set then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0244"), delay_close = 2})
		return
	end
	local function callfunc()
		self.m_model.m_team_changed_flag = false
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		self:updateMsg(99999)
		self:updateMsg("refresh_ui", nil, "Arena.ArenaRace.ArenaRace")
	end
	self.m_model:getNetData("race_arena_set_defend_team",{team = team,relic = self.m_model.m_solts, battle_pet = self.m_model.m_battle_pet, normal_array = self.m_model.m_normal_array, deployment = self.m_model.m_atk_deployment}, callfunc,false,nil, GlobalConfig.POST)
end

---- 竞技场防守阵容
function M:arenaSetDefendTeam()
	local can_set = false
	local team = {}
	for i = 1, 5 do
		team[i]= self.m_model.main_team[i] or ""
		if team[i] ~= "" then
			can_set = true
		end
	end
	if not can_set then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0244"), delay_close = 2})
		return
	end
	local function callfunc()
		self.m_model.m_team_changed_flag = false
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		self:updateMsg(99999)
		self:updateMsg("refresh_ui", nil, "Arena.ArenaNormal.ArenaNormal")
	end
	self.m_model:getNetData("arena_set_defend_team",{team = team,relic = self.m_model.m_solts, battle_pet = self.m_model.m_battle_pet ,normal_array = self.m_model.m_normal_array, deployment = self.m_model.m_atk_deployment}, callfunc,false,nil, GlobalConfig.POST)	
end

-- teams: {1: [hero_oid], 2: [hero_oid], 3: [hero_oid]}
-- 高阶竞技场防守阵容 多队伍
function M:highArenaSetDefendTeams()
	local teams, can_set, deployments = self.m_model:getMultTeamParam()
	if not can_set then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0934"), delay_close = 2})
		return
	end
	local function callfunc()
		self.m_model.m_team_changed_flag = false
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		self:updateMsg("refresh_ui", nil, "Arena.ArenaHigher.ArenaHigherDefendTeam")
		self:updateMsg(99999)
	end
	self.m_model:getNetData("high_arena_set_defend_teams",{teams = teams, battle_pets = self.m_model.m_mult_battle_pets, normal_arrays = self.m_model.m_mult_normal_array, relics = self.m_model.m_mult_solts , deployments = deployments}, callfunc,false,nil, GlobalConfig.POST)	
end

function M:mythArenaSetDefendTeams()
	local teams, can_set, deployments = self.m_model:getMultTeamParam()
	if not can_set then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0934"), delay_close = 2})
		return
	end
	local function callfunc()
		self.m_model.m_team_changed_flag = false
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		self:updateMsg("refresh_ui", nil, "MythArena.MythArenaDefendTeamPop")
		self:updateMsg(99999)
	end
	self.m_model:getNetData("myth_arena_set_defend_teams",{teams = teams, battle_pets = self.m_model.m_mult_battle_pets, relics = self.m_model.m_mult_solts ,normal_arrays = self.m_model.m_mult_normal_array, deployments = deployments}, callfunc,false,nil, GlobalConfig.POST)
end

--剑试天下 积分赛防守阵容
function M:setCompareSwordDefendTeams()
	local teams, can_set, deployments = self.m_model:getMultTeamParam()
	if not can_set then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0934"), delay_close = 2})
		return
	end
	local function callfunc()
		self.m_model.m_team_changed_flag = false
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		self:updateMsg("refresh_ui", nil, "CompareSwordWithWorld.CompareSwordDefendTeam")
		self:updateMsg(99999)
	end
	local deployments = {}
	for i = 1,self.m_model.m_team_nums do
		table.insert(deployments,1)
	end
	self.m_model:getNetData("full_service_set_defend_teams",{typ = self.m_model.m_race_type ,teams = teams, battle_pets = self.m_model.m_mult_battle_pets, normal_arrays = self.m_model.m_mult_normal_array, relics = self.m_model.m_mult_solts , deployments = deployments}, callfunc,false,nil, GlobalConfig.POST)
end


-- 华山论剑防守阵容 多队伍
function M:huashanSetDefendTeams()
	local teams, can_set, deployments = self.m_model:getMultTeamParam()
	if not can_set then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0934"), delay_close = 2})
		return
	end
	local function callfunc()
		self.m_model.m_team_changed_flag = false
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		self:updateMsg("refresh_ui", nil, "HuashanSword.HuashanSwordDefendTeam")
		self:updateMsg(99999)
	end
	self.m_model:getNetData("arena_mountain_hua_set_defend_teams",{teams = teams,battle_pets = self.m_model.m_mult_battle_pets, relics = self.m_model.m_mult_solts ,normal_arrays = self.m_model.m_mult_normal_array, deployments = deployments}, callfunc,false,nil, GlobalConfig.POST)
end

-- teams: {1: [hero_oid], 2: [hero_oid], 3: [hero_oid]}
-- 天级赛防守阵容 多队伍
function M:topArenaRaceSetDefendTeams()
	local teams, can_set, deployments = self.m_model:getMultTeamParam()
	if not can_set then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0934"), delay_close = 2})
		return
	end
	local function callfunc()
		self.m_model.m_team_changed_flag = false
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		self:updateMsg("refresh_ui", nil, "Arena.ArenaRace.ArenaTopDefendTeam")
		self:updateMsg(99999)
	end
	self.m_model:getNetData("race_arena_set_defend_team",{teams = teams,battle_pets = self.m_model.m_mult_battle_pets, relics = self.m_model.m_mult_solts ,normal_arrays = self.m_model.m_mult_normal_array, deployments = deployments}, callfunc,false,nil, GlobalConfig.POST)
end

--争锋联赛防守阵容，多队伍
function M:zfArenaDefendTeams()
	local teams, can_set, deployments = self.m_model:getMultTeamParam()
	if not can_set then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0934"), delay_close = 2})
		return
	end
	local function callfunc()
		self.m_model.m_team_changed_flag = false
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		self:updateMsg("refresh_ui", nil, "Arena.ArenaHigher.ArenaHigherDefendTeam")
		self:updateMsg(99999)
	end
	self.m_model:getNetData("rise_arena_set_defends",
			{teams = teams,relics = self.m_model.m_mult_solts , deployments = deployments},
			callfunc,false,nil, GlobalConfig.POST)
end

-- teams: {1: [hero_oid], 2: [hero_oid], 3: [hero_oid]}
-- 五行联赛防守阵容 多队伍
function M:fiveArenaRaceSetDefendTeams()
	local teams, can_set, deployments = self.m_model:getMultTeamParam()
	if not can_set then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0934"), delay_close = 2})
		return
	end
	local function callfunc()
		self.m_model.m_team_changed_flag = false
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		self:updateMsg("refresh_ui", nil, "Arena.ArenaRace.ArenaTopDefendTeam")
		self:updateMsg(99999)
	end
	self.m_model:getNetData("race_arena_season_set_defend_team",{teams = teams, battle_pets = self.m_model.m_mult_battle_pets,relics = self.m_model.m_mult_solts ,normal_arrays = self.m_model.m_mult_normal_array, deployments = deployments}, callfunc,false,nil, GlobalConfig.POST)
end

-- 巅峰论剑阵容 多队伍
function M:topArenaSetDefendTeams()
	local teams, can_set, deployments = self.m_model:getMultTeamParam()
	if not can_set then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0934"), delay_close = 2})
		return
	end
	local function callfunc()
		self.m_model.m_team_changed_flag = false
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		self:updateMsg("refresh_ui", nil, "Arena.ArenaHigher.ArenaHigherDefendTeam")
		self:updateMsg(99999)
	end
	self.m_model:getNetData("top_arena_set_teams",{teams = teams, battle_pets = self.m_model.m_mult_battle_pets, relics = self.m_model.m_mult_solts, normal_arrays = self.m_model.m_mult_normal_array,deployments = deployments}, callfunc,false,nil, GlobalConfig.POST)	
end
-- 巅峰公会战 多队伍
function M:guildHighWarSetDefendTeams()
	local teams, can_set = self.m_model:getMultTeamParam()
	local ghw_teams = {}
	for i = 1, 5 do
		ghw_teams[tostring(i)] = teams[i] or {}
	end
	local deployments = {}
	if not can_set then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0934"), delay_close = 2})
		return
	end
	local function callfunc(response)
		UserDataManager:setGuildHighWarTeams(response.teams)
		self.m_model.m_team_changed_flag = false
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		self:updateMsg("refresh_ui", nil, "UnionWar")
		self:updateMsg("refresh_data", nil, "GuildHighWar.GuildHighWarBattleTeamPop")
		self:updateMsg("refresh_data", nil, "GuildHighWar.GuildHighWarTeamPop")
		self:updateMsg(99999)
	end
	self.m_model:getNetData("guild_high_war_set_formation",{teams = ghw_teams, relics = self.m_model.m_mult_solts, deployments = deployments}, callfunc,false,nil, GlobalConfig.POST)
end

--推图
function M:stageSetTeam()
	local can_set = false
	local team = {}
	for i = 1, 5 do
		team[i]= self.m_model.main_team[i] or ""
		if team[i] ~= "" then
			can_set = true
		end
	end
	if not can_set then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0487"), delay_close = 2})
		return
	end
	local function callfunc()
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		self:updateMsg(99999)
	end
	self.m_model:getNetData("hero_set_team",{type = "stage", battle_pet = self.m_model.m_battle_pet, relic = self.m_model.m_solts, index = 0,team = team, normal_array = self.m_model.m_normal_array, deployment = self.m_model.m_atk_deployment}, callfunc,false,nil, GlobalConfig.POST)
end

function M:openEditFormationName(data)
	local params =
	{
		on_ok_call = function(msg)
			self:heroFormationName(data.index, msg)
		end,
		tips = Language:getTextByKey("new_str_0539"),
		title = Language:getTextByKey("new_str_0539"),
		placeholder = Language:getTextByKey("new_str_0540"),
		text = "",
		character_limit = 3,
	}
	self:openView("Pops.CommonInputPop", params)
end

function M:heroFormationName(index, name)
	local function callfunc(response, tag, status_code)
		if response then
			self:updateMsg("refreshUI", nil, "Formation.MultiFormation")

			--if self.m_view.m_multi_formation_node then
			--	self.m_view.m_multi_formation_node:refreshUI()
			--end
			self.m_view:updateMultiFormationBtnLoopScroll()
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0538"), delay_close = 2})
		else
			if status_code == GlobalConfig.SENSITIVE_WORDS_CODE then
				self:updateMsg("reset_input_text", nil, "Pops.CommonInputPop")
			end
		end
	end
	self.m_model:getNetData("hero_formation_name",{name = name, index = index}, callfunc, nil, true)
end

function M:refreshHelperUI(eventName, data)
	self.m_view:refreshHelperUI(data.player)
end

function M:requestSaveUnionWarTeam(callback)
	local params = {}
	local teams = {}
	for idx = 1, 3 do
		local tmpTeam = {}
		if idx == self.m_model.m_formation_index then
			tmpTeam = self.m_model.main_team
		elseif self.m_model.union_war_teams[tostring(idx)] ~= nil then
			tmpTeam = self.m_model.union_war_teams[tostring(idx)].team
		end
		teams[tostring(idx)] = tmpTeam
	end
	params.teams = teams
	params.relics = self.m_model.m_mult_solts
	local normal_arrays = {}
	for k,v in pairs(self.m_model.m_mult_normal_array) do
		normal_arrays[tostring(k)] = v
	end
	params.normal_arrays = normal_arrays
	params.battle_pets = self.m_model.m_mult_battle_pets
	local function unionwar_callfunc(response, tag, status_code)
		if response then
			self.m_model.m_team_changed_flag = false
			if callback then
				callback()
			else
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("UnionWar_str_018"), delay_close = 2})
				self:updateMsg(99999)
			end
			UserDataManager:setGvgTeamSetReward(response.reward)
		else
			status_code = tostring(status_code)
			if status_code == "39015" or status_code == "39019" then
				self.m_model.m_team_changed_flag = false
				if callback then
					callback()
				else
					self:updateMsg(99999)
				end
			end
		end
	end
	local battle_mode_cfg_item = GlobalConfig.BATTLE_MODE_CFG[self.m_model.m_mode] or {}
	local url_key = battle_mode_cfg_item.save_url_key
	if url_key then
		self.m_model:getNetData(url_key, params, unionwar_callfunc, false, true, GlobalConfig.POST)
	else
		Logger.logErrorAlways(self.m_model.m_mode, "requestSaveUnionWarTeam url is null ")
	end
end
-- teams: {1: [hero_oid], 2: [hero_oid], 3: [hero_oid]}
function M:miningSetDefendTeams()
	local teams, can_set, deployments = self.m_model:getMultTeamParam()
	if not can_set then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0934"), delay_close = 2})
		return
	end
	local function callfunc()
		self.m_model.m_team_changed_flag = false
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		self:updateMsg("refresh_ui", nil, "HuntTreasures.HuntTreasuresMyTeamPop")
		self:updateMsg(99999)
	end
	self.m_model:getNetData("mining_set_defend_team",{teams = teams,normal_array = self.m_model.m_normal_array, battle_pets = self.m_model.m_mult_battle_pets, relics = self.m_model.m_mult_solts, deployments = deployments}, callfunc,false,nil, GlobalConfig.POST)
end

function M:requestSaveMiningDefenseTeam()
	local params = {}
	local teams = {}
	-- for idx = 1, 4 do
	-- 	local tmpTeam = {}
	-- 	if idx == self.m_model.m_formation_index then
	-- 		tmpTeam = self.m_model.main_team
	-- 	elseif self.m_model.mining_defense_teams[idx] ~= nil then
	-- 		tmpTeam = self.m_model.mining_defense_teams[idx]
	-- 	end
	-- 	teams[idx] = tmpTeam
	-- end
	params.team = self.m_model.main_team
	params.relic = self.m_model.m_solts
	params.battle_pet = self.m_model.m_battle_pet
	params.team_id = self.m_model.m_formation_index
	local function mining_defense_callfunc(response)
		self.m_model.m_team_changed_flag = false
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		self:updateMsg("refresh_ui", nil, "HuntTreasures.HuntTreasuresMyTeamPop")
		self:updateMsg(99999)
	end
	self.m_model:getNetData("mining_set_defend_team", params, mining_defense_callfunc, false, nil, GlobalConfig.POST)
end

function M:requestSaveActiveMiningDefenseTeam()
	local ver = UserDataManager.local_data:getLocalDataByKey("HuntTreasuresGuildVersion", 1) -- 存贮活动版本号
	local params = {}
	local teams = {}
	-- for idx = 1, 4 do
	-- 	local tmpTeam = {}
	-- 	if idx == self.m_model.m_formation_index then
	-- 		tmpTeam = self.m_model.main_team
	-- 	elseif self.m_model.mining_defense_teams[idx] ~= nil then
	-- 		tmpTeam = self.m_model.mining_defense_teams[idx]
	-- 	end
	-- 	teams[idx] = tmpTeam
	-- end
	params.ver = ver
	params.team = self.m_model.main_team
	params.relic = self.m_model.m_solts
	params.battle_pet = self.m_model.m_battle_pet
	params.team_id = self.m_model.m_formation_index
	local function mining_defense_callfunc(response)
		self.m_model.m_team_changed_flag = false
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		self:updateMsg("refresh_ui", nil, "HuntTreasuresGuild.HuntTreasuresGuildMyTeamPop")
		self:updateMsg(99999)
	end
	self.m_model:getNetData("active_mining_set_defend_team", params, mining_defense_callfunc, false, nil, GlobalConfig.POST)
end

function M:cancelSaveUnionWarTeam()
	for k,v in pairs(self.m_model.main_team) do
		if v and #v > 0 then
			self:sendState(v, k, false)
		end
	end
	self.m_model.main_team = table.copy(self.m_model.temp_team)
	for k,v in pairs(self.m_model.main_team) do
		if v and #v > 0 then
			self:sendState(v, k, true)
		end
	end	
	self.m_view:updateLoopScroll()
end

--上阵遗物
function M:useWeapon(data)
	if self.m_model.m_mult_team_flag == true and self.m_model.m_mult_solts then
		local cur_id = self.m_model:getMultDressedWeaByIndex(data.index)
		if cur_id == data.wea_id then
			self.m_view:hideSelectType()
			return
		end
		if self.m_model.m_mult_solts[self.m_model.m_formation_index] == nil then
			self.m_model.m_mult_solts[self.m_model.m_formation_index] = {}
		end
		self.m_model.m_team_changed_flag = true
		self.m_model:replaceMultWea(data.wea_id)
		self.m_model.m_mult_solts[self.m_model.m_formation_index][tostring(data.index)] = data.wea_id
	else
		local cur_id = self.m_model:getDressedWeaByIndex(data.index)
		if cur_id == data.wea_id then
			self.m_view:hideSelectType()
			return
		end
		self.m_model.m_solts[tostring(data.index)] = data.wea_id
	end
	self.m_view:resetHeroCombat()
	self.m_view:hideSelectType()
end

-- teams: {1: [hero_oid], 2: [hero_oid], 3: [hero_oid]}
-- 风云擂台防守 team_type一队 或 三队
-- set_type 0防守阵容，1攻击阵容
function M:fulwinArenaSetDefendTeams(team_type)
	local function callfunc()
		self.m_model.m_team_changed_flag = false
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		self:updateMsg("refresh_ui", nil, "FulwinArena.FulwinArenaMain")
		self:updateMsg(99999)
	end
	local set_type = self.m_model.m_params.edit_team or 0
	local teams, can_set, deployments = nil
	if team_type == 1 then
		teams = self.m_model.main_team
		if type(self.m_model.m_atk_deployment) == "number" then
			deployments = self.m_model.m_atk_deployment == 0 and 1 or self.m_model.m_atk_deployment
		else
			deployments = 1
		end
		self.m_model:getNetData("friend_arena_set_defend_teams",{normal_arrays = {self.m_model.m_normal_array} ,battle_pet = self.m_model.m_battle_pet ,set_type = set_type, team_type = team_type, teams = teams, relics = self.m_model.m_mult_solts , deployments = deployments}, callfunc,false,nil, GlobalConfig.POST)
	else
		teams, can_set, deployments = self.m_model:getMultTeamParam()
		if not can_set then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0934"), delay_close = 2})
			return
		end
		self.m_model:getNetData("friend_arena_set_defend_teams",{normal_arrays = self.m_model.m_mult_normal_array ,battle_pets = self.m_model.m_mult_battle_pets ,set_type = set_type, team_type = team_type, teams = teams, relics = self.m_model.m_mult_solts , deployments = deployments}, callfunc,false,nil, GlobalConfig.POST)
	end
end

--争锋联赛防守阵容设置 team_type 1:单队
function M:zfArenaSetDefendTeams(team_type)
	local function callfunc()
		self.m_model.m_team_changed_flag = false
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		--self:updateMsg("refresh_ui", nil, "FulwinArena.FulwinArenaMain")
		if team_type~=1 then
			self:updateMsg("refresh_ui", nil, "Arena.ArenaHigher.ArenaHigherDefendTeam")
		end
		self:updateMsg(99999)
	end
	--local set_type = self.m_model.m_params.edit_team or 0
	local teams, can_set, deployments = nil
	if team_type == 1 then
		local can_set = false
		local team = {}
		for i = 1, 5 do
			team[i]= self.m_model.main_team[i] or ""
			if team[i] ~= "" then
				can_set = true
			end
		end
		if not can_set then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0244"), delay_close = 2})
			return
		end

		teams = self.m_model.main_team
		if type(self.m_model.m_atk_deployment) == "number" then
			deployments = self.m_model.m_atk_deployment == 0 and 1 or self.m_model.m_atk_deployment
		else
			deployments = 1
		end
		self.m_model:getNetData("rise_arena_set_defends",
				{heros_ban={},
				 normal_arrays = self.m_model.m_normal_array,
				 mul_team = false,
				 teams = teams,
				 relics = self.m_model.m_mult_solts ,
				 deployments = deployments},
				callfunc,false,
				nil,
				GlobalConfig.POST)
	else
		teams, can_set, deployments = self.m_model:getMultTeamParam()
		if not can_set then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0934"), delay_close = 2})
			return
		end
		self.m_model:getNetData("rise_arena_set_defends",
				{heros_ban=self.m_model.m_forbidden_hero_ids,
				normal_arrays = self.m_model.m_mult_normal_array ,
				 mul_team =true,
				 teams = teams,
				 relics = self.m_model.m_mult_solts ,
				 deployments = deployments}, callfunc,false,nil,
				GlobalConfig.POST)
	end
end


--宠物斗技
function M:petDoujiSetTeam()
	local can_set = false
	local team = {}
	for i = 1, 3 do
		local data,_ = self.m_model:getPetData(self.m_model.main_team[i])
		if data then
			team[i]=  self.m_model.main_team[i]
		else
			team[i]= ""	
		end
		
		if team[i] ~= "" then
			can_set = true
		end
	end
	if not can_set then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("pet_douji_text_06"), delay_close = 2})
		return
	end
	local function callfunc()
		self.m_model.m_team_changed_flag = false
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
		self:updateMsg(99999)
	end
	self.m_model:getNetData("set_defend_team",{team = team}, callfunc,false,nil, GlobalConfig.POST)
end

function M:RunAnimEnd()
	local params = {main_team = self.m_model.main_team,def_data = self.m_model.m_def_data,index = self.m_model.m_formation_index}
	self:openView("CombatSuppressSystem",params)	
end

function M:RunAnimEnter()
	self.m_view:runEnterAnim()
end

function M:destroy()
	LikeOO.BattleTalkControl:closeTalk()
	M.super.destroy(self)
	EventDispatcher:unRegisterEvent("refreshHelperUI", {self, self.refreshHelperUI})
end

return M
