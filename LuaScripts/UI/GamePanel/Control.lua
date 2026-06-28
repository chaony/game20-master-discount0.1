---@class GamePanelControl : OOControlBase
---@field m_model GamePanelModel
---@field m_view GamePanelView
local M = class("GamePanelControl",LikeOO.OOControlBase)

function M:onEnter()
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS then
		if SceneManager.curScene.sceneId ~= SceneManager.SceneID.BossScene then
			SceneManager:changeScene(SceneManager.SceneID.BossScene,self.m_model)
		else
			self:updateMsg("battle_start")
		end
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
		if SceneManager.curScene.sceneId ~= SceneManager.SceneID.ActiveBossScene then
			SceneManager:changeScene(SceneManager.SceneID.ActiveBossScene,self.m_model)
		else
			self:updateMsg("battle_start")
		end
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE then
		if SceneManager.curScene.sceneId ~= SceneManager.SceneID.HeroTrainScene then
			SceneManager:changeScene(SceneManager.SceneID.HeroTrainScene,self.m_model)
		else
			self:updateMsg("battle_start")
		end
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HERO_BOSS_PVE then
		if SceneManager.curScene.sceneId ~= SceneManager.SceneID.HeroTrainScene then
			SceneManager:changeScene(SceneManager.SceneID.HeroTrainScene,self.m_model)
		else
			self:updateMsg("battle_start")
		end
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNION_BOSS then
		if SceneManager.curScene.sceneId ~= SceneManager.SceneID.UnionBossScene then
			SceneManager:changeScene(SceneManager.SceneID.UnionBossScene)
		else
			self:updateMsg("battle_start")
		end
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOWER or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER or self.m_model.m_mode==GlobalConfig.BATTLE_MODE.XIAKEDAO
	or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI then
		if SceneManager.curScene.sceneId ~= SceneManager.SceneID.TianjiLouFightScene then
			SceneManager:changeScene(SceneManager.SceneID.TianjiLouFightScene, self.m_model.m_data)
		else
			self:updateMsg("battle_start")
		end
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MAZE then
		if SceneManager.curScene.sceneId ~= SceneManager.SceneID.MiGongFightScene then
			SceneManager:changeScene(SceneManager.SceneID.MiGongFightScene)
		else
			self:updateMsg("battle_start")
		end
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE then
		if SceneManager.curScene.sceneId ~= SceneManager.SceneID.GuJianQiTanFightScene then
			SceneManager:changeScene(SceneManager.SceneID.GuJianQiTanFightScene)
		else
			self:updateMsg("battle_start")
		end
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.YINYANG_TOWER
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WD_TOWER
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FOUR_TOWER then
		if SceneManager.curScene.sceneId ~= SceneManager.SceneID.WuXingZhenFightScene then
			SceneManager:changeScene(SceneManager.SceneID.WuXingZhenFightScene, self.m_model)
		else
			self:updateMsg("battle_start")
		end
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LEGEND then
		if SceneManager.curScene.sceneId ~= SceneManager.SceneID.LegendScene then
			SceneManager:changeScene(SceneManager.SceneID.LegendScene)
		else
			self:updateMsg("battle_start")
		end
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.QIMENDUNJIA then
		if SceneManager.curScene.sceneId ~= SceneManager.SceneID.QiMenDunJiaScene then
			SceneManager:changeScene(SceneManager.SceneID.QiMenDunJiaScene)
		else
			self:updateMsg("battle_start")
		end
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
		if SceneManager.curScene.sceneId ~= SceneManager.SceneID.FightScene then
			SceneManager:changeScene(SceneManager.SceneID.FightScene, self.m_model.m_data.battle)
		else
			self:updateMsg("battle_start")
		end
	else
		if SceneManager.curScene.sceneId ~= SceneManager.SceneID.FightScene then
			SceneManager:changeScene(SceneManager.SceneID.FightScene, self.m_model.m_data)
		else
			self:updateMsg("battle_start")
		end
	end
	SceneManager.curScene:setMode(self.m_model.m_mode);
	self.m_guide_file_name = "UI.GamePanel.Guide"
	self.m_view:setAuto(self.m_model.m_auto)
	self.m_view:setSpeed2(self.m_model.m_speed2)

	audio:ResumeSkillsBusVol()
	self:updateMsg("formation_callback",nil,"parent")
	self.m_plot_show_flag = false
	audio:SendEvtUI("In_Battle")
	SceneManager:continue()
end

-- 不执行guide start
function M:startGuide()
	--self:plotShow()
end

function M:plotShow()
	if SceneManager.curScene.cameraObj == nil then
		return
	end
	if self.m_plot_show_flag then
		return
	end
	self.m_plot_show_flag = true
	local function callback()
    	self:updateMsg("battle_start")
    end
	SceneManager:getCurSceneView():DeleteEffectAndCamera();
 --    if self.m_model.m_params.isDemonstrate then
	--     self:openView("Pops.PlotPop", {callback = callback, demonstrate = self.m_model.m_params.isDemonstrate})
	-- else
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
		local stage_cfg = GameUtil:getBattleStageCfg()
		if (stage_cfg.img_event and stage_cfg.img_event ~= "") or (stage_cfg.chapter_img_event and next(stage_cfg.chapter_img_event) ~= nil) then
			self:openView("Pops.PlotPop", {callback = callback})
		else
			callback()
		end
	else
		callback()
	end
	-- end
end

function M:realBattleStart()
	if self.m_model == nil then return end
	if GlobalConfig.BATTLE_MODE_CFG[self.m_model.m_mode].pvp or self.m_model.m_replay then
		if self.m_model.m_replay then
			if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE then
				if self.m_model.m_params.round then
					SceneManager.curScene:battleStart(self.m_model.m_data, self.m_model.m_round, true)
				else
					SceneManager.curScene:battleStart(self.m_model.m_data, 0, true, nil, true)
				end
			else
				SceneManager.curScene:battleStart(self.m_model.m_data, self.m_model.m_round, true)
			end
		else
			SceneManager.curScene:battleStart(self.m_model.m_data, 0, false)
		end
	else
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE then
			SceneManager.curScene:battleStart(self.m_model.m_data, 0, false, self.m_model.m_five_pos)
		else
			SceneManager.curScene:battleStart(self.m_model.m_data)
		end
	end
	LikeOO.BattleTalkControl:checkBattleTalk(0)
end

function M:battleStart()
	if self.m_model == nil then return end
	if (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RAID or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT) and not self.m_model.m_replay then
		--local stage_cfg = GameUtil:getBattleStageCfg()
		local battle_id = self.m_model.m_battle_id
		
		--local stage_battle_cfg = ConfigManager:getCfgByName("stage_battle")
		local stage_battle_cfg_item = ConfigManager:getCfgStageBattle(battle_id) or {}--stage_battle_cfg[battle_id] or {}
		if (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT) and (stage_battle_cfg_item == nil or not(next(stage_battle_cfg_item))) then
			if battle_id == nil then
				battle_id = self.m_model.m_battle_id_tab[self.m_model.m_round]
			end
			stage_battle_cfg_item = ConfigManager:getCfgStageBattle(battle_id)
		end
		local boss_position = stage_battle_cfg_item.boss_position or 0
		local monster = stage_battle_cfg_item.monster or {}
		local boss_monster = monster[boss_position]
		if boss_monster then
			self:openView("GamePanel.BattleBossTips", {hero_id = boss_monster.id, callback = function()
				self:realBattleStart()
			end})
		else
			self:realBattleStart()
		end
	else
		self:realBattleStart()
	end
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:closeView()
	elseif msg == "hero_buff_btn" or msg == "h_hero_buff_btn" then--查看己方英雄buff
		if self.m_model.m_is_stop then return end
		local res1, res2, race1, race2 = self.m_model:checkArray()
		self:openView("Pops.FetterBuffPop", {buff_lv = res1, demon_num = res2})
	elseif msg == "enemy_buff_btn" or msg == "h_enemy_buff_btn"	then--查看敌方英雄buff
		if self.m_model.m_is_stop then return end
		local res1, res2, race1, race2 = self.m_model:checkEnemyArray()
		self:openView("Pops.FetterBuffPop", {buff_lv = res1, demon_num = res2})
	elseif msg == "speed2" or msg == "h_speed2" then	--2倍速
		self:selectSpeed2()
	elseif msg == "auto" or msg == "h_auto" then	--自动打怪
		if UserDataManager.guide_data:isGuiding() then
			SceneManager:continue();
		end
		self:selectAuto()
	elseif msg == "addCount" then	--宝箱回调
		self.m_view:setTreasure_count(data)
	elseif msg == "playerDataShow" then
		self:openView("GamePanel.PlayerDataShow");
	elseif msg == "stop" or msg == "h_stop" then	--暂停
		--self.m_model:autoStop()
		--self.m_view:handlerStopBtn()
		-- if self.m_model.m_is_stop then
		-- 	SceneManager:pause()
		-- else
		-- 	SceneManager:continue();
		-- end
		SceneManager:pause()
		LikeOO.BattleTalkControl:pause()
		local params = {
			--继续战斗
			btn1_call = function ()
				SceneManager:continue();
				LikeOO.BattleTalkControl:play()
			end,
			--退出战斗
			btn2_call = function ()
				SceneManager.curScene:exitBattle()
				SceneManager:getCurSceneView():resetCamerInfo();
				SceneManager:getCurSceneView().cameraController:BlackScreen(false);
				SceneManager.curScene.plyMgr:resetBlackTimeHandler();
				self:sendRoundAction(2) --发送战斗统计数据
				
				SceneManager.curScene.gameover = true
				--初始化阶段
				SceneManager:getCurSceneModel():set_sceneState(0)
				if self.m_model == nil then
					return
				end
				if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RAID then
					self:updateMsg("battle_end_refresh_ui", nil, "Taoist")
					SceneManager:changeScene(SceneManager.SceneID.HangUpScene)
					self:closeView()
				else
					if self.m_model.m_replay then
						SceneManager.curScene:gameOverNow()
					else
						local mode = self.m_model.m_mode
						local mode_util_item = BattleModeUtil[mode]
						if mode_util_item and mode_util_item.gamePanelControlExit then
							mode_util_item.gamePanelControlExit(self)
						else
							self:updateMsg("common_refresh",nil,"parent")
							static_rootControl:closeAllViewPop();
							SceneManager:changeScene(SceneManager.SceneID.HangUpScene)
						end
					end
				end
				SceneManager:continue();
				TimeManager:reset()
			end,
			--重新开始
			btn3_call = function ()
				SceneManager.curScene:restartBattle()
				SceneManager:getCurSceneView():resetCamerInfo();
				SceneManager:getCurSceneView().cameraController:BlackScreen(false);
				SceneManager.curScene.plyMgr:resetBlackTimeHandler();
				if self.m_model == nil then
					return
				end
				self:sendRoundAction(3) --发送战斗统计数据
				local mode = self.m_model.m_mode
				local race = self.m_model.m_race
				local battle_id = self.m_model.m_battle_id
				local battle_config_id = self.m_model.battle_config_id
				local floor = self.m_model.m_floor
				local five_pos = self.m_model.m_five_pos
				local bio_id = self.m_model.m_bio_id
				local chapter_id = self.m_model.m_chapter_id
				local stage_id = self.m_model.m_stage_id
				local version = self.m_model.version
				local boss_id = self.m_model.m_boss_id
				local raid_sort = self.m_model.m_raid_sort
				local m_type = self.m_model.m_type
				local m_legend_data = self.m_model.m_legend_data
				local m_budo_floor = self.m_model.m_budo_floor
				local active_tower_heros = nil
				local next_floor = false
				local stage_type = self.m_model.m_params.stage_type -- 战斗关卡类型
				local cell_id = self.m_model.m_params.cell_id -- 地块id
				local star = self.m_model.m_params.star -- 难度
				local races = self.m_model.m_races -- 限制种族
				local wall_coef = self.m_model.m_wall_coef
				local combat_gve_battle = self.m_model.m_combat_gve_battle
				local lock_hids = self.m_model.m_lock_hids
				local difficulty_reduce = self.m_model.m_difficulty_reduce
				local boss_max_hp = self.m_model.m_boss_max_hp
				local def_data = self.m_model.gve_def_data
				local gve_version = self.m_model.m_gve_version
				local cur_stage_cfg = self.m_model.m_cur_stage_cfg
				local layer=self.m_model.m_layer
				LikeOO.BattleTalkControl:play()
				
				if mode == GlobalConfig.BATTLE_MODE.TOWER or mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER then --天机楼 重新开始使用天机楼阵容
					next_floor = true
				end
				if mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER then
					active_tower_heros = self.m_model.m_legend_heros
				end
				local mode_util_item = BattleModeUtil[mode]
				if mode_util_item and mode_util_item.gamePanelControlRestart then
					self:openView("Pops.TransitionPage")
					mode_util_item.gamePanelControlRestart(self, m_type)
				else
					-- self:openView("Formation",{mode = mode, next_floor = next_floor, budo_floor = m_budo_floor, race = race, battle_id = battle_id, floor = floor, five_pos = five_pos, version = version,boss_id = boss_id, raid_sort = raid_sort, battle_config_id = battle_config_id, bio_id = bio_id, chapter_id = chapter_id, stage_id = stage_id, legend_data = m_legend_data});
					self:openView("Pops.TransitionPage", {open_view_name = "Formation", open_view_params = {mode = mode, next_floor = next_floor, budo_floor = m_budo_floor, race = race, battle_id = battle_id, floor = floor, five_pos = five_pos, version = version,boss_id = boss_id, raid_sort = raid_sort, 
																											battle_config_id = battle_config_id, bio_id = bio_id, chapter_id = chapter_id, stage_id = stage_id, legend_data = m_legend_data, active_tower_heros = active_tower_heros, 
																											stage_type = stage_type, cell_id = cell_id, star = star, races = races, wall_coef = wall_coef, combat_gve_battle = combat_gve_battle, lock_hids = lock_hids, 
																											difficulty_reduce = difficulty_reduce, boss_max_hp = boss_max_hp, def_data = def_data, gve_version = gve_version,cur_stage_cfg = cur_stage_cfg,layer=layer}})
				end
				self:closeView();
				-- SceneManager:continue();
				TimeManager:reset()
			end,
			replay = self.m_model.m_replay,
			mode = self.m_model.m_mode,
		}
		self:openView("GamePanel.GamePanelPop", params)
	elseif msg == "useSkill" then	--暂停
		self:useSkill(data["index"])
	elseif msg == "refreshCardEffect" then	--刷新大招特效
		self:refreshCardEffect(data["index"], data["show"])
	elseif msg == "skill_click" then
		SceneManager:continue();
	elseif msg == "check_guide" then
		if UserDataManager.guide_data:isGuiding() then
			self:closeView("Pops.FetterBuffPop")
		end
		self.m_guide:checkGuide()
	elseif msg == "battleOnce" then
		local round = data.round or 0
		if round == 0 then
			self.m_view:setVSInfo(round)
		else
			if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA 
					or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA  
					or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA
					or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD
					or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE
					or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
				self.m_view:setVSInfo(round)
				if  self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.MULT_STAGE and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
					self.m_view:showRoundNode(round)
				end
				self.m_view:setBuffLv(round)
				self:setOnceTimer(round == 1 and 2 or 1, function()
					self.m_view:hideRoundNode()
				end)
			end
		end
	elseif msg == "battle_start" then
		--带剧情的战斗开始
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
			--self:play_all_drama()
			self:battleStart();
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOP_OF_TIME then --时光之巅发送战斗开始
			self:rpgBattleStart()
		else
			self:battleStart()
		end
	elseif msg == "battle_end" then
		self:battleEnd( data )
	elseif msg == "boss_passivity_img" then
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS 
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE then
			return
		end
		local data_desc = self.m_model:getBossBufTips()
		local btns = self.m_view:findGameObject("boss_passivity_img")
		GameUtil:lookInfoTips(self.m_control, {click_transform = btns.transform, msg = Language:getTextByKey(data_desc)  } )
	elseif msg == "add_value_info_btn" then
		self.btn_trans = self.m_view:findGameObject("add_value_info_btn")
		GameUtil:lookInfoTips(self.m_control, {click_transform = self.btn_trans.transform, msg = Language:getTextByKey("fb_str_0031")})
	elseif msg == "hide_ui" then
		self.m_view:setObjectVisible("horizontally_main",false);
	elseif msg == "pet_contest_start" then	-- 宠物对战开始
		self.m_view:showPetContestStart(data)
	elseif msg == "pet_contest_result" then
		self.m_view:showPetContestResult(data)
	elseif msg == "battle_anim" then
		local round = SceneManager:getCurSceneModel().round or 1
		if round == 1 and (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ZF_ARENA
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ZF_ARENA_MUL
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HERO_BOSS_PVP
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RTA_ARENA) then
			self.m_view:addBattleVS()
			self:setOnceTimer(1, function()
				self.m_view:removeBattleVS()
				if data.callback ~= nil then
					data.callback()
				end
				--	SceneManager.curScene:battleFrist()
			end)
		else
			if (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MYTH_ARENA) and round then
				self.m_view:setBuffLv(round)
			end
			self.m_view:palyBeginAnim(data.callback)
		end
	elseif msg == "hide_view" then
		self.m_view:setObjectVisible("h_stop", false)
		--self.m_view:setObjectVisible("h_auto", false)
		self.m_view:setObjectVisible("horizontally_main", false);
	elseif msg == "show_view" then
		self.m_view:setObjectVisible("horizontally_main", true);
		self.m_view:runAnim("GamePanel_Enter")
	elseif msg == "show_black_line" then
		self.m_view:runAnim("black_line_1")
		audio:SendEvtUI("UI_StoryStart")
		audio:PauseMusicBusVol()
	elseif msg == "hide_black_line" then
		local function call_back()
			self.m_view:runAnim("GamePanel_Enter")
		end
		self.m_view:runAnim("black_line_2", call_back)
		audio:ResumeMusicBusVol()
	elseif msg == "playerSkillName" then
		self.m_view:playerSkillName(data);
	elseif msg == "start_battle_beging" then
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA 
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA 
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD 
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA_DEFENSE
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MINING
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_MINING
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RTA_ARENA
		then
			self.m_view:setObjectVisible("h_stop", false)
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
			self.m_view:setObjectVisible("h_stop", false)
		else
			self.m_view:setObjectVisible("h_stop", self.m_model:getBoolByCom(2) == true and not(self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS)  )
		end
		if UserDataManager.guide_data:isGuiding() then
			local guide_info = UserDataManager.guide_data:getCurGuideInfo()
			if guide_info.key == "GamePanel" and guide_info.action == 5 or guide_info.action == 6 or guide_info.action == 7 then
				self:updateMsg("check_guide")
			end
		end
	elseif msg == "load_scene_finish" then
		--self:plotShow()
		self:updateMsg("battle_start")
	elseif msg == "quick_pass_btn" then
		self:stageQuickPassStage()
	end
end

--播放战斗前的剧情
function M:battle_play_drama( callback_drama )
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


function M:play_all_drama()
	--战斗前的逻辑
	--场景剧情不是空
	if SceneManager.curScene.story ~= nil then
		--0 先播放别的剧情
		--1 先播放我
		if SceneManager.curScene.story.playIndex == 0 then
			--播放剧情
			self:battle_play_drama( function()
				--播放站立对话
				SceneManager:getCurSceneView():runStory(function()
					--战斗开始
					self:battleStart();
				end)
			end)
		else
			--先播放站立对话
			SceneManager:getCurSceneView():runStory(function()
				--再播放 drama
				self:battle_play_drama( function()
					--战斗开始
					self:battleStart();
				end)
			end)
		end
	end
end


function M:battleEnd( data )
	if UserDataManager.guide_data:isGuiding() then
		local guide_info = UserDataManager.guide_data:getCurGuideInfo()
		if guide_info.key == "GamePanel" and guide_info.action == 4 then
			self.m_guide:doNextGuide()
		end
	end


	if self.m_model.m_replay then
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RTA_ARENA  then
			local mode = self.m_model.m_mode
			local mode_util_item = BattleModeUtil[mode]
			if mode_util_item and mode_util_item.gamePanelControlExit then
				mode_util_item.gamePanelControlExit(self)
			end
			return
		end
	end

	local function callback()
		--data.ex_hero = ex_hero
		local time = 0
		if  SceneManager.curScene.sceneId == 10 or SceneManager.curScene.sceneId == 3  then
			local pos = Vector3.New(3.5,5.15,-8)
			local count = 0
			local table_value = {}
			for i = self.m_view.boss_data.Count, 1, -1 do
				local obj = self.m_view.boss_data:get(i -1)
				if obj ~= nil and SceneManager.curScene ~= nil then
					time = 1
					SceneManager.curScene:MoveToPath(obj,obj.transform.position,pos,0,0.4, function( ... )
						count = count + 1
						self.m_view.slot_anim.gameObject:SetActive(true)
						ResourceUtil:ReturnItem(obj)
						self.m_view.boss_data:remove(obj)
						table_value = {count = 1 , list_data = self.m_view.boss_data}
						self.m_view:setTreasure_count(table_value)
					end)
				end
			end
		end

		self:setOnceTimer(time, function()
			data.version = self.m_model.version or 1
			if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY
					or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WD_TOWER
					or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.YINYANG_TOWER
					or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FOUR_TOWER then --五行
				data.m_five_pos = self.m_model.m_five_pos or 1
				data.m_floor = self.m_model.m_floor or 1
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOWER then
				data.m_budo_floor = self.m_model.m_budo_floor or 1
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.BIOGRAPHY then -- 传记
				data.bio_id = self.m_model.m_params.bio_id
				data.chapter_id = self.m_model.m_params.chapter_id
				data.stage_id = self.m_model.m_params.stage_id
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LEGEND then -- 江湖传说
				data.value = SceneManager.curScene:getBattleValue()
				data.stage_id = self.m_model.m_params.battle_id
				data.legend_new_record = self.m_view.legend_new_record
				data.legend_level = self.m_model.m_params.legend_data.level
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW then -- 邪极魅影
				data.m_floor = self.m_model.m_floor or 1
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS then -- 三侠五义
				data.m_floor = self.m_model.m_floor or 1
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE then -- 通用试炼
				data.m_floor = self.m_model.m_floor or 1
				data.open_id = self.m_model.open_id or 395
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD then -- 龙泉剑影
				data.m_floor = self.m_model.m_floor or 1
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
				data.stage_type = self.m_model.m_params.stage_type -- 战斗关卡类型
				data.cell_id = self.m_model.m_params.cell_id -- 地块id
				data.star = self.m_model.m_params.star --难度星等
				data.gve_version = self.m_model.m_params.gve_version -- 战斗版本号
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then--古剑奇谭
				data.stage_id = data.ext_data.stage_id
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACCON then--xhx
				data.stage_id = data.ext_data.stage_id
				data.raccon_hero_id = self.m_model.m_params.raccon_hero_id
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.AWAKE_SYSTEM then--入梦铃
				data.stage_id = self.m_model.m_params.stage_id
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HERO_FATE then--侠客情缘
				data.stage_id = self.m_model.m_params.stage_id
			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_BOSS then--剑试天下 Boss阶段
				data.open_id = self.m_model.open_id or 414
				data.battle_id = self.m_model.m_battle_id

			elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RTA_ARENA then--剑出鸿蒙
				data.rta_wendaoBNum = self.m_model.rta_wendaoBNum
				data.rta_score = self.m_model.m_rta_score
				data.rta_preScore = self.m_model.m_rta_preScore
				data.rta_result=self.m_model.m_rta_result
			end
			if not self.m_model.m_params.isDemonstrate then
				data.battle_type = self.m_model.m_params.battle_type
				if data.battle_data then
					data.battle_data.battle_config_id = self.m_model.battle_config_id
				end
				data.boss_id = self.m_model.m_boss_id
				data.boss_dmg = self.m_view.boos_totalDamage
				data.max_boss_hp = self.m_model.m_boss_max_hp
				data.boss_hp_cid = self.m_model.m_boss_hp_cid
				data.battle_time = SceneManager.curScene:getBattleUseTime()
				if data.quick_pass then
					SceneManager:pause()
				end
				data.raid_sort = self.m_model.m_raid_sort
				data.round = self.m_model.m_round
				data.special_open_id = self.m_model.m_special_open_id or nil -- 侠客志
				data.special_version = self.m_model.m_special_version or nil
				--Logger.logError(data," 发送到结算界面的数据 ")
				self:openView("Settlement", data)
			else
				local function netCallback(response)
					local rewards = RewardUtil:mergeRewardAndFormat(response.reward)
					local heros = {}
					for i,v in ipairs(rewards) do
						if v[1] == RewardUtil.REWARD_TYPE_KEYS.HEROS then
							if UserDataManager.hero_data:isNewHero(v[2]) then
								table.insert(heros, v)
							end
						end
					end
					if #heros > 0 then
						self:updateMsg("battle_end", heros, "parent")
						--RewardUtil:rewardTipsByRewards(heros, callback)
					else
						self:updateMsg("battle_end", nil, "parent")
					end
				end
				local upload_data = data.battle_data and data.battle_data.upload_data
				upload_data = upload_data or {}
				if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
					if self:isStoryLevel() then
						upload_data.s_id = UserDataManager:getBattleStage();
						upload_data.node_id = self.m_model.m_node_id;
						self.m_model:getNetData("scenario_battle_end", upload_data, netCallback, nil, nil, GlobalConfig.POST, {forceBack = true})
					else
						self.m_model:getNetData("battle_end", upload_data, netCallback, nil, nil, GlobalConfig.POST, {forceBack = true})
					end
				else
					self.m_model:getNetData("battle_end", upload_data, netCallback, nil, nil, GlobalConfig.POST, {forceBack = true})
				end
			end
		end)
		--end)
	end
	--侠客情缘，有结束时播放剧情的需求
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HERO_FATE then
		local result = data.result or 0
		if result == 1 then
			local dialog_id = self.m_model.m_cur_stage_cfg.win_event or 0
			if dialog_id ~= 0 then
				self:openView("Guide.GuideDrama", {dialog_id = dialog_id, callback = callback})
				return
			end
		end
	end
	callback()
	--LikeOO.BattleTalkControl:closeTalk()
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
		local stage_cfg = GameUtil:getBattleStageCfg()
		UserDataManager:setTempData("battleStage",stage_cfg);
		--local result = data.result or 0
		--local dialog_id = result == 1 and stage_cfg.win_event or stage_cfg.lose_event
		--if dialog_id ~= 0 then
		--	self:openView("Guide.GuideDrama", {dialog_id = dialog_id, callback = callback})
		--else
		--	callback()
		--end
	end
end

--是否是剧情关 
function M:isStoryLevel()
			--加载剧情关配置
			local scenario_config = ConfigManager:getCfgByName("scenario_config");
			for k,v in pairs(scenario_config) do
			if tonumber(k) == UserDataManager:getBattleStage() then
			return true;
			end
			end
			return false;
			end			
			

--地图-战斗开始
function M:rpgBattleStart( data )
	local delopment = data.delopment or 1;
	local team = data.team;
    local chapter_id = data.chapter_id
    local block_id = data.block_id
    local function netCallback(response)
        if SceneManager.curScene ~= nil then
            SceneManager.curScene:rpgBattleStart(response);
        end
    end
    local params = {chapter_id = data.chapter_id, block_id = data.block_id }
    self.m_model:getNetData("rpg_battle_start", params, netCallback,nil,nil,GlobalConfig.POST)
end

--快速通关
function M:stageQuickPassStage()
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA 
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD 
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA 
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MYTH_ARENA
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI  then
		SceneManager:pause()
		local battle_data = self.m_model.m_data
		self:updateMsg("battle_end", { result = battle_data.result, mode = self.m_model.m_mode, battle_data = battle_data})
		return
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_BOSS
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LEGEND then
		SceneManager:pause()
		local upload_data = {}
		upload_data.skip = 1 --boss结果默认胜利
		self:updateMsg("battle_end", { result = 1, mode = self.m_model.m_mode, quick_pass = true})
		return
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE then
		SceneManager:pause()
		local upload_data = {}
		upload_data.skip = 1 --boss结果默认胜利
		local battle_data = self.m_model.m_data
		self:updateMsg("battle_end", { result = battle_data.result, mode = self.m_model.m_mode, quick_pass = true})
		return
	end
	local function netCallback(response)
		local need_battle = response.need_battle or 0
		if need_battle == 0 then
			self:updateMsg("battle_end", { result = 1, mode = self.m_model.m_mode, battle_data = {}, quick_pass = true, data = response})
		else
			GameUtil:lookInfoTips(self, {msg = "new_str_0762", delay_close = 2})
		end
	end
	local params = {}
	self.m_model:getNetData("stage_quick_pass_stage", params, netCallback)
end

function M:selectSpeed2()
	if self.m_model:getBoolByCom(4) == true then
		local speed2 = self.m_model:changeSpeed2()
		self.m_view:setSpeed2( speed2 )
		UserDataManager.local_data:setUserDataByKey("combat_speed", speed2)
		TimeManager:set_localSpeed( speed2 )
	else
		local need_id = ConfigManager:getCommonValueById(258)
		local stage_tab = ConfigManager:getCfgByName("stage")
		local need_stage = stage_tab[need_id]
		local map_name = Language:getTextByKey(need_stage.map_point_name)
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0516", map_name), delay_close = 2}) 
	end
	
end

function M:selectAuto()
	local auto = self.m_model:changeAuto()
	self.m_view:setAuto(auto)
	UserDataManager.local_data:setUserDataByKey("combat_auto", auto)
	SceneManager:getCurSceneModel():addAutoFight(auto == 1);
	--SceneManager.curScene.plyMgr:SetAutoFight(auto == 1)
end

function M:useSkill(playerIndex)
	if UserDataManager.guide_data:isGuiding() then
		local guide_info = UserDataManager.guide_data:getCurGuideInfo()
		if guide_info.key == "GamePanel" and guide_info.action == 4 then
			SceneManager:pause()
			return
		end
	end
	self.m_view:useSkill(playerIndex)
end

function M:refreshCardEffect(playerIndex, show)
	self.m_view:refreshCardEffect(playerIndex, show)
end

function M:removeAllHero()
	self.m_model.removeAll()
end

function M:refresh_kill_num(num)
	if self.m_view ~= nil then
		self.m_view:refreshKillNum(num)
		self.m_view:refreshLegendRecord(num)
	end
end

--function M:refresh_buff_attr(num)
--	self.m_view:refreshKillNum(num, true)
--end

--战斗中途操作统计
function M:sendRoundAction(type)
	local params = {}
	params.result = type or 2--(默认为2, 表示退出,3重新开始)
	params.sort = self.m_model.m_mode
	params.sub_id = self.m_model:getSubId()
	self.m_model:getNetData("round_action", params)
end


function M:destroy()
	LikeOO.BattleTalkControl:closeTalk()

	GameUtil:destroyLookInfoTips()
	self:closeView("Pops.FetterBuffPop")
	audio:PauseSkillsBusVol()
	M.super.destroy(self)
end

return M