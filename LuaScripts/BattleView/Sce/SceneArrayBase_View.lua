--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-05-06 10:18:58
]]

--场景的视图层
---@class SceneArrayBase_View : Scene_View @
---@field super Scene_View @Scene_View
local M = class("SceneArrayBase_View",Battle.Scene_View)

local __drag_hero_index = 99

function M:init( model )
	M.super.init(self, model)
	self.heroDetailIndex = 0;
    self.mouseDownTime = 0;
    self.mouseUpTime = 0;
	self.mouseDown_durTime = 0.2;
	self.changeMaterialId = 0;
	self.changeMaterialTween = nil
	self.curChangeMaterial = nil;
	self.curPlayMat = 0;
	self.unlockFinish = false;
	self.standEffect_hero = Battle.List.new();
	self.standEffect_enemy = Battle.List.new();
	
	--新剧情
	self.storyNewMgr = require("Battle.Sce.Tools.SceneStoryNewMgr").new();
	self.storyNewMgr:init();
	
	--人物进入战斗之前的说话剧情控制器
	self.story = require("Battle.Sce.Tools.SceneStoryMgr").new();
	self.story:init();
	
	--战斗开始事件
	self:addEventListener_Local(Battle.EventType.MV_SceneModelBattleStart,{self,self.MV_SceneModelBattleStart})
	--战斗一次
	self:addEventListener_Local(Battle.EventType.MV_SceneModelBattleOnce,{self,self.MV_SceneModelBattleOnce})
	--更新UI
	self:addEventListener_Local(Battle.EventType.MV_SceneModelUpdatePlayerUI,{self,self.MV_SceneModelUpdatePlayerUI})
	--创建特效
	self:addEventListener_Local(Battle.EventType.MV_SceneModelCreateEffect,{self,self.MV_SceneModelCreateEffect})
	--布阵开始
	self:addEventListener_Local(Battle.EventType.MV_SceneModelArray,{self,self.MV_SceneModelArray})
	--更新阵型
	self:addEventListener_Local(Battle.EventType.MV_SceneModelUpdateDeployment,{self,self.MV_SceneModelUpdateDeployment})
	--玩家出生
	self:addEventListener_Local(Battle.EventType.MV_SceneModelPlayerSpawn, {self, self.MV_SceneModelPlayerSpawn})
	--刷新UI
	self:addEventListener_Local(Battle.EventType.MV_SceneModelResetUI, {self, self.MV_SceneModelResetUI})
	--处理相机和特效
	self:addEventListener_Local(Battle.EventType.MV_SceneModelHandleEffectAndCamera, {self,self.MV_SceneModelHandleEffectAndCamera})
	--下阵处理
	self:addEventListener_Local(Battle.EventType.MV_SceneModelGoDownBattle, {self, self.MV_SceneModelGoDownBattle})
	--游戏结束
	self:addEventListener_Local(Battle.EventType.MV_SceneModelGameOver, {self,self.MV_SceneModelGameOver})
	--配置战斗开始
	self:addEventListener_Local(Battle.EventType.MV_SceneModelConfigStart, {self, self.MV_SceneModelConfigStart})
	
	--宠物
	self:addEventListener_Local(Battle.EventType.MV_SceneModel_PetContestStart, {self, self.MV_SceneModel_PetContestStart})
	self:addEventListener_Local(Battle.EventType.MV_PetContestResult, {self, self.MV_PetContestResult})
	
end

---宠物比气势开始
function M:MV_SceneModel_PetContestStart()
	--播放战斗的文字特效q
	self:sendEvent("pet_contest_start",{
		callback = function()
			self:dispatchEvent_Local(Battle.EventType.VM_SceneModel_PetContestStart)
		end
	},"GamePanel");
end

---宠物比气势结果
function M:MV_PetContestResult(eventName, eventData)
	--播放战斗的文字特效q
	self:sendEvent("pet_contest_result",{
		data = eventData,
		callback = function()
			self.plyMgr:removePetPowerItem()
			self.plyMgr:showPetHpNode()
			self:dispatchEvent_Local(Battle.EventType.VM_SceneModel_PetContestResult)
		end
	},"GamePanel");
end


function M:get_story()
	return self.story;
end

--设定相机高度
function M:SetCameraHeight( type )
	if type == 1 then
		self.startSetCamera = true;
		self.cameraController:MoveHeight(-1.1,0.5,nil)
		self.cameraController:RotaToHeight(1.4,0.5,nil)
		TimeTools:delayTimeUnity(0.5, function()
			self.startSetCamera = false;
		end)
	else
		self.startSetCamera = true;
		self.cameraController:MoveHeight(0,0.3,nil)
		self.cameraController:RotaToHeight(0,0.3,nil)
		TimeTools:delayTimeUnity(0.3, function()
			self.startSetCamera = false;
		end)
	end
end


function M:MV_SceneModelConfigStart( eventName, data )
	--播放战斗的文字特效q
	self:sendEvent("battle_anim",{
		callback = function()
			self:dispatchEvent_Local(Battle.EventType.VM_SceneViewCallBattleStart)
		end
	},"GamePanel");
end


function M:MV_SceneModelGameOver( eventName, data )
	--动画改成受到TimeScale影响
	U3DUtil:SetUnScale(false)
	if not IsNull(SceneManager:getCurSceneView().cameraController) then
		--把黑屏设置亮
		SceneManager:getCurSceneView().cameraController:BlackScreen(false);
	end
end

--下阵处理
function M:MV_SceneModelGoDownBattle( eventName, data )
	self:goDownBattle()
end

--特效和相机处理
function M:MV_SceneModelHandleEffectAndCamera( eventName, data )
	if data.type == 1 then
		self:DeleteEffectAndCamera();
	end
