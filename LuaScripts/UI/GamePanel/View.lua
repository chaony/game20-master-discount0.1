---@class GamePanelView : OOPopBase
---@field m_model GamePanelModel
local M = class("GamePanelView",LikeOO.OOPopBase)

M.m_uiName = "GamePanel/GamePanel2"
M.m_iphoneXAdapter = true
M.m_cache_ui_flag = true
local SkillButton = require("UI.GamePanel.SkillButton")

local c = {}

M.skillBtns = nil
M.panelLive = false;

M.func = nil
--boss表数据下表
M.maxnum = 0

M.bossHpColor = {
    Color(206/255,165/255,85/255,1),  --黄色
    Color(85/255,168/255,206/255,1),  -- 天蓝
    Color(167/255,85/255,206/255,1),  -- 紫色
    Color(206/255,85/255,85/255,1),   -- 红色
}

M.bossHpColor2 = {
	Color(85/255,168/255,206/255,1),  -- 天蓝
	Color(167/255,85/255,206/255,1),  -- 紫色
	Color(206/255,165/255,85/255,1),  --黄色
	Color(206/255,85/255,85/255,1),   -- 红色
	Color(0/255,0/255,0/255,1),  -- 黑色
}

M.effectUiData = {
	{anim = "TempEffectUI_gongji", imgPath = "jinqian"},
	{anim = "TempEffectUI_fuzhu", imgPath = "hengshan"},
	{anim = "TempEffectUI_huifu", imgPath = "fuwei"},
}

function M:onEnter()
	local content_node = self:findGameObject("horizontally_main")
	if content_node and self.m_iphonex_offset_x > 0 then
		local rt = content_node:GetComponent("RectTransform")
		rt.offsetMin = Vector2(self.m_iphonex_offset_x, rt.offsetMin.y)
		rt.offsetMax = Vector2(-self.m_iphonex_offset_x, rt.offsetMax.y)
	end
	self:setTextByLanKey("dps_add_name", "new_str_0392")
	self:setTextByLanKey("hp_add_name", "fb_str_0028")
	self.is_horizontally = CS.wt.framework.ResourcesHelper.useHovBattle
	self.battle_begin = self:findGameObject("battle_begin")
	self.pet_battle_begin1 = self:findGameObject("pet_battle_begin1")
	self.pet_battle_begin2 = self:findGameObject("pet_battle_begin2")
	self:setTextByLanKey("petjieduan1",  Language:getTextByKey("pet_douji_text_01"))
	self:setTextByLanKey("petjieduan2",  Language:getTextByKey("pet_douji_text_02"))
	self:setTextByLanKey("petbipin1",  Language:getTextByKey("pet_douji_text_03"))
	self:setTextByLanKey("petbipin2",  Language:getTextByKey("pet_douji_text_04"))
	self.pet_contest = self:findGameObject("pet_contest")
	self.bosshead_tx_img = self:findGameObject("bosshead_tx_img")
	self:updateBossHead();
	self:updateAddValue();
	self.boos_totalDamage = 0
	--注册斗气击破事件
	
	EventDispatcher:registerEvent("BlackOver",{self,self.blackOver})
	EventDispatcher:registerEvent("AngerMax",{self,self.angerMaxHandler})
	EventDispatcher:registerEvent("AngerUpdate",{self,self.angerUpdateHandler})
	EventDispatcher:registerEvent("HpUpdate",{self,self.hpUpdateHandeler})
	EventDispatcher:registerEvent("TimeUpdate",{self,self.timeUpdateHandler})
	EventDispatcher:registerEvent("PlayerDead",{self,self.playerDead})
	EventDispatcher:registerEvent("addSkillBtns",{self,self.addSkillBtns})
	EventDispatcher:registerEvent("calculateDamage", {self,self.calculateDamageHandler})
	EventDispatcher:registerEvent("MaxHpChanged",{self,self.playerMaxHpChanged})
	--EventDispatcher:registerEvent("UpdateTotalDamage",handler(self,self.shakeNum))
	self:setObjectVisible("horizontally_main", false)
	self:setObjectVisible("dmg", false)
	self:setObjectVisible("BosshpBar", false)
	self:setObjectVisible("playerDataShow", GameVersionConfig.OpenPlayDataShow == true)
	self:setObjectVisible("UI_GamePanel2_ShaDi_01",  false)
	self.panelLive = true
	self.destroyBox = false;
	self.skillBtns = Battle.List.new()
	self.canvasScaler = self.m_ui_obj:GetComponent("CanvasScaler");
	-- self.m_canvas.worldCamera = SceneManager.curScene.cameraController.Camera_UI
	self.main = self:findGameObject("horizontally_main") --main
	self.skillname_obj = self:findGameObject("skillname_obj");
	self.tempEffectUI_obj = self:setObjectVisible("TempEffectUI", false);
	self.effectUI_behaviour = UIUtil.findLuaBehaviour(self.tempEffectUI_obj)

	self.mainTran = self:findGameObject("horizontally_main") --main
	self.Total = self:findGameObject("h_Total") --总伤害
	self.auto = self:findButton("h_auto")  --自动战斗按钮
	self.speed2 = self:findButton("h_speed2")  --2倍速按钮
	self.totalDamageText = self:findText("TotalNum") --显示自动战斗的文字
	self.blood = self:findImage("h_blood") --血框
	self.blackSreen = self:findImage("h_blackSreen")  --黑屏
	self.Enemy_VindictiveZero = self:findGameObject("Enemy_VindictiveZero") --斗气耗尽
	self.timeText = self:findText("h_Time");
	self.timeText.text = self:formatTime(0);
	self.legend_timeText = self:findText("legend_time");
	self.legend_timeText.text = self:formatTime(0);
	self.cardNode = self:findGameObject("h_cardNode") 
	self:setObjectVisible("h_vs_info_node", false)
	self.main:SetActive(true)
	self.canvasScaler.referenceResolution = Vector2(1280,720)
	self.bosshp_slider = self:findSlider("BosshpBar")
	self.dmg = self:findText("dmg")
	self.passivity = self:findText("passivity")
	self.TimeBg = self:findGameObject("TimeBg")
	self.Bg = self:findImage("TimeBg")
	self.boss_hpValue = self:findImage("hpValue")
	self.boss_hpBg = self:findImage("hpBg")
	self.treasure = self:findGameObject("treasure") --宝箱
	self.treasure_count = self:findText("treasure_box_text") --宝箱数量
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS 
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.UNION_BOSS
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE 
			or (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY and self.m_model.m_five_pos == 0)
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_BOSS
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HERO_BOSS_PVE then
		
		self:setImg("sjboss_bosstouxiang01","maze_stage_ui", self.m_model:getBossBufImg())
		self.boss_hpValue.color = self.bossHpColor[4]
		self.boss_hpValue.color.a = 0
		self.bosshp_slider.value = 0
		self.bosshp_slider.gameObject:SetActive(self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.ACTIVE_BOSS)
		self.world_boss = ConfigManager:getCfgByName("world_boss")
		self.dmg.text = 0
		
		local boss_id = self.m_model.m_boss_id or 1
		if not self.world_boss[self.m_model.m_boss_id] then boss_id = 1 end
		self.lost_hp = self.world_boss[boss_id]["lost_hp"]
		self.reward_lost_hp = self.world_boss[boss_id]["reward_lost_hp"]
		
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS and next(self.m_model:getNewBossRewardCfg()) then
			self.reward_lost_hp = self.m_model:getNewBossRewardCfg()
		end
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
			local world_boss = ConfigManager:getCfgByName("active_world_boss")
			local world_boss_item = world_boss[self.m_model.m_data.battle.common.param or 327] or {}
			local version_item = world_boss_item[self.m_model.m_data.battle.common.sub_param or 1] or {}
			self.lost_hp = version_item["lost_hp"]
			self.reward_lost_hp = version_item["reward_lost_hp"]
		end
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE then
			self.hero_train = ConfigManager:getCfgByName("train_challenge")
			self.hero_train_cfg = self.hero_train[self.m_model.m_boss_id]
			self.lost_hp = self.hero_train_cfg["lost_hp"]
			self.reward_lost_hp = self.hero_train_cfg["reward_lost_hp"]
		end
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HERO_BOSS_PVE then
			self.hero_train = ConfigManager:getCfgByName("hero_boss")
			self.hero_train_cfg = self.hero_train[self.m_model.m_boss_id]
			self.lost_hp = self.hero_train_cfg["lost_hp"]
			--self.reward_lost_hp = self.hero_train_cfg["reward_lost_hp"]
		end
		if  self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_BOSS then
			self.hero_train = ConfigManager:getCfgByName("full_service_boss_hp") or {}
			self.hero_train_cfg = self.hero_train[100001] or {}
			self.lost_hp = self.hero_train_cfg["lost_hp"] or {}
			self.reward_lost_hp = {}
			self.bosshp_slider.gameObject:SetActive(false)
		end
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY then
			self.five_array = ConfigManager:getCfgByName("mood_shadow_stage")
			self.five_array_cfg = self.five_array[1] or {}
			self.lost_hp = self.five_array_cfg["lost_hp"]
		end
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW then
			self.evil_array = ConfigManager:getCfgByName("hero_event_stage")
			self.evil_array_cfg = self.evil_array[1] or {}
			self.lost_hp = self.evil_array_cfg["lost_hp"]
		end
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD then
			self.evil_array = ConfigManager:getCfgByName("evil_shadow_stage")
			self.evil_array_cfg = self.evil_array[2] or {}
			self.lost_hp = self.evil_array_cfg["lost_hp"]
		end
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS then
			self.evil_array = ConfigManager:getCfgByName("chivalrous_practice_stage")
			self.evil_array_cfg = self.evil_array[1] or {}
			self.lost_hp = self.evil_array_cfg["lost_hp"]
		end
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE then
			self.evil_array = ConfigManager:getCfgByName("active_train")
			self.evil_array_cfg = self.evil_array[self.m_model.open_id][self.m_model.version][1] or {}
			self.lost_hp = self.evil_array_cfg["lost_hp"]
		end

		self.dmg.text = 0 
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
			self.bosshp_slider.value = 1  -- 默认满血
			self.boss_hpValue.color = self.bossHpColor[2]
			self.boss_hpValue.color.a = 1
			self:setObjectVisible("dmg", true)
			self.dmg.text = "100%"
			self.gve_stage = ConfigManager:getCfgByName("gve_stage")
			self.gve_stage_cfg = self.gve_stage[self.m_model.m_params.stage_id] or {}
			self.lost_hp = self.gve_stage_cfg["lost_hp"]
		end
		--UIUtil.setLocalPosition(self.TimeBg.transform,300,305,0)
		--self.Bg.color = Color(0,0,0,0)
		self.color = Color(0,0,0,0)
		local BossHead = self:findGameObject("BossHead")
		local boss_user = self.m_model:getUserInfoBySort(2)
		GameUtil:setUserAvatar(BossHead, boss_user, false,nil,{show_flag = true, scale = 1})
		self.maxnum = 1
		self.reward_maxnum = 1
		self.treasure_count.text = 0
		self.count = 0
		self.boss_data = Battle.List.new()
		self.baoxiang_time = 5
		self.boss_hpBg.color = self.color
		local slot_anim = ResourceUtil:GetUIEffectItem("WorldBossPop/UI_WorldBossPop_BaoDian", self.treasure)
		-- self.slot_anim = ResourceUtil:LoadUIGameObject("Activities/WorldBoss/UI_WorldBossPop_BaoDian", Vector3.zero,nil)
		--  		self.slot_anim.transform:SetParent(self.treasure.transform, false)
		--  		self.slot_anim.gameObject:SetActive(false)
	end
	
	self:setObjectVisible("h_speed2", self.m_model:getBoolByCom(3) == true)

	M.ISNullObj_Active(self.Total)
	M.ISNullObj_Active(self.gameOver)

	self.m_hero_MaskSlider = MaskSlider.new()
	local hero = self:findGameObject("heroTeam")
	self.passivity.text = "";
	local hero_floor = UIUtil.findImage(hero.transform,"douQiBgFloor")
	self.m_hero_MaskSlider:creat(hero_floor)
	self.m_hero_MaskSlider:set_FixValue(1)

	self.m_enemy_MaskSlider = MaskSlider.new()
	local enemy = self:findGameObject("enemyTeam")
	local enemy_floor = UIUtil.findImage(enemy.transform,"douQiBgFloor")
	self.m_enemy_MaskSlider:creat(enemy_floor)
	self.m_enemy_MaskSlider:set_FixValue(1)

	self.m_hero_pingpang = self.m_hero_MaskSlider.m_hero_PingPangMotion
	self.m_enemy_pingpang = self.m_enemy_MaskSlider.m_enemy_PingPangMotion

	--playerSkills = {card1,card2,card3,card4,card5}
	
	self:setSpeed2(self.m_model.m_speed2)
	self:setAuto(self.m_model.m_auto)
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT
	or  self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE 
	or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MYTH_ARENA then
		self:setBuffLv(self.m_model.m_round)
	else
		self:setBuffLv()
	end
	self:setObjectVisible("stage_bg", self.m_model:checkShowStageName())
	
	local curLevel = UserDataManager:getBattleStage()
	if curLevel > 6 and (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE) then
		self:setTextByLanKey("stage_name",  Language:getTextByKey("new_str_0124").." "..self.m_model:getStageBattleName())
	else
		self:setTextByLanKey("stage_name",  self.m_model:getStageBattleName())
	end
	self:hideRoundNode()
	self.lost_hp_list = {}
	self.lost_hp_list = self.m_model:getGuildTable()
	self.drop_list = {}
	local is_bool = self.m_model:isShowEnemyUI()
	self:setObjectVisible("enemyBuff", is_bool)
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA 
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA_DEFENSE
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA_DEFENSE then
		--self:setObjectVisible("battle_begin_spine", false)
		self:setObjectVisible("battle_begin", false)
		self:setObjectVisible("pet_battle_begin1", false)
		self:setObjectVisible("pet_battle_begin2", false)
	else
		self:setObjectVisible("battle_begin", false)
		self:setObjectVisible("pet_battle_begin1", false)
		self:setObjectVisible("pet_battle_begin2", false)
		--self:setObjectVisible("battle_begin_spine", false)
	end
	self:setObjectVisible("h_stop", false)
	
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LEGEND then
		self:setObjectVisible("kill_num_bg", true) 

		self:setTextByLanKey("legend_refresh_time_text",  "legend_str_023")
		self.kill_num_content = self:findRectTransform("kill_num_content")
		self.kill_num_content_luaBehaviour = self.kill_num_content:GetComponent("LuaBehaviour")
		self.live_time_content = self:findRectTransform("live_time_content")
		self.live_time_content_luaBehaviour = self.live_time_content:GetComponent("LuaBehaviour")
		if self.m_model.m_data.battle.common.battle_mode == 2 then
			self:setTextByLanKey("kill_num_text",  "legend_str_005")
			self:setTextByLanKey("kill_num_text2",  "legend_str_028")
			self:setTextByLanKey("legend_record_text2", "legend_str_028")
			self:refreshKillNum(0)
		elseif self.m_model.m_data.battle.common.battle_mode == 3 then
			self:setTextByLanKey("live_time_text",  "legend_str_024")
			self:refreshKillNum(0, false)
			self:refreshNum(0, self.live_time_content, self.live_time_content_luaBehaviour)
			self:setTextByLanKey("live_time_text2", "legend_str_029")
			self:setTextByLanKey("legend_record_text2", "legend_str_029")
		end
		self:setTextByLanKey("legend_record_text", "legend_str_027")
		self.legend_refreshTime_content = self:findRectTransform("legend_refresh_time_content")
		self.legend_refreshTime_content_luaBehaviour = self.legend_refreshTime_content:GetComponent("LuaBehaviour")
		self:refreshLegendCountDown(SceneManager.curScene.legend_stage_cfg.refresh_time)
		self.legend_record_content = self:findRectTransform("legend_record_content")
		self.legend_record_content_luaBehaviour = self.legend_record_content:GetComponent("LuaBehaviour")
		local cur_record = self.m_model.m_legend_data.progress[tostring(SceneManager.curScene.legend_stage_cfg.type)]
		if cur_record == nil or cur_record == 0 then
			self:setObjectVisible("legend_record_bg", false)
		else
			self:setObjectVisible("legend_record_bg", true)
			self:refreshLegendRecord(0)
		end
		self:setObjectVisible("TimeBg", false)
		self:setObjectVisible("legend_time_Bg", true)
		self:setObjectVisible("kill_num_bg", self.m_model.m_data.battle.common.battle_mode == 2)
		self:setObjectVisible("live_time_bg", self.m_model.m_data.battle.common.battle_mode == 3)
		self:setObjectVisible("legend_refresh_bg", self.m_model.m_data.battle.common.battle_mode == 3)
	else
		self:setObjectVisible("kill_num_bg", false)
		self:setObjectVisible("TimeBg", true)
		self:setObjectVisible("legend_time_Bg", false)
		self:setObjectVisible("legend_refresh_bg", false)
		self:setObjectVisible("legend_record_bg", false)
		self:setObjectVisible("live_time_bg", false)
	end
	
	self.auto.gameObject:SetActive(self.m_model:getBoolByCom(1) == true and self.m_model:isCanReleaseSkill())
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA 
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA then
		self:setObjectVisible("h_auto", false)
		self:setAuto(1)
	end
	self:runAnim("GamePanel_Enter")
	self:clearSkillBtns();
	-- 快速通关按钮
	local open_quick_flag = self.m_model:openQuickFlag()
	self:setObjectVisible("quick_pass_btn", open_quick_flag)

	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then --宠物第一阶段不显示跳过按钮
		self:setObjectVisible("quick_pass_btn", false)
		self:setObjectVisible("h_stop", false)
	end

	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RTA_ARENA then
		--self:setObjectVisible("bottom_Btns", false)
		self:setObjectVisible("quick_pass_btn", false)
		self:setObjectVisible("h_auto", false)
	end
end


function M:updateAddValue()
	local openAddValue = false;
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
		local hp_rate = self.m_model.m_server_hp_coef - 100;
		local dps_rate = self.m_model.m_server_dps_coef - 100;
		if hp_rate > 0 then
			openAddValue = true;
			self:setText("hp_add_value","+"..hp_rate.."%")
			self:setText("dps_add_value","+"..dps_rate.."%")
		end
	else
		openAddValue = false;
	end
	self:setObjectVisible("add_value_bg", openAddValue)
	self:setObjectVisible("add_value_info_btn", openAddValue)
	self:setObjectVisible("hp_add_name", openAddValue)
	self:setObjectVisible("hp_add_value", openAddValue)
	self:setObjectVisible("dps_add_name", openAddValue)
	self:setObjectVisible("dps_add_value", openAddValue)
end



function M:updateBossHead()
	local bossHeadConfig = self.m_model:getBossConfig();
	if bossHeadConfig ~= nil then
		self:setObjectVisible("treasureHead",false);
		local hero_id = bossHeadConfig.hero_id
		if hero_id == nil then
			hero_id = bossHeadConfig.boss_show
		end
		local hero_detail = ConfigManager:getCfgByName("hero_detail");
		local hero_data = hero_detail[hero_id];
		if hero_data then
			UIUtil.setImg(self.bosshead_tx_img, hero_data.icon, "hero_head_ui")
		else
			Logger.logErrorAlways(hero_id, "hero_detail cfg not found id ： ")
		end
	else
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then -- 奇门遁甲boss不掉宝箱
			self:setObjectVisible("treasureHead",false);
			UIUtil.setImg(self.bosshead_tx_img, "a_boss_taiyin", "battle_ui")
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_BOSS then
			self:setObjectVisible("treasureHead",false);
		else
			local bossCfg = self.m_model:getWorldBossCfg()
			local boss_icon = bossCfg.boss_icon or "a_sjbs_bosstouxiang"
			UIUtil.setImg(self.bosshead_tx_img, boss_icon, "battle_ui")
		end
	end
end


function M:playerSkillName( player )
	local sceneInfo = Battle.BattleGlobalConfig.SCENE_ID_INFO[SceneManager.curScene.sceneId]
	if sceneInfo.showSkill3Effect ~= true then
		return
	end
	if self.skillname_obj and player.camp == 1 and player.curSkillConfig ~= nil then
		local deployment = SceneManager.curScene.atkDeployment
		local deployment_cfg = ConfigManager:getCfgByName("deployment")
		local deployment_cfg_item = deployment_cfg[deployment] or {}
		local key_pos = deployment_cfg_item.key_pos or 0 -- 阵眼序号

		--播放大招效果
		--local data = self.effectUiData[1]
		--LuaBehaviourUtil.runAnim(self.effectUI_behaviour,data.anim, nil)
		--local skill_img = self.effectUI_behaviour:FindGameObject(data.imgPath)
		--local hero_skin_cfg = Battle.BattleConfigManager:getHeroCurSkinCfgByData_Battle(player.heroData, player.plyData)
		--if hero_skin_cfg.skill3pic then
		--	GameUtil:updateResourcesImg(skill_img, "Texture/HeroIcon/"..hero_skin_cfg.skill3pic)
		--end
		--
		--local img = skill_img:GetComponent("Image")
		--img:SetNativeSize()
		--local skill_img_rect = skill_img:GetComponent("RectTransform")
		--skill_img_rect.sizeDelta = skill_img_rect.sizeDelta * 0.5
		--if  hero_skin_cfg.skill3pos then
		--	skill_img_rect.anchoredPosition = Vector2.New(hero_skin_cfg.skill3pos[1], hero_skin_cfg.skill3pos[2])
		--	LuaBehaviourUtil.setTextByLanKey(self.effectUI_behaviour,"skill_name", hero_skin_cfg.skill3name)
		--end
		--
		--self.tempEffectUI_obj:SetActive(true)
		--self.m_control:setOnceTimer(2.5,function()
		--	self.tempEffectUI_obj:SetActive(false)
		--end)
		
		--if player.index + 1 == key_pos then
		--else
			local skillname = player.curSkillConfig.data.skill_name_liberation
			if skillname ~= "" and skillname ~= nil then
				if not IsNull(self.m_skill_obj) then
					ResourceUtil:ReturnItem( self.m_skill_obj)
					self.m_skill_obj = nil
				end

				local skill_obj = GameUtil:createPrefab("GamePanel/BigSkillName2", self.skillname_obj.transform)
				if not IsNull(skill_obj) then
					skill_obj.transform.localPosition = Vector3(0,0,0)
					local luaBehaviour = UIUtil.findLuaBehaviour(skill_obj)
					local skill_name_img = luaBehaviour:FindGameObject("skill_name_img")
					GameUtil:setTextureLoadSetLanImgText(skill_name_img, skillname)

					local skill_role_img=luaBehaviour:FindGameObject("role_img").transform
					local hero_skin_cfg = Battle.BattleConfigManager:getHeroCurSkinCfgByData_Battle(player.heroData, player.plyData)
					if hero_skin_cfg.skill3pic then
						GameUtil:updateResourcesImg(skill_role_img, "Texture/HeroIcon/"..hero_skin_cfg.skill3pic)
					end

					if  hero_skin_cfg.skill3pos then
						local skill_img_rect = skill_role_img:GetComponent("RectTransform")
						skill_img_rect.anchoredPosition = Vector2.New(hero_skin_cfg.skill3pos[1], hero_skin_cfg.skill3pos[2])
					end
					--local role_img_rect=skill_name_img:GetComponent("RectTransform")
					--role_img_rect.anchoredPosition=Vector2.new(hero_skin_cfg.skillRoleImgPos[1],hero_skin_cfg.skillRoleImgPos[2])

					luaBehaviour:RunAnim("BigSkillName_Show", function()
						if not IsNull(skill_obj) then
							ResourceUtil:ReturnItem(skill_obj)
							skill_obj = nil
							self.m_skill_obj = nil
						end
					end, 1)
				end
				self.m_skill_obj = skill_obj			
			else
				Logger.logWarning(" 技能  Name = nil");
			end
		--end
	end
end

function M:setTreasure_count( data )
	self.count = self.count + data.count
	self.treasure_count.text = self.count
	self.boss_data = data.list_data
	-- self.boss_data:remove()
end

function M:calculateDamageHandler(eventName, data)
	local totalDamage = 0
	local enemylostHplistFix = SceneManager.curScene.plyMgr.enemylostHplistFix
	for k,v in pairs(enemylostHplistFix) do
		totalDamage = totalDamage + math.floor(GlobalTools:ToFloat(v))
	end
	--local totalDamage = GlobalTools:ToFloat(totalDamageFix)

	--总的掉血量
	--totalDamage = math.floor( totalDamage )
	--玩家
	local ply = data["player"]
	

	--只记录boss的
	if ply.isBoss then
		self:setObjectVisible("dmg", true)
		--掉落箱子
		--这里是掉落宝箱
		local old_reward_num = self.reward_maxnum
		self:dropBox(totalDamage);
		--计算boss血量
		self:caculateHpBar(ply,totalDamage, old_reward_num)
	end
end

---@param eventData Battle_HandleData_MaxHpChanged
function M:playerMaxHpChanged(eventName, eventData)
	if SceneManager:getCurSceneModel().mode == Battle.BattleGlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
		if eventData.player.isBoss then
			self.m_model.m_boss_max_hp = GlobalTools:ToFloat(eventData.player.data:get_hp())
		end
	end
end

function M:caculateWorldBossHpBar(totalDamage)
	local max_hp = self.m_model.m_boss_max_hp
	local cur_part, cur_hp_percent, total_hp_percent = self.m_model:getWorldBossHp(totalDamage)
	local hp_color_index = cur_part + 1
	local hp_bg_color_index = cur_part + 2
	return cur_hp_percent, hp_color_index, hp_bg_color_index
end

function M:getBossAtkAddLayer(totalDamage, cur_max_num)
	local temp_atk_num = cur_max_num
	for i = cur_max_num, #(self.lost_hp) do
		if  self.lost_hp[i] ~= nil and totalDamage > self.lost_hp[i] then
			temp_atk_num = i
		end
	end
	return temp_atk_num
end

--计算血量
function M:caculateHpBar( ply,totalDamage, old_reward_num )
	local last_hp = 0
	self.atk_max_num = 0
	self.lastnum = 0
	
	local function updateHpColorNum(maxnum)
		local num = maxnum  % #self.bossHpColor
		if num <= 0  then
			if self.lastnum > #self.bossHpColor then
				self.lastnum = 1
			end
			num = self.lastnum +1
		end
		self.lastnum = num
		if num > #self.bossHpColor  then
			num = num - #self.bossHpColor
		end
		self.color = self.boss_hpValue.color
		self.color.a = 1
		self.boss_hpValue.color = self.bossHpColor[num]
	end
	if self.lost_hp[self.maxnum] ~= nil and totalDamage > self.lost_hp[self.maxnum] then
		ply.dmg_layer = self.maxnum
		self.maxnum = self:getBossAtkAddLayer(totalDamage, self.maxnum)
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW or self.m_model.m_mode  == GlobalConfig.BATTLE_MODE.DRAGONSWORD
				or self.m_model.m_mode  == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS 
				or self.m_model.m_mode  == GlobalConfig.BATTLE_MODE.COMMON_BATTLE 
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
			updateHpColorNum(self.maxnum)
		end
	end
	
	self.atk_max_num = self.maxnum
	self.boss_hpBg.color = self.color
	
	self.dmg.text = totalDamage
	self.boos_totalDamage = totalDamage
	local num_text = ""
	if self.atk_max_num > 0 then
		num_text = "x"..self.atk_max_num
	end
	self.passivity.text = num_text
	
	local cur_lost_hp = self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS and self.reward_lost_hp or self.lost_hp
	local cur_max_num = self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS and self.reward_maxnum or self.maxnum
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
		cur_lost_hp = self.lost_hp
		cur_max_num = self.maxnum
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
		cur_lost_hp = self.reward_lost_hp
		cur_max_num = self.reward_maxnum
	end
	local cue_lostHp = cur_lost_hp[cur_max_num-1] or cur_lost_hp[#cur_lost_hp] or 1
	local target = 0
	last_hp = cur_lost_hp[cur_max_num-1] or 0
	target = ((totalDamage -last_hp) /(cue_lostHp - last_hp))
	if totalDamage >= last_hp then
		self.bosshp_slider.value =1
		if target > 1 then
			target = target - 1
		end
	end

	if self.bosshp_slider.value > target then
		self.bosshp_slider.value = Mathf.Min(self.bosshp_slider.value + (0.1*0.02),target)
	elseif self.bosshp_slider.value < target then
		target = 1
		self.bosshp_slider.value = Mathf.Min(self.bosshp_slider.value + (0.1*0.02),target)
		if self.bosshp_slider.value >= 1 then
			self.bosshp_slider.value = 0
		end
	end

	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
		local cur_hp_percent, hp_color_index, hp_bg_color_index = self:caculateWorldBossHpBar(totalDamage)
		self.boss_hpValue.color = self.bossHpColor2[hp_color_index]
		self.boss_hpBg.color = self.bossHpColor2[hp_bg_color_index]
		self.bosshp_slider.value = 1 - cur_hp_percent
		local total_hp_percent = math.max(0, (1 - totalDamage / self.m_model.m_boss_max_hp ))
		self.dmg.text = string.format("%.2f", (total_hp_percent *100 )) .. "%"
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
		local cur_hp_percent, hp_color_index, hp_bg_color_index = self:caculateWorldBossHpBar(totalDamage)
		self.boss_hpValue.color = self.bossHpColor2[hp_color_index]
		self.boss_hpBg.color = self.bossHpColor2[hp_bg_color_index]
		self.bosshp_slider.value = 1 - cur_hp_percent
		local total_hp_percent = math.max(0, (1 - totalDamage / self.m_model.m_boss_max_hp ))
		self.dmg.text = string.format("%.2f", (total_hp_percent *100 )) .. "%"
	end
end


--boss掉落宝箱
function M:dropBox( totalDamage )
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS or
			self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS or
			self.m_mode == GlobalConfig.BATTLE_MODE.UNION_BOSS then
		--要飞往的坐标
		local pos = UIUtil.UITo3D(self.treasure.transform.position);
		--总伤害
		if self.reward_lost_hp[self.reward_maxnum] ~= nil and totalDamage > self.reward_lost_hp[self.reward_maxnum] then
			if  self.reward_maxnum <= table.nums(self.reward_lost_hp) then
				--创建宝箱
				local obj = ResourceUtil:LoadCommonEffect("Fx_Boss_BaoXiang",nil)
				self.boss_data:add(obj)
				--宝箱动画
				if SceneManager.curScene ~= nil then
					SceneManager.curScene:DoPath(obj,self.boss_data,self.treasure,function( ... )
						local shutiao = obj.transform:Find("LOD0 _Boss_BaoXiang_07").transform:Find("Fx_Boss_BaoXiang_04")
						shutiao.gameObject:SetActive(true)
					end)
				end
				self.reward_maxnum = self.reward_maxnum + 1

				if self.destroyBox == false then
					self.destroyBox = true;
					--5秒后所有的宝箱回收一次
					self.m_control:setOnceTimer(5, function()
						for i = self.boss_data.Count, 1, -1 do
							local obj = self.boss_data:get(i -1)
							if obj ~= nil and SceneManager.curScene ~= nil then
								local shutiao = obj.transform:Find("LOD0 _Boss_BaoXiang_07").transform:Find("Fx_Boss_BaoXiang_04")
								shutiao.gameObject:SetActive(false)
								local scale = obj.transform.localScale
								scale.x = 0.5
								scale.y = 0.5
								scale.z = 0.5
								obj.transform.localScale = scale
								SceneManager.curScene:MoveToPath(obj,obj.transform.position,pos,0,0.4, false,function( ... )
									self.count = self.count + 1
									ResourceUtil:ReturnItem(obj)
									self.treasure_count.text = self.count
								end)
							end
						end
						self.boss_data:clear();
						self.destroyBox = false;
					end)
				end
			end
		end
		
	end
end


function M:clearSkillBtns()
	-- 移除
	for i=1,self.skillBtns.Count,1 do
		local btn = self.skillBtns:get(i-1)
		btn:destroy()
	end
	self.skillBtns:clear()
	UIUtil.destroyAllChild(self.cardNode.transform)
end

function M:addSkillBtns()
	if self.m_model.m_mode==GlobalConfig.BATTLE_MODE.RTA_ARENA then
		self.cardNode.gameObject:SetActive(false)
		return
	end
	-- 移除
	self:clearSkillBtns()

	local playerList = SceneManager:getCurSceneModel().plyMgr:getPlayers(1)
	local flag = true
	for i=1,playerList.Count do
		if flag then
			flag = false
			for j = playerList.Count,i+1, -1 do
				if playerList:get(j-1).index < playerList:get(j-2).index then
					local temp = playerList:get(j-1)
					playerList:set(j-1, playerList:get(j-2));
					playerList:set(j-2, temp)
					flag = true
				end
			end
		else
			break;
		end	
	end

	local len = playerList.Count;
	local startPos_x = 0
	if len == 1 then
		startPos_x = 0;
	elseif len == 2 then
		startPos_x = -70;
	elseif len == 3 then
		startPos_x = -141;
	elseif len == 4 then
		startPos_x = -210;
	elseif len == 5 then
		startPos_x = -282;
	end
	local rect = self.m_rt.rect
	local aspRatio = rect.width/1280
	if aspRatio < 1 and aspRatio > 0 then
		self.cardNode.transform.localScale = Vector3.New(aspRatio, aspRatio, aspRatio)
	end
	for i=1,playerList.Count do
		local player = playerList:get(i-1)
		if player.master == nil then
			local btn = SkillButton.new()
			--Vector3(startPos_x+142*(i-1),-525,0)
			btn:init(player, i, self.cardNode.transform, "icon_zhero_01", self.m_control, self.is_horizontally, aspRatio)
			self.skillBtns:add(btn)
		end
	end
	for i=1,self.skillBtns.Count,1 do
		local btn = self.skillBtns:get(i-1)
		self:setParticleRenderOrder(btn.obj)
	end
end

function M:timeUpdateHandler( eventName, data )
	if self.panelLive == true then
		local timeData = data["time"]
		self.time = math.modf( tonumber(timeData) );
		if self.timeText ~= nil then
			if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LEGEND then
				if self.m_model.m_data.battle.common.battle_mode == 3 then
					local curTimeData = GlobalTools:ToFloat(data["cur_time"])
					local curTime = math.modf( tonumber(curTimeData) )
					self:refreshNum(curTime, self.live_time_content, self.live_time_content_luaBehaviour)

					self:refreshLegendCountDown(math.modf(GlobalTools:ToFloat(SceneManager.curScene.legendNextRefreshTime - data["cur_time"])))
					self:refreshLegendRecord(math.floor(GlobalTools:ToFloat(data["cur_time"])))
				end
				self.legend_timeText.text = self:formatTime(self.time);
			else
				self.timeText.text = self:formatTime(self.time);
			end
		end
	end
end
	

function M:formatTime( time )
	local format = "00:00"
	local minite = math.modf( time/60 )
	local second = time - minite * 60
	local minite_str = "00"
	local second_str = "00"
	if minite > 0 then
		if minite < 10 then
			minite_str = "0"..minite
		else
			minite_str = ""..minite
		end
	end
	if second > 0 then
		if second < 10 then
			second_str = "0"..second
		else
			second_str = ""..second
		end
	end
	format = minite_str..":"..second_str;
	return format;
end

function M:blackOver( eventName, data )
	local player = data["data"]
	for i=1,self.skillBtns.Count,1 do
		local btn = self.skillBtns:get(i-1)
		if btn.player == player then 
			btn:blackOver()
		end
	end
end


function M:hpUpdateHandeler( eventName, data )
	local player = data["data"]
	for i=1,self.skillBtns.Count,1 do
		local btn = self.skillBtns:get(i-1)
		if btn.player == player then 
			btn:hpUpdateHandeler(data["hp"])
		end
	end
end


function M:playerDead(eventName, data)
	local player = data["data"]
	local deadBtn = nil;
	for i=1,self.skillBtns.Count,1 do
		local btn = self.skillBtns:get(i-1)
		if btn.player == player then
			deadBtn = btn;
			btn:playerDead()
		end
	end

	if deadBtn ~= nil then
		self.skillBtns:remove(deadBtn);
	end
end


function M:angerUpdateHandler( eventName, data )
	local player = data["data"]
	for i=1,self.skillBtns.Count,1 do
		local btn = self.skillBtns:get(i-1)
		if btn.player == player then 
			btn:angerUpdateHandler(data["angerValue"])
		end
	end
end


--怒气满了
function M:angerMaxHandler( eventName, data )
	local player = data["data"]
	for i=1,self.skillBtns.Count,1 do
		local btn = self.skillBtns:get(i-1)
		if btn.player == player then 
			btn:playerSkillOkHandler()
		end
	end
end


function M.ISNullObj_Active(obj)
	if not IsNull(obj) then
		obj:SetActive(false)
	end
end

--游戏结束隐藏卡牌
function M:HideCards()
	--for k,v in pairs(playerSkills) do
	--	v:SetActive(false)
	--end
end

--游戏结束胜利界面
function M:GameOver()
	self.gameOver:SetActive(true)
	self:HideCards()
end

--点击自动战斗按钮
function M:AutoClickButton()
	-- SceneManager.Inst.mPlayerMgr.autoSkill = !SceneManager.Inst.mPlayerMgr.autoSkill;
end


---斗气恢复
function M:FightScoreRecoverHandler(data)
	--if data.mType == Hero then
	-- 	if data.recovery then
	-- 		self.m_hero_pingpang:Play()
	-- 	else 
	-- 		self.m_hero_pingpang:Stop()
	-- 	end
	-- 	self.m_hero_MaskSlider:set_Value( )--1- FightScoreManager.Inst.hero.GetFightScorePercent)
	--else
	--	if data.recovery then
	-- 		self.m_enemy_pingpang:Play()
	-- 	else 
	-- 		self.m_enemy_pingpang:Stop()
	-- 	end
	-- 	self.m_enemy_MaskSlider:set_Value()
	--end
end


function M:setSpeed2(bl)
	if self.is_horizontally == true then
		local speed_num = TimeManager.maxTimeSpeed - 0.5
		if bl <= speed_num then
			self:setObjectVisible("h_speed2_selected",false)
			--GameUtil:setLanImgText(self:findRectTransform("h_speed2"), "a_zd_btn_jiasu")
		else
			local obj = self:setObjectVisible("h_speed2_selected",true)
			UIUtil.findText(obj.transform,"Text").text = (bl < TimeManager.maxmaxTimeSpeed - 0.5) and "x2" or "x4"
			--GameUtil:setLanImgText(self:findRectTransform("h_speed2"), "a_zd_btn_jiasu_h")
		end	
	end
end

function M:setAuto(bl)
	if self.is_horizontally == true then
		local battle_auto_first = UserDataManager.local_data:getUserDataByKey("battle_auto_first", 0)
		if bl == 1 then
			self:setObjectVisible("h_auto_selected",true)
			--GameUtil:setLanImgText(self:findRectTransform("h_auto"), "a_zd_btn_zidong_h")
			if battle_auto_first == 0 then
				UserDataManager.local_data:setUserDataByKey("battle_auto_first", 1)
				self:setObjectVisible("UI_Formation_TiShi_001", false)
			end
		else
			self:setObjectVisible("h_auto_selected",false)
			--GameUtil:setLanImgText(self:findRectTransform("h_auto"), "a_zd_btn_zidong")
			if (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE) and battle_auto_first == 0 then
				local stage = UserDataManager:getBattleStage()
				if stage > 5 then
					self:setObjectVisible("UI_Formation_TiShi_001", true)
				end
			end
		end
	end
end

function M:setBuffLv(cur_round)
	local hero_buff_data =self.m_model:getAddBuffLv(cur_round)
	local enemy_buff_data =self.m_model:getEnemyAddBuffLv(cur_round)
	local h_heroBuff = self:findGameObject("h_heroBuff")
	local h_enemyBuff = self:findGameObject("h_enemyBuff")
	GameUtil:updateBuffShow(h_heroBuff, hero_buff_data)
	GameUtil:updateBuffShow(h_enemyBuff, enemy_buff_data)
end

function M:useSkill(playerIndex)
	for i = 1, self.skillBtns.Count do
		if self.skillBtns:get(i - 1).player.index == playerIndex and self.skillBtns:get(i - 1).player.master == nil then
			self.skillBtns:get(i - 1):useSkill()
		end
	end
end

function M:refreshCardEffect(playerIndex, show)
	for i = 1, self.skillBtns.Count do
		if self.skillBtns:get(i - 1).player.index == playerIndex then
			self.skillBtns:get(i - 1):showEffect(show)
		end
	end
end

function M:getArenaInfoNode()
	local left_arena_info_node = nil
	local right_arena_info_node = nil
	if self.is_horizontally == true then
		self:setObjectVisible("h_vs_info_node", self.m_model:isShowVSFlag())
		left_arena_info_node = self:findGameObject("h_left_arena_info_node")
		right_arena_info_node = self:findGameObject("h_right_arena_info_node")
	else
		self:setObjectVisible("vs_info_node", self.m_model:isShowVSFlag())
		left_arena_info_node = self:findGameObject("left_arena_info_node")
		right_arena_info_node = self:findGameObject("right_arena_info_node")
	end
	return left_arena_info_node, right_arena_info_node
end

function M:setVSInfo(round)
	local left_arena_info_node, right_arena_info_node = self:getArenaInfoNode()
	self:setUserInfo(left_arena_info_node, round, 1)
	self:setUserInfo(right_arena_info_node, round, 2)
end

function M:setUserInfo(obj, round, sort)
	local user = self.m_model:getUserInfoBySort(sort)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_name_text", tostring(user.name))
	local player_head_node = luaBehaviour:FindGameObject("player_head_node")
	GameUtil:setUserAvatar(player_head_node, user,nil,nil,{show_flag = true, scale = 1})
	local results = self.m_model:getBattleResults()
	local team_nums = 3
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA then
		team_nums = 2
	end
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ZF_ARENA_MUL then
		team_nums = self.m_model.m_team_nums
	end
	for i = 1, 3 do
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "team_img_"..tostring(i), false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "battle_result_"..tostring(i), false)
	end
	for i = 1, team_nums do
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "team_img_"..tostring(i), true)
		local result = results[i] or 0
		local battle_result = luaBehaviour:FindGameObject("battle_result_" .. i)
		if sort == 1 then
			GameUtil:setLanImgText(battle_result, result == 1 and "a_jjc_sheng" or "a_jjc_bai")
		else
			GameUtil:setLanImgText(battle_result, result ~= 1 and "a_jjc_sheng" or "a_jjc_bai")
		end
		battle_result:SetActive(round > i)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_round_text_" .. i, "upper_num_str_000" .. i)
	end
end

function M:setResultInfo(round)
	if not GlobalConfig.BATTLE_MODE_CFG[self.m_model.m_mode].pvp and not self.m_model.m_replay then
		local left_arena_info_node, right_arena_info_node = self:getArenaInfoNode()
		self:showRoundResult(left_arena_info_node, round, 1)
		self:showRoundResult(right_arena_info_node, round, 2)
	end
end

function M:showRoundResult(obj, round, sort)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local round_data = SceneManager.curScene.tongjiData:getRoundData(round)
	local result = round_data.result or 0
	local battle_result = luaBehaviour:FindGameObject("battle_result_" .. round)
	if sort == 1 then
		GameUtil:setLanImgText(battle_result, result == 1 and "a_jjc_sheng" or "a_jjc_bai")
	else
		GameUtil:setLanImgText(battle_result, result ~= 1 and "a_jjc_sheng" or "a_jjc_bai")
	end
	battle_result:SetActive(true)
end

function M:showRoundNode(round)
	round = round or 1
	if self.is_horizontally ==true then
		self:setObjectVisible("h_round_node", true)
	else
		self:setObjectVisible("round_node", true)
	end
	local round_text_img = self:findGameObject("round_text_img")
	if round > 0 and round < 4 then
		-- jjc_1huihe jjc_2huihe jjc_3huihe
		GameUtil:setLanImgText(round_text_img, "a_jjc_huihe" .. round)
		if round > 1 then
			self:setResultInfo(round - 1)
		end
	end
end

function M:hideRoundNode()
	if self.is_horizontally ==true then
		self:setObjectVisible("h_round_node", false)
	else
		self:setObjectVisible("round_node", false)
	end	
end

function M:addBattleVS()
	if self.m_model.m_mode==GlobalConfig.BATTLE_MODE.RTA_ARENA then
		local BattleVSNode = CustomRequire("UI.Arena.ArenaRTA.BattleVSNode")
		self.m_battle_vs_node = BattleVSNode.new(self.m_control)
	else
		local BattleVSNode = CustomRequire("UI.GamePanel.BattleVSNode")
		self.m_battle_vs_node = BattleVSNode.new(self.m_control)
	end
end

function M:removeBattleVS()
	if self.m_battle_vs_node then
		self.m_battle_vs_node:destroy()
		self.m_battle_vs_node = nil
	end
end

function M:handlerStopBtn()
	if self.m_model.m_is_stop then
		--self:setObjectVisible("h_stop_select",true)
		--GameUtil:setLanImgText(self:findRectTransform("h_stop"), "a_zd_btn_zanting")
	else
		--self:setObjectVisible("h_stop_select",false)
		--GameUtil:setLanImgText(self:findRectTransform("h_stop"), "a_zd_btn_zanting")
	end
end

--显示伤害奖励
function M:showReward(dmg)
	for	k,v in pairs(self.lost_hp_list) do
		if v.is_show == false then
			if dmg >= v.dmg then 
				v.is_show = true
				local boss = SceneManager.curScene.plyMgr:getEnemyByIndex(0)
				if boss then
					for i=1,5 do
						local drop = require("Battle.Sce.DropObj").new()
						local x = math.random(10, 30)
						local y = math.random(5,9)
						local z = math.random(0,6)
						drop:init("DropObj",boss.spine.transform.position, -x,y,z);
						table.insert(self.drop_list, drop)
					end
					for i=1,3 do
						local drop = require("Battle.Sce.DropObj").new()
						local x = math.random(10,30)
						local y = math.random(5,9)
						local z = math.random(0,6)
						drop:init("DropObj1", boss.spine.transform.position, -x,y,z);
						table.insert(self.drop_list, drop)
					end
					for i=1,1 do
						local drop = require("Battle.Sce.DropObj").new()
						local x = math.random(10,30)
						local y = math.random(5,9)
						local z = math.random(0,6)
						drop:init("DropObj2", boss.spine.transform.position, -x,y,z);
						table.insert(self.drop_list, drop)
					end
				end
			end
		end
	end
end	

function M:palyBeginAnim(callback)
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA_DEFENSE
			or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA_DEFENSE then
		self:setObjectVisible("battle_begin", false)
		self:setObjectVisible("pet_battle_begin1", false)
		self:setObjectVisible("pet_battle_begin2", false)
		callback()
	elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
		self:setObjectVisible("battle_begin", false)
		audio:SendEvtUI("UI_Pat_Battel")
		self:setObjectVisible("pet_battle_begin1", true)
		self:setObjectVisible("pet_battle_begin2", false)
		callback()
	else
		self:setObjectVisible("pet_battle_begin1", false)
		self:setObjectVisible("pet_battle_begin2", false)
		self:setObjectVisible("battle_begin", true)
		local function endduijue(msg)
			callback()
		end
		
		local luaBehaviour = UIUtil.findLuaBehaviour(self.battle_begin)

		if luaBehaviour then
			local anim = luaBehaviour:FindAnimationState("battle_begin","Duijue")
			anim.speed = self.m_model.m_speed2
			luaBehaviour:RunAnim("Duijue", nil, 1)
			self.m_control:setOnceTimer(1.2, endduijue)
		end
		audio:SendEvtUI("Ui_Duijue")
	end
	self.m_control:setOnceTimer(2, function()
		if not (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_MINING
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MINING
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI)  then
			self:setObjectVisible("h_stop", self.m_model:getBoolByCom(2) == true and not(self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS) )
		elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS  then
			self:setObjectVisible("h_stop", false)
		end
	end)
end

function M:showPetContestStart(data)
	local callback = data.callback
	self:setObjectVisible("pet_contest", true)
	self.m_control:setOnceTimer(1, function()
		self:setObjectVisible("pet_battle_begin1", false)
	end)
	self.m_control:setOnceTimer(3, function()
		if callback then
			callback()
		end
	end)
end

function M:showPetContestResult(data)
	local callback = data.callback
	audio:SendEvtUI("UI_Pat_Battel")
	self:setObjectVisible("pet_battle_begin2", true)
	self.m_control:setOnceTimer(1, function()
		self:setObjectVisible("pet_contest", false)
		self:setObjectVisible("pet_battle_begin2", false)
		self:setObjectVisible("quick_pass_btn", true)
		if callback then
			callback()
		end
	end)
end

function M:refreshNum(num, rect, luaBehaviour)
	local num_str = tostring(num)
	--rect.anchoredPosition = Vector2.New(50 + (string.len(num_str)-1)*8,0)
	for i = 1, 4 do
		if i <= string.len(num_str) then
			LuaBehaviourUtil.setImg(luaBehaviour, "num"..tostring(i), "a_jhcg_"..string.sub(num_str,i,i), "main_ui")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num"..tostring(i), true)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num"..tostring(i), false)
		end
	end
end

function M:refreshKillNum(num, isPercent, noEffect)
	if isPercent == true then
		num = tostring(num) .."%"
	end
	self:refreshNum(num, self.kill_num_content, self.kill_num_content_luaBehaviour)

	if noEffect ~= true then
		if type(num) == "string" or num > 0 then
			if self.kill_num_sequence == nil then
				self.kill_num_sequence = Tweening.DOTween.Sequence()
				self.kill_num_sequence:Append(self.kill_num_content:DOScale(2,0.3):SetEase(Tweening.Ease.OutSine))
				self.kill_num_sequence:Append(self.kill_num_content:DOScale(1,0.15):SetEase(Tweening.Ease.OutSine))
				self.kill_num_sequence:OnComplete(function()
					self.kill_num_sequence = nil
				end)
			end
			if self.kill_num_timer == nil then
				self:setObjectVisible("UI_GamePanel2_ShaDi_01",  true)
				self.kill_num_timer = self.m_control:setOnceTimer(0.3, function()
					self:setObjectVisible("UI_GamePanel2_ShaDi_01",  false)
					self.kill_num_timer = nil
				end)
			end
		end
	end
end

function M:refreshLegendCountDown(num)
	if self.legend_last_CountDown ~= num then
		self:refreshNum(num, self.legend_refreshTime_content, self.legend_refreshTime_content_luaBehaviour)
		
		if self.refreshTime_sequence == nil then
			self.refreshTime_sequence = Tweening.DOTween.Sequence()
			self.refreshTime_sequence:Append(self.legend_refreshTime_content:DOScale(2,0.3):SetEase(Tweening.Ease.OutSine))
			self.refreshTime_sequence:Append(self.legend_refreshTime_content:DOScale(1,0.15):SetEase(Tweening.Ease.OutSine))
			self.refreshTime_sequence:OnComplete(function()
				self.refreshTime_sequence = nil
			end)
		end
		self.legend_last_CountDown = num
	end
end

function M:refreshLegendRecord(cur_num)
	local record = self.m_model.m_legend_data.progress[tostring(SceneManager.curScene.legend_stage_cfg.type)] or 0
	if record > 0 then
		local num = math.floor(record - cur_num)
		if num >= 0 then
			self:setObjectVisible("legend_record_content", true)
			self:setObjectVisible("legend_record_text2", true)
			self:refreshNum(num, self.legend_record_content, self.legend_record_content_luaBehaviour)
		else
			if self.legend_new_record ~= true then
				self.legend_new_record = true
				self:setTextByLanKey("legend_record_text", "legend_str_030")
				self:setObjectVisible("legend_record_text2", false)
				self:setObjectVisible("legend_record_content", false)
			end
		end
	else
		if cur_num > 0 then
			self.legend_new_record = true
		end
	end
end

function M:destroy()
	self.m_control:removeTimer(self.kill_num_timer)
	self:removeBattleVS()
	EventDispatcher:unRegisterEvent("BlackOver",{self,self.blackOver})
	EventDispatcher:unRegisterEvent("AngerMax",{self,self.angerMaxHandler})
	EventDispatcher:unRegisterEvent("AngerUpdate",{self,self.angerUpdateHandler})
	EventDispatcher:unRegisterEvent("HpUpdate",{self,self.hpUpdateHandeler})
	EventDispatcher:unRegisterEvent("TimeUpdate",{self,self.timeUpdateHandler})
	EventDispatcher:unRegisterEvent("PlayerDead",{self,self.playerDead})
	EventDispatcher:unRegisterEvent("addSkillBtns",{self,self.playerDead})
	EventDispatcher:unRegisterEvent("calculateDamage", {self,self.calculateDamageHandler})
	EventDispatcher:unRegisterEvent("MaxHpChanged",{self,self.playerMaxHpChanged})
	self.panelLive = false;

	for i = 1, self.skillBtns.Count do
		local btn = self.skillBtns:get(i-1)
		btn:destroy();
	end
	self.skillBtns:clear()

	if self.boss_data ~= nil then
		for i = self.boss_data.Count, 1, -1 do
			local obj = self.boss_data:get(i -1)
			if obj ~= nil then
										
				ResourceUtil:ReturnItem(obj)
			end
		end
	end
	if not IsNull(self.m_skill_obj) then
		ResourceUtil:ReturnItem( self.m_skill_obj)
		self.m_skill_obj = nil
	end

	M.super.destroy(self)
end

return M