end

--刷新UI
function M:MV_SceneModelResetUI( eventName, data )
	self:resetUI();
end

--玩家出生结束了
function M:MV_SceneModelPlayerSpawn( eventName, data )
	if self.enterData.m_move_camera == 1 then
		self:setCameraInfo(true,"gve")
	else
		self:setCameraInfo(true)
	end
	if self.story:hasStory() then
		self:sendEvent("show_view",nil,"GamePanel");
	end
	self:sendEvent("battle_anim",{ callback = function()
		TimeTools:delayTimeUnity(0.6, function()
			EventDispatcher:dipatchEvent("addSkillBtns")
			self:dispatchEvent_Local(Battle.EventType.VM_SceneViewSetPlayerAttr)
			self:dispatchEvent_Local(Battle.EventType.VM_SceneViewCallBattleStart)
			if self.mode == GlobalConfig.BATTLE_MODE.BIG_MAP or self.mode == GlobalConfig.BATTLE_MODE.NEW_BIG_MAP then
				SceneManager:setData("show_loading_black", false)
				static_rootControl:updateMsg("close_battle_loading")
			end
		end)
	end },"GamePanel");
end

function M:MV_SceneModelUpdateDeployment( eventName, data )
	local atk_deployment = data.atk_deployment
	local def_deployment = data.def_deployment
	self:updateDeployment(atk_deployment, def_deployment)
end

function M:MV_SceneModelArray( eventName, data )
	self:setCameraInfo(false)

	GameMain.addUpdate("MouseEvent",handler(self,self.MouseEvent) );
	--玩家的位置信息
	self.playerPositionData = table.copy(data.data);
	if data.config == true then
		self:DeleteEffectAndCamera()
	else
		self:DeleteEffectAndCamera()
		--self:SetEffectAndCamera()
	end
	LikeOO.BattleTalkControl:registerBattleTalk(self.model.mode, {})
end

function M:MV_SceneModelCreateEffect( eventName, data )
	
end

function M:MV_SceneModelUpdatePlayerUI( eventName, data )
	--处理玩家脚底UI
	self.plyMgr:HandleFootUI();
	--设定相机
	self:SetEffectAndCamera(function()
		if SceneManager:getCurSceneModel().mode ~= GlobalConfig.BATTLE_MODE.PET_DOUJI then
			self:createLevelEffect();
		end
	end)
	
	if self.cameraController ~= nil then
		self.cameraController:SetCameraStartPos();
		self.cameraController.OpenTarget = nil;
	end
end
--战斗一次
function M:MV_SceneModelBattleOnce( eventName, data )
	self:battleOnce()
end

--战斗开始
function M:MV_SceneModelBattleStart(eventName, data)
	self:destoryShowObj()
end

--进入场景
function M:enter( data )
	M.super.enter(self, data )
	--self.storyNewMgr:init();
end

--从新设置UI
function M:resetUI()
	if self.story:hasStory() then
		self:sendEvent("hide_view",nil,"GamePanel");
	end
end

--剧情布阵
--初始化剧情关人物信息
function M:arrayingStoryPlayers( callBack )
	self.storyNewMgr:arrayingStoryPlayers( callBack )
end

--设定特效和摄像机
function M:SetEffectAndCamera( callback )
    self:createStandEffect( callback );
    self:setSceneInstancePosition(false);
end

function M:destroy( nextScene )
	M.super.destroy(self, nextScene)
	self:destoryShowObj();
    --站立特效
	self:deleteStandEffect();
	--删除品质特效
	self:deleteLevelEffect();
	if self.storyNewMgr ~= nil then
		self.storyNewMgr:destroyStoryPlayers();
	end
	GameMain.removeUpdate("MouseEvent");
end

--销毁显示物体
function M:destoryShowObj()
	if self.showObj ~= nil then
		ResourceUtil:ReturnItem(self.showObj)
		self.showObj = nil;
    end
end

function M:battleOnce()
	self:DeleteEffectAndCamera()
	local level = UserDataManager:getBattleStage();
end

function M:DeleteEffectAndCamera()
    --站立特效
	self:deleteStandEffect();
	self:deleteLevelEffect();
	self:setSceneInstancePosition(true);
end

--设定场景显示的的位置 
function M:setSceneInstancePosition( isZhanDou )
	if self.sceneObjs ~= nil and self.sceneObjs.Count > 0 then
		if isZhanDou then
			for i=1,self.sceneObjs.Count do
				self.sceneObjs:get(i-1).transform.localPosition = Vector3(0,0,0)
			end
		else
			for i=1,self.sceneObjs.Count do
				self.sceneObjs:get(i-1).transform.localPosition = Vector3(0,0,2.1)
			end
		end
	end
end

--跑剧情
function M:runStory( callBack )
	if self.story:hasStory() then
		--之前是通知游戏界面
		--self:sendEvent("show_black_line",nil,"GamePanel");
		--后来改成通知布阵界面
		--self:sendEvent("show_black_line",nil,"Formation");
		self:sendEvent("show_black_line",nil,"Formation.BeforeStory");
		TimeTools:delayTimeUnity(0.7, function()
			self.story:runningStory(function()
				--self:sendEvent("hide_black_line",nil,"GamePanel");
				--self:sendEvent("hide_black_line",nil,"Formation");
				self:sendEvent("hide_black_line",nil,"Formation.BeforeStory");
				if callBack ~= nil then
					callBack();
				end
			end)
		end)
	else
		if callBack ~= nil then
			callBack();
		end
	end
end

--上阵下阵
function M:go_in_or_out_battle(heroid, heroPos, isAdd, isPet, callBack)
	if isAdd == true then
		if isPet and isPet == true then
			local pos = self.model:findPetSpawnPosition(1,heroPos-1)
			local data,_ = UserDataManager.pet_data:getPetDataById(heroid)
			if data ~= nil then
				data.playerType = "pet"
				local player_model = self:createGoInPet(heroid, data,1, callBack)
				self:PlayShangZhenEffect(pos)
				self:sendEvent("updatePlayerPosData",self.playerPositionData,"Formation")
			end
		else
			local pos = nil
			if SceneManager:getCurSceneModel().mode == Battle.BattleGlobalConfig.BATTLE_MODE.PET_DOUJI then
				pos = self:findPetSpawnPosition(1, heroPos-1)
			else
				pos = self:findSpawnPosition(1, heroPos-1)
			end
			--self:playerEffect(pos,"fx_ui_shangzhen_01",0.6)
			--上阵
			local data,_ = UserDataManager.hero_data:getHeroDataById(heroid)
			if data == nil then
				data = self.model.m_assist_heros[heroid] or self.model.m_legend_heros[heroid]
			end
			if data == nil then
				data = UserDataManager.pet_data:getPetDataById(heroid)
			end
			data.playerType = "player"
			if data ~= nil then
				local player_model = self:createGoInHero(heroid, heroPos, data, pos, callBack)
				
				self:PlayShangZhenEffect(pos)
				
				self.playerPositionData[heroPos] = player_model:get_playerInstanceId()
				self:sendEvent("updatePlayerPosData",self.playerPositionData,"Formation")
			end
		end
	else
		if isPet and isPet == true then
			local player_view = self.plyMgr:getPlayerByInstanceId(heroid);
			if player_view ~= nil then
				local obj = ResourceUtil:LoadCommonEffect("Skill_XiaZhen_001",nil)
				obj.transform.position = player_view:get_position()
				ResourceUtil:ReturnItem(obj);
				--从不删除列表中内删除
				ResourceUtil:AddNoUnLoadBundle(player_view.bundelName,"", true);
				ResourceUtil:AddNoUnLoadBundle(player_view.effectBundleName,"", true);
				player_view:deleteLevelEffect();
				if self.curChangeMaterial ~= nil then
					if self.changeMaterialId ~= 0 then
						player_view.luaViewHelper:ResetMaterial(self.changeMaterialId)
						self.changeMaterialId = 0
					end
				end
				self.model.plyMgr:destoryXieZhanPet(player_view.model, true);
				self:sendEvent("updatePlayerPosData",self.playerPositionData,"Formation")
			end
		else
			local player_view = self.plyMgr:getPlayerByInstanceId(heroid);
			if player_view ~= nil then
				if player_view:checkApostle() then
					self:sendEvent("removeHelperUI", {player = player_view}, "Formation")
				end
	
				local obj = ResourceUtil:LoadCommonEffect("Skill_XiaZhen_001",nil)
				if not IsNull(obj) then
					obj.transform.position = player_view:get_position()
					ResourceUtil:ReturnItem(obj);
				end
				--从不删除列表中内删除
				ResourceUtil:AddNoUnLoadBundle(player_view.bundelName,"", true);
				ResourceUtil:AddNoUnLoadBundle(player_view.effectBundleName,"", true);
				player_view:deleteLevelEffect();
				self.playerPositionData[heroPos] = ""
				if self.curChangeMaterial ~= nil then
					if self.changeMaterialId ~= 0 then
						player_view.luaViewHelper:ResetMaterial(self.changeMaterialId)
						self.changeMaterialId = 0
					end
				end
				self.model.plyMgr:destoryPlayer(player_view.model, true);
				self:sendEvent("updatePlayerPosData",self.playerPositionData,"Formation")
			end
		end
		if callBack ~= nil then
			callBack()
		end
	end
end

function M:PlayShangZhenEffect(pos)
	local obj = ResourceUtil:LoadCommonEffect("Skill_ShangZhen_001",nil)
	if not IsNull(obj) then
		obj.transform.position = pos;
		TimeTools:delayTimeUnity(2, function()
			ResourceUtil:ReturnItem(obj);
		end)
	end
end

function M:getGveBattleConfig()
    local cur_season = UserDataManager:getCurSeason()
	local gve_cfg = ConfigManager:getCfgByName("gve")
	local gve_cfg_season = gve_cfg[cur_season] or {}
	return gve_cfg_season
end

function M:createGoInHero(heroid, heroPos, data, pos, callBack, is_drag)
	if SceneManager:getCurSceneModel() then
		if SceneManager:getCurSceneModel().mode == Battle.BattleGlobalConfig.BATTLE_MODE.GVE_BATTLE or
				SceneManager:getCurSceneModel().mode == Battle.BattleGlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
			local gve_cfg_season = self:getGveBattleConfig()
			local conversion_a = gve_cfg_season.conversion_a or 300 -- 最小等級
			if data and data.lv < conversion_a and data.clv < conversion_a then
				data = table.copy(data)
				data.lv = conversion_a
				data.clv = conversion_a
			end
		elseif SceneManager:getCurSceneModel().mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
			if SceneManager:getCurSceneModel().m_data.level_up == 1 then
				local min_lv = 300 -- 最小等級
				if data and data.lv < min_lv and data.clv < min_lv then
					data = table.copy(data)
					data.lv = min_lv
					data.clv = min_lv
				end
			end
		elseif SceneManager:getCurSceneModel().mode == Battle.BattleGlobalConfig.BATTLE_MODE.MYTH_ARENA or
				SceneManager:getCurSceneModel().mode == Battle.BattleGlobalConfig.BATTLE_MODE.MYTH_ARENA_DEFENSE then
			local show_lvXlsxData = ConfigManager:getCommonValueById(727) or {{3,150},{5,300}}
			local h_cfg = UserDataManager.hero_data:getHeroConfigByCid(data.id)
			local xlsxEvo = h_cfg.evo
			local heroLv = 1
			local commonHeroData1 = show_lvXlsxData[1]
			local commonHeroData2 = show_lvXlsxData[2]
			if xlsxEvo == commonHeroData1[1] then
				heroLv = commonHeroData1[2]
			elseif xlsxEvo == commonHeroData2[1] then
				heroLv = commonHeroData2[2]
			end
			data = table.copy(data)
			data.lv = heroLv
			data.clv = heroLv
		elseif SceneManager:getCurSceneModel().mode == Battle.BattleGlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR then
			local conversion_a = ConfigManager:getCommonValueById(776 or 3300) or 1
			--local lv = math.max(hero_data.lv, hero_data.clv)
			--local r_lv = math.max(lv, conversion_a)
			local heroLv = conversion_a 
			--local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
			--local upgrade_cfg = hero_upgrade[tonumber(r_lv)] or {}
			--heroLv = upgrade_cfg.display_level or 1
			data = table.copy(data)
			data.lv = heroLv
			data.clv = heroLv
		elseif SceneManager:getCurSceneModel().mode == GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_POINT_RACE or SceneManager:getCurSceneModel().mode == GlobalConfig.BATTLE_MODE.TEAM_SORT_FULL_SERVICE_PROMOTION then
			local show_lvXlsxData = ConfigManager:getCommonValueById(778 or 2300) 
			local h_cfg = UserDataManager.hero_data:getHeroConfigByCid(data.id)
			local xlsxEvo = h_cfg.evo
			local heroLv = 1
			local commonHeroData1 = show_lvXlsxData[1]
			local commonHeroData2 = show_lvXlsxData[2]
			if xlsxEvo == commonHeroData1[1] then
				heroLv = commonHeroData1[2]
			elseif xlsxEvo == commonHeroData2[1] then
				heroLv = commonHeroData2[2]
			end
			data = table.copy(data)
			data.lv = heroLv
			data.clv = heroLv
		elseif SceneManager:getCurSceneModel().mode == Battle.BattleGlobalConfig.BATTLE_MODE.AWAKE_SYSTEM then
			local stagecfg = SceneManager:getCurSceneModel().m_ext_data.m_stage_cfg or {}
			local hero_level = stagecfg.max_lv or 300
			data = table.copy(data)
			data.lv = hero_level
			data.clv = hero_level
		elseif SceneManager:getCurSceneModel().mode == Battle.BattleGlobalConfig.BATTLE_MODE.XIAKEDAO or
				SceneManager:getCurSceneModel().mode == Battle.BattleGlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI
		then
			local hero_isle_base_cfg=ConfigManager:getCfgByName("hero_isle_base")
			local hero_level=hero_isle_base_cfg.hero_level or 300
			data = table.copy(data)
			data.lv = hero_level
			data.clv = hero_level
		elseif SceneManager:getCurSceneModel().mode == Battle.BattleGlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE or 
				SceneManager:getCurSceneModel().mode == Battle.BattleGlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE then
			local openJusticeIndex = UserDataManager.local_data:getUserDataByKey("fulwin_arena_is_justice", 0)
			-- 0 不公平，1公平
			if openJusticeIndex == 1 then
				local show_lvXlsxData = ConfigManager:getCommonValueById(721) or {{3,150},{5,300}}
				local h_cfg = UserDataManager.hero_data:getHeroConfigByCid(data.id)
				local xlsxEvo = h_cfg.evo
				local heroLv = 1
				local commonHeroData1 = show_lvXlsxData[1]
				local commonHeroData2 = show_lvXlsxData[2]
				if xlsxEvo == commonHeroData1[1] then
					heroLv = commonHeroData1[2]
				elseif xlsxEvo == commonHeroData2[1] then
					heroLv = commonHeroData2[2]
				end
				data = table.copy(data)
				data.lv = heroLv
				data.clv = heroLv
			end
		end
	end
	local player_model = self.model.plyMgr:createPlayer(data,1,heroPos-1,nil,nil)
	player_model:set_playerInstanceId(heroid)
	player_model.data:set_evo( data.evo );
	if data.clv and data.clv > 0 then
		player_model.data:set_level( data.clv );
	else
		player_model.data:set_level( data.lv );
	end
	if player_model.aiEngine ~= nil then
		player_model.aiEngine.enableAI = true;
	end

	--人物视图创建完成
	player_model.loadPlayerViewFinish = function( player_view )
		if player_model.isDestoryMe == true then
			if callBack ~= nil then
				callBack()
			end
			return
		end
		if SceneManager:getCurSceneModel().mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.PET_DOUJI then
			player_view:createLevelEffect();
		end
		player_view:MakeFootUI();
		--如果是助战英雄
		if player_model:checkApostle() then
			self:sendEvent("createHelperUI", {player = player_view}, "Formation")
		end
		player_view.jianying = ResourceUtil:LoadCommonEffect("Fx_JianYing_01",nil)
		player_view.jianying.transform.position = pos;
		--加入不删除列表
		ResourceUtil:AddNoUnLoadBundle(player_view.bundelName,"", false);
		ResourceUtil:AddNoUnLoadBundle(player_view.effectBundleName,"", false);

		TimeTools:delayTimeUnity(0.1, function()
			if player_view.jianying ~= nil then
				ResourceUtil:ReturnItem(player_view.jianying);
				player_view.jianying = nil;
			end
			if callBack ~= nil then
				callBack()
			end
		end)
		if is_drag then
			self.isMouseDown = true
			self.selectPlayer = player_view
			GameUtil:lookPlayerTips(static_rootControl, self.selectPlayer)
			GameUtil:lookPlayerRelationTips(static_rootControl, self.selectPlayer)
			self.cur_near_index = self.selectPlayer:get_index()
			self.last_near_index = self.cur_near_index
		end
	end
	return player_model
end

function M:createGoInPet(heroid, petData, camp, callBack)
	local player_model = self.model:createNewPet(heroid, petData,camp)
	--人物视图创建完成
	player_model.loadPlayerViewFinish = function( player_view )
		if player_model.isDestoryMe == true then
			if callBack ~= nil then
				callBack()
			end
			return
		end
		player_view:createLevelEffect();
		player_view:MakeFootUI();
		--加入不删除列表
		ResourceUtil:AddNoUnLoadBundle(player_view.bundelName,"", false);
		ResourceUtil:AddNoUnLoadBundle(player_view.effectBundleName,"", false);

		TimeTools:delayTimeUnity(0.1, function()
			if callBack ~= nil then
				callBack()
			end
		end)
	end
	return player_model
end

function M:destroyDragPlayer()
	local player_model = self.model.plyMgr:getHeroByIndex(__drag_hero_index);
	if player_model then
		local player_view = self.plyMgr:getPlayerByInstanceId(__drag_hero_index);
		if player_view ~= nil then--移除预制体
			--从不删除列表中内删除
			ResourceUtil:AddNoUnLoadBundle(player_view.bundelName,"", true);
			ResourceUtil:AddNoUnLoadBundle(player_view.effectBundleName,"", true);
			player_view:deleteLevelEffect();
		end
		self.model.plyMgr:destoryPlayer(player_model, true)
	end
end

--拖动
function M:goDragBattle(heroid, callBack)
	self:destroyDragPlayer()
	local pos = self:findSpawnPosition(1, 1)
	--self:playerEffect(pos,"fx_ui_shangzhen_01",0.6)
	--上阵
	local data,_ = UserDataManager.hero_data:getHeroDataById(heroid)
	if data == nil then
		data = self.model.m_assist_heros[heroid]
	end
	if data ~= nil then
		local player_model = self.model.plyMgr:getPlayerByInstanceId(heroid)
		if player_model == nil then
			self:createGoInHero(heroid, __drag_hero_index + 1, data, pos, callBack, true)
		else
			self.isMouseDown = true
			local player_view = self.plyMgr:getPlayerByInstanceId(heroid);
			self.selectPlayer = player_view
			if callBack ~= nil then
				callBack()
			end
		end
	else
		if callBack ~= nil then
			callBack()
		end
	end
end

--创建站立特效
function M:createStandEffect( callback )
	local sceneInfo = Battle.BattleGlobalConfig.SCENE_ID_INFO[SceneManager:getCurSceneModel().sceneId]
	local heroPoslist = self.heroPoslist
	local enemyPoslist = self.enemyPoslist
	if SceneManager:getCurSceneModel().mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
		heroPoslist = self.petPoslist
		enemyPoslist = self.petEnemyPoslist
	end
	if sceneInfo ~= nil then
		local num = 0;
		
		if sceneInfo.hero_showStand then
			num = num + heroPoslist.Count
		end
		if sceneInfo.enemy_showStand then
			num = num + enemyPoslist.Count
		end
		if sceneInfo.hero_showStand then
			for i=1,heroPoslist.Count do
				ResourceUtil:LoadCommonEffectAsync("Fx_Formation_Grey01", self.obj, function(effect)
					num = num - 1;
					if effect ~= nil then
						effect.transform.position = heroPoslist:get(i-1);
						local canvasObj = effect.transform:Find("Canvas")
						local canvas = canvasObj:GetComponent("Canvas");
						canvas.worldCamera = SceneManager:getCurSceneView().cameraController.Camera_3D
						local textObj = canvasObj.transform:Find("Root").transform:Find("Text");
						local text = textObj:GetComponent("Text");
						text.text = i.."";
						local pos = effect.transform.position;
						pos.y = pos.y + 0.01
						effect.transform.position = pos
						self.standEffect_hero:add(effect);
					end
					if num <= 0 and callback ~= nil then
						callback()
					end
				end)
			end
		end
		if sceneInfo.enemy_showStand then
			for i=1,enemyPoslist.Count do
				ResourceUtil:LoadCommonEffectAsync("Fx_Formation_Grey01", self.obj, function(effect)
					num = num - 1;
					if effect ~= nil then
						effect.transform.position = enemyPoslist:get(i-1);
						local canvasObj = effect.transform:Find("Canvas")
						local canvas = canvasObj:GetComponent("Canvas");
						canvas.worldCamera = SceneManager:getCurSceneView().cameraController.Camera_3D
						local textObj = canvasObj.transform:Find("Root").transform:Find("Text");
						local text = textObj:GetComponent("Text");
						text.text = i.."";
						local pos = effect.transform.position
						pos.y = pos.y + 0.01
						effect.transform.position = pos
						self.standEffect_enemy:add(effect);
					end
					if num <= 0 and callback ~= nil then
						callback()
					end
				end)
			end
		end
	end
end

-- 更新阵法
function M:updateDeployment(atk_deployment, def_deployment)
	self:updateAtkDeployment(atk_deployment)
	self:updateEnemyDeployment(def_deployment)
end

-- 更新攻击方阵法
function M:updateAtkDeployment(deployment)
	self.atkDeployment = deployment
	self:updateDeploymentPos(self.standEffect_hero, deployment, -8)
end

-- 更新敌方阵法
function M:updateEnemyDeployment(deployment)
	self.defDeployment = deployment
	self:updateDeploymentPos(self.standEffect_enemy,deployment, 12)
end

--
function M:updateDeploymentPos(list, deployment, pos_x)
	deployment = deployment or 1
	local deployment_cfg = ConfigManager:getCfgByName("deployment")
	local deployment_cfg_item = deployment_cfg[deployment] or {}
	local key_pos = deployment_cfg_item.key_pos or 0 -- 阵眼序号
	for i = 1, list.Count do
		local effect = list:get(i - 1)
		if effect then
			--local canvasObj = effect.transform:Find("Canvas")
			--local key_buff_icon_tran = canvasObj.transform:Find("Root").transform:Find("key_buff_icon")
			local key_buff_icon_tran = effect.transform:Find("key_buff_icon");
			key_buff_icon_tran.gameObject:SetActive(key_pos == i)
		end
	end
end

--创建品质特效
function M:createLevelEffect()
	local players = self.plyMgr:getPlayers(1);
	for i=1,players.Count do
		local player = players:get(i-1)
		player:createLevelEffect();
	end
	local enemys = self.plyMgr:getPlayers(-1);
	for i=1,enemys.Count do
		local player = enemys:get(i-1)
		player:createLevelEffect();
	end
end

--删除站立特效
function M:deleteStandEffect()
	for i=1,self.standEffect_hero.Count do
		if self.standEffect_hero:get(i-1) then
			ResourceUtil:ReturnItem( self.standEffect_hero:get(i-1) );
		end
	end
	for i=1,self.standEffect_enemy.Count do
		if self.standEffect_enemy:get(i-1) then
			ResourceUtil:ReturnItem( self.standEffect_enemy:get(i-1) );
		end
	end
	self.standEffect_hero:clear();
	self.standEffect_enemy:clear();
end

--删除等级特效
function M:deleteLevelEffect()
	local players = self.plyMgr:getPlayers(1);
	for i=1,players.Count do
		local player = players:get(i-1)
		player:deleteLevelEffect();
	end

	local enemys = self.plyMgr:getPlayers(-1);
	for i=1,enemys.Count do
		local player = enemys:get(i-1)
		player:deleteLevelEffect();
	end
end

--下阵
function M:goDownBattle()
	local data =  { heroid = self.selectPlayer:get_playerInstanceId(), ob = self.selectPlayer:get_index() }
	self:sendEvent("goDownBattle",data,"Formation")
	self.selectPlayer:deleteLevelEffect();
	self.selectPlayer = nil
	self.selectObj = nil
end

-- 新手引导布阵
function M:GuideUpdatePlayerPos(data)
	local check_index = data[1]
	local index = data[2]
	local heroIndexPos = self.heroPoslist:get(index-1)
	local minNearPos = heroIndexPos;
	local index_Player = self.plyMgr:getHeroByIndex(index - 1)

	if self.selectPlayer ~= nil then
		self.selectPlayer:CreateFootUI()
	else
		return
	end
				
	if index_Player ~= nil then
		index_Player.index = check_index-1
		index_Player.tranformHelper.index = check_index-1;

		self.selectPlayer:set_index( index-1 );
		self.selectPlayer.tranformHelper.index = index-1;

		index_Player:updateLevelEffect();
		self.selectPlayer:updateLevelEffect();

		self.playerPositionData[index] = self.selectPlayer:get_playerInstanceId()
		self.playerPositionData[check_index] = index_Player:get_playerInstanceId();
		--更新上传数据										
		self:sendEvent("updatePlayerPosGuide",self.playerPositionData,"Formation")
		self.selectPlayer:changePosition( minNearPos.x, minNearPos.y, minNearPos.z )

		local pos = self:findSpawnPosition(1,index_Player.index);
		index_Player:changePosition( pos.x, pos.y, pos.z )
	else
		if not self.selectPlayer then
			self.scene:sendEvent("updatePlayerPosGuide",self.playerPositionData,"Formation")
			return
		end
		self.selectPlayer:set_index( index-1 )
		self.selectPlayer.tranformHelper.index = index-1;
		self.selectPlayer:updateLevelEffect();

		self.playerPositionData[index] = self.selectPlayer:get_playerInstanceId()
		self.playerPositionData[check_index] = "";
		--更新上传数据											 
		self:sendEvent("updatePlayerPosGuide",self.playerPositionData,"Formation")
		self.selectPlayer:changePosition( minNearPos.x, minNearPos.y, minNearPos.z )
		-- self.selectPlayer:refreshTable()
	end
	self.selectPlayer = nil
end

function M:changeHeroRayCheckBoxByIndex(index)
	local players = self.plyMgr:getPlayers(1)
	local player = players:get(index)
	if player then
		local raycheckBox = player.raycheckBox
		if not IsNull(raycheckBox) then
			raycheckBox.gameObject:SetActive(false)
			raycheckBox.gameObject:SetActive(true)
		end
	end
end

function M:testHitPlayerByIndex(index)
	local players = self.plyMgr:getPlayers(1)
	local player = players:get(index)
	if player then
		return player:testHitPlayer()
	end
	return false
end

function M:MouseEvent()
	--战斗模式下才会有鼠标操作
	if self:get_sceneState() == SceneManager.SceneState.SceneReadyRun and self.open_panel_num == 0 and static_rootControl:hasChild("Formation") then
        self:mouseDown();
        self:mouseMove();
        self:mouseUp();
	end
end

--鼠标按下
function M:mouseDown()
	if static_rootControl:can3DTouchByViewName("Formation") or static_rootControl:can3DTouchByViewName("pops.BattleTalkPop") then
		if U3DUtil:Input_GetMouseButtonDown(0) then
			local can_click = GameUtil:getFunmationStatus()
			if can_click == false then
				return
			end
			self.isMouseDown = true
			self.mouseDownTime = U3DUtil:RealtimeSinceStartup();
			local check_index = nil
			local guide_info = UserDataManager.guide_data:getCurGuideInfo()
			local isGuiding = UserDataManager.guide_data:isGuiding()
			if isGuiding and guide_info then -- 引导屏蔽调整阵容操作 转为引导强制换位
				if guide_info.key == "Formation"  then
					if guide_info.action == 4 then
						check_index = guide_info.target[1]-1
						local hit_flag = self:testHitPlayerByIndex(check_index)
						if not hit_flag then
							self:changeHeroRayCheckBoxByIndex(check_index)
						end
					else
						self.isMouseDown = false
						return
					end
				end
			end
			local objList = CS.wt.framework.PhysicsTool.GetHitPlayer()
			--and  SceneManager:getCurSceneModel().mode ~= GlobalConfig.BATTLE_MODE.PET_DOUJI  
			if objList.Count > 0  then
				for i=1,objList.Count do
					local obj = objList[i-1];
					local helper = obj:GetComponent("LuaTransformHelper")
					if helper.camp == 1 then
						self.selectPlayer = self.plyMgr:getHeroByIndex(helper.index)
						if self.selectPlayer ~= nil then
							self.cur_near_index = self.selectPlayer:get_index()
							if check_index and check_index ~= self.cur_near_index then
								self.isMouseDown = false
								self.selectPlayer = nil
								return
							end
							self.last_near_index = self.selectPlayer:get_index()
							GameUtil:lookPlayerTips(static_rootControl, self.selectPlayer)
							GameUtil:lookPlayerRelationTips(static_rootControl, self.selectPlayer)
							if self.selectPlayer.fontUI ~= nil then
								self.selectPlayer.footUI:destroy();
							end
						end
					else
						Logger.log(obj, " 我点击到的是敌人 ")
					end
				end
				if self.selectPlayer ~= nil then
					if self.changeMaterialId == 0 then
						self.changeMaterialId = self.selectPlayer.luaViewHelper:AddMaterial("huanwei_01",1, function(mat)
							self.curChangeMaterial = mat
							if self.changeMaterialTween ~= nil then
								self.changeMaterialTween:Kill()
							end
							self.changeMaterialTween = Tweening.DOTween.To(function(alpha)
								mat:SetFloat("_AlphaValue", alpha)
							end, 0, 0.4, 0.2)
						end);
					end
				end
			end
		end
	end
end

--鼠标移动
function M:mouseMove()
	if self.isMouseDown then
		local md_time = U3DUtil:RealtimeSinceStartup() - self.mouseDownTime;
		if md_time >= self.mouseDown_durTime then
			if self.unlockFinish == false then
				self:sendEvent("lock_formation",nil,"Formation")
				self.unlockFinish = true;
			end
		end
		if self.selectPlayer ~= nil then
			local pos = CS.wt.framework.PhysicsTool.GetHitLandPos()
			pos.y = 0;
			self.selectPlayer:changePosition( pos.x, pos.y, pos.z );
			self:setSummonPos(self.selectPlayer, pos)
			local near_count = 0
			local minDis = 100000

			local heroPoslist = self.heroPoslist
			if SceneManager:getCurSceneModel().mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
				heroPoslist = self.petPoslist
			end

			-- 计算吸附
			for i = 1,heroPoslist.Count do
				--玩家位置坐标
				local heroIndexPos = heroPoslist:get(i-1);
				local select_pos = self.selectPlayer:get_position();
				local dis = Vector3.Distance(heroIndexPos, select_pos)
				GameUtil:updatePlayerTips( select_pos )
				if self.selectPlayer:checkApostle() then
					EventDispatcher:dipatchEvent("refreshHelperUI", {player = self.selectPlayer})
				end

				--此处1.5表示可以交换的最小距离
				if dis < minDis and dis < 1.5 then
					minDis = dis
					near_count = near_count + 1
					self.cur_near_index = i-1;
					if self.cur_near_index ~= self.last_near_index then
						if not IsNull(self.moveShangZhen_eff) then
							self.moveShangZhen_eff:Destroy();
							--移动的时候上阵特效
							self.moveShangZhen_eff = self:playerEffect(heroIndexPos,"fx_buff_fazhen_01",60)
						else
							--移动的时候上阵特效
							self.moveShangZhen_eff = self:playerEffect(heroIndexPos,"fx_buff_fazhen_01",60)
						end		
						self.last_near_index = self.cur_near_index
					end
					-- heroIndexPos.y = self.selectObj.transform.position.y
					-- self.selectObj.transform.position = heroIndexPos
				end
			end
			if near_count == 0 then
				if not IsNull(self.moveShangZhen_eff) then
					self.moveShangZhen_eff:Destroy();
					self.moveShangZhen_eff = nil
					self.last_near_index = nil
				end
			end
		end
	end
end

function M:setSummonPos(player, pos)
	local summonList = player.model.summonList
	for i = 1, summonList.list.Count do
		local key = summonList.list:get(i-1)
		local plys = summonList:get(key)
		for i, v in ipairs(plys) do
			local player_view = self.plyMgr:getPlayerByInstanceId(v:get_playerInstanceId())
			player_view:changePosition(pos.x, pos.y, pos.z)
		end
	end
end

--鼠标抬起
function M:mouseUp()
	if U3DUtil:Input_GetMouseButtonUp(0) then
		if self.unlockFinish == true then
			self:sendEvent("un_lock_formation",nil,"Formation")
		end
		self.unlockFinish = false;
		self.mouseUpTime = U3DUtil:RealtimeSinceStartup() - self.mouseDownTime;
		if  not IsNull(self.moveShangZhen_eff) then
			self.moveShangZhen_eff:Destroy();
			self.moveShangZhen_eff = nil
		end
		self.isMouseDown = false
		if self.selectPlayer ~= nil then
			if self.curChangeMaterial ~= nil then
				if self.changeMaterialId ~= 0 then
					if self.selectPlayer.luaViewHelper ~= nil then -- GPM issue_id: e9fbf83cc7a2ce1ce7063dd76847c549
						self.selectPlayer.luaViewHelper:ResetMaterial(self.changeMaterialId)
					end
					self.changeMaterialId = 0
				end
			end
			
			local guide_info = UserDataManager.guide_data:getCurGuideInfo()
			local isGuiding = UserDataManager.guide_data:isGuiding()
			if isGuiding and guide_info then -- 引导屏蔽调整阵容操作 转为引导强制换位
				if guide_info.key == "Formation" and guide_info.action == 4 then
					self.isMouseDown = false
					return
				end
			end
			--上一次选择的人物的index
			local lastIndex = self.selectPlayer:get_index()
			--检测id
			local check_index = lastIndex + 1
			--
			local minDis = 100000
			local index = check_index;
			local heroPoslist = self.heroPoslist
			if SceneManager:getCurSceneModel().mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
				heroPoslist = self.petPoslist
			end
			local minNearPos = heroPoslist:get(check_index-1)
			for i = 1,heroPoslist.Count do
				--玩家位置坐标
				local heroIndexPos = heroPoslist:get(i-1)
				local dis = Vector3.Distance( heroIndexPos, self.selectPlayer:get_position() )
				if dis < minDis and dis < 1.5 then
					heroIndexPos.y = 0
					minNearPos = heroIndexPos
					minDis = dis
					index = i
				end
			end
			
			--最近的index
			if check_index == index then
				-- 向下拖动到列表位置时松手后下阵
				local select_player_pos = self.selectPlayer:get_position()
				local heroIndexPos = heroPoslist:get(4)
				if self.canDownFlag and heroIndexPos and select_player_pos.z < (heroIndexPos.z - 2.5) then
					self:goDownBattle();
				else
					--归位
					if self.selectPlayer ~= nil and minNearPos then
						self.selectPlayer:changePosition( minNearPos.x, minNearPos.y, minNearPos.z )
						self:setSummonPos(self.selectPlayer, minNearPos)

						self:PlayShangZhenEffect(Vector3.New(minNearPos.x, minNearPos.y, minNearPos.z))
						if self.selectPlayer:checkApostle() then
							EventDispatcher:dipatchEvent("refreshHelperUI", {player = self.selectPlayer})
						end
					end
				end 
			else
				local sceneInfo = Battle.BattleGlobalConfig.SCENE_ID_INFO[SceneManager:getCurSceneModel().sceneId]
				if self.selectPlayer ~= nil and sceneInfo.hero_showLevel then
					self.selectPlayer:CreateFootUI()
				end

				local index_Player = self.plyMgr:getHeroByIndex(index - 1)
				if index_Player ~= nil then
					index_Player:set_index(check_index-1)
					index_Player.tranformHelper.index = check_index-1;

					self.selectPlayer:set_index( index-1 );
					self.selectPlayer.tranformHelper.index = index-1;

					index_Player:updateLevelEffect();
					self.selectPlayer:updateLevelEffect();

					self.playerPositionData[index] = self.selectPlayer:get_playerInstanceId()
					if lastIndex ~= __drag_hero_index then
						self.playerPositionData[check_index] = index_Player:get_playerInstanceId();
					end
					--更新上传数据											 
					self:sendEvent("updatePlayerPosData",self.playerPositionData,"Formation")
					self.selectPlayer:changePosition( minNearPos.x, minNearPos.y, minNearPos.z )
					self:setSummonPos(self.selectPlayer, minNearPos)
					self:PlayShangZhenEffect(Vector3.New(minNearPos.x, minNearPos.y, minNearPos.z))

					local pos = self:findSpawnPosition(1,index_Player.index);
					if SceneManager:getCurSceneModel().mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
						pos = self:findPetSpawnPosition(1,index_Player.index);
					end
					index_Player:changePosition( pos.x, pos.y, pos.z )
					self:setSummonPos(index_Player, pos)
					self:PlayShangZhenEffect(Vector3.New(pos.x, pos.y, pos.z))

					if index_Player:checkApostle() then
						EventDispatcher:dipatchEvent("refreshHelperUI", {player = index_Player})
					end
				else
					self.selectPlayer:set_index( index-1 )
					self.selectPlayer.tranformHelper.index = index-1;
					self.selectPlayer:updateLevelEffect();

					self.playerPositionData[index] = self.selectPlayer:get_playerInstanceId()
					if lastIndex ~= __drag_hero_index then
						self.playerPositionData[check_index] = "";
					end
					--更新上传数据											 
					self:sendEvent("updatePlayerPosData",self.playerPositionData,"Formation")
					self.selectPlayer:changePosition( minNearPos.x, minNearPos.y, minNearPos.z )
					self:setSummonPos(self.selectPlayer, minNearPos)
				end
				if self.selectPlayer:checkApostle() then
					EventDispatcher:dipatchEvent("refreshHelperUI", {player = self.selectPlayer})
				end
			end
			self.selectPlayer = nil;
		end
		GameUtil:resetPlayerInfoTips()
		GameUtil:resetPlayerRelationTips()
		self:destroyDragPlayer()
	end
end

return M;