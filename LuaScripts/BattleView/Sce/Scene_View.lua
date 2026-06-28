local SceneManager = SceneManager
---@class Scene_View : ViewBase
local M = class("Scene_View",Battle.ViewBase)

--开始场景
function M:init( model )
	self.model = model;
	self.sceneId = self.model.sceneId;
	self.friction = 40;
	self.open_panel_num = 0;
	self.delay_close_loading_time = 0;
	self.maxTime = 90;
	self.battleCameraConfig = require("Battle.battleCameraConfig")
	-- 初始化监听事件
	self:addEventListener_Local(Battle.EventType.MV_SceneModelEnter,{self, self.MV_SceneModelEnter});
	-- 场景数据销毁
	self:addEventListener_Local(Battle.EventType.MV_SceneModelDestory, {self, self.MV_SceneModelDestory});
	-- 场景数据初始化完成
	self:addEventListener_Local(Battle.EventType.MV_SceneModelInitFinish,{self,self.MV_SceneModelInitFinish});
	-- 玩家管理器创建完成
	self:addEventListener_Local(Battle.EventType.MV_PlayerManagerModelCreateFinish,{self, self.MV_PlayerManagerModelCreateFinish})
	-- 设定场景状态
	self:addEventListener_Local(Battle.EventType.MV_SceneModelSetState, {self,self.MV_SceneModelSetState})
	--相机不渲染
	self:addEventListener_Local(Battle.EventType.MV_SceneModelCameraShow, {self,self.MV_SceneModelCameraShow})
end

--加入事件
function M:addEvent()
	-- 场景播放特效
	self:addEventListener_Local(Battle.EventType.MV_SceneModelPlayEffect, {self, self.MV_SceneModelPlayEffect})
	-- 监听发送事件
	self:addEventListener_Local(Battle.EventType.MV_SceneModelSendEvent, {self,self.MV_SceneModelSendEvent})
end


--设定场景状态
function M:set_sceneState( state )
	self.sceneState = state;
end

--返回场景状态
function M:get_sceneState()
	return self.sceneState;
end

function M:MV_SceneModelCameraShow( eventName, data )
	if self.cameraController and self.cameraController.CameraShow then
		self.cameraController:CameraShow(data.show)
	end
end

-- 提交设定场景状态
function M:MV_SceneModelSetState( eventName, data )
	self:set_sceneState( self.model:get_sceneState() )
end

--发送场景事件
function M:MV_SceneModelSendEvent(eventName, data) 
	self:sendEvent(data.eventName, data.data, data.panelName)
end


function M:Scene_unity_update(dt, unsdt)
	self:view_update(dt,unsdt);
end

-- 场景数据初始化完成
function M:MV_SceneModelInitFinish(  eventName, data )
	self:initFinish();
end

--数据层 开始
function M:MV_SceneModelEnter( eventName, data )
	--进入场景的时候才执行更新操作
	self.heroPoslist = self:changeListPostion( self.model:get_heroPosList() )
	self.enemyPoslist = self:changeListPostion( self.model:get_enemyPosList() )
	self.petPoslist = self:changeListPostion( self.model:get_petPoslist() )
	self.petEnemyPoslist = self:changeListPostion( self.model:get_petEnemyPoslist() )
	--Unity场景名字 和 场景根节点的名字
	self.scene_name = self.model.scene_name;
	self.sceneObj_name = self.model.sceneObj_name;
	self:enter(data);
end


function M:changeListPostion( target_list )
	local list = Battle.List.new();
	if target_list ~= nil then
		for i = 1, target_list.Count do
			local fix_pos = target_list:get(i - 1);
			local pos = Vector3(0,0,0);
			pos.x = GlobalTools:ToFloat( fix_pos.x );
			pos.y = GlobalTools:ToFloat( fix_pos.y );
			pos.z = GlobalTools:ToFloat( fix_pos.z );
			list:add(pos);
		end
	end
	return list;
end


--数据层 通知播放特效
function M:MV_SceneModelPlayEffect( eventName, data )
	self:playerEffect(data.m_pos, data.m_name, data.m_time)
end

--数据层  销毁掉
function M:MV_SceneModelDestory( eventName, data )
	self:destroy(data.nextScene);
end

--玩家管理器层创建完成
function M:MV_PlayerManagerModelCreateFinish( eventName, data )
	--Logger.logError("<[SceneView]> 收到玩家管理器创建完成,创建视图绑定事件 ")
	local plyMgr_model = data;
	self.plyMgr = require("BattleView.Ply.PlayerManager_View").new()
	SceneManager.MV_EventMgr:register(self.plyMgr, plyMgr_model);
	self.plyMgr:start( self, plyMgr_model)
end

--设定背景音乐
function M:setBGMusic()
	local start_idx, _ = string.find(self.scriptName, "FightScene")
	if start_idx then
		StateSoundManager:playBGM(self.sceneData and self.sceneData.mode or 0)
	else
		local bgm =  self.scene_info and self.scene_info.bgm or ""
		if bgm ~= "" then
			audio:SendEvtBGM(bgm)
		end
	end
end

-- 初始化完成
function M:initFinish()
	
end

--播放特效
function M:playerEffect( pos, name, autoDestoryTime )
	local effectData = {}
	effectData["prefab"] = name
	effectData["isPutUpInParent"] = false
	effectData["autodestoryTime"] = autoDestoryTime
	local prefabTrans = {}
	effectData["prefabTrans"] = prefabTrans
	prefabTrans["useUserSet"] = true
	prefabTrans["position"] = {pos.x, pos.y, pos.z}
	prefabTrans["rotation"] = {0,0,0}
	prefabTrans["scale"] = {1,1,1}

	effectData["directionType"] = "world"
	effectData["scaleType"] = "world"
	effectData["positionType"] = "worldFix"

	local effectPlayerTypeName = "";
	local obj = nil

	--预制体
	local prefab = effectData.prefab;
	local parent = nil;
	local directionType = effectData.directionType;
	local scaleType = effectData.scaleType;
	local positionType = effectData.positionType;
	local useUserSet = effectData.prefabTrans.useUserSet == true
	local autodestoryTime = effectData.autodestoryTime;
	local isPutUpInParent = effectData.isPutUpInParent == false
	local position_x = tonumber(effectData.prefabTrans.position[1]);
	local position_y = tonumber(effectData.prefabTrans.position[2]);
	local position_z = tonumber(effectData.prefabTrans.position[3]);
	local rotation_x = tonumber(effectData.prefabTrans.rotation[1]);
	local rotation_y = tonumber(effectData.prefabTrans.rotation[2]);
	local rotation_z = tonumber(effectData.prefabTrans.rotation[3]);
	local scale_x = tonumber(effectData.prefabTrans.scale[1]);
	local scale_y = tonumber(effectData.prefabTrans.scale[2]);
	local scale_z = tonumber( effectData.prefabTrans.scale[3]);

	local player_effect = CS.zmhx.EffectManager.Inst:PlayEffect(prefab,
																parent,
																directionType,
																scaleType,
																positionType,
																useUserSet,
																autodestoryTime,
																isPutUpInParent,
																position_x,
																position_y,
																position_z,
																rotation_x,
																rotation_y,
																rotation_z,
																scale_x,
																scale_y,
																scale_z,
																obj, effectPlayerTypeName, false );
	return player_effect
end


function M:enter(data)
	self.enterData = data;
	GameMain.addUpdate("Scene_Unity_Update",handler(self, self.Scene_unity_update) );
	-- 场景信息数据
	self.scene_info = self.model:get_scene_info();
	self:addEvent();
	self:loadSync(data);
	if data == nil or (data and data.playBGM ~= false) then
		self:setBGMusic()
	end
end

--更新
function M:view_update(dt,unsdt)
	if self.plyMgr ~= nil then
		self.plyMgr:view_update(dt,unsdt);
	end
end

--向ui发送事件
function M:sendEvent( eventName, data, panelName )
	static_rootControl:updateMsg(eventName,data,panelName)
	EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.BATTLE_EVENT, {event = eventName, data = data})
end

--异步加载场景
function M:loadSync( data )
	self.sceneData = data;
	if SceneManager.goInSceneing == nil or SceneManager.goInSceneing == false then
		if SceneManager.curSceneName ~= self.scene_name then
			static_rootControl:openView("Loading.SyncLoadBigLoading",{ isShowBg = data.isShowBg, callback = function()
				SceneManager.goInSceneing = true;
				ResourceUtil:LoadScene(self.scene_name,function (scene_name, flag)
					SceneManager.curSceneName = self.scene_name;
					SceneManager.goInSceneing = false;
					self:sceneLoadFinish();
					self:initScene()
					--场景加载完成
					SDKUtil:OnSceneLoadFinish()
				end,"1")
				--场景开始加载_gpm
				SDKUtil:OnSceneStart(self.scene_name)
			end})
		else
			self:initScene()
		end
	end
end

--场景加载完成
function M:sceneLoadFinish()
	EventDispatcher:registerTimeEvent("delay_close_loading_time",function()
		--ResourceUtil:AddUnLoadFinish(function()
			ResourceUtil:UnLoadMemeroy()
			static_rootControl:updateMsg("close_sync_load_big_loading")
		--end)
		--ResourceUtil:StartUnLoadBundle()
	end,0.1,0.1)
end


--检测卸载bundle
--1 挂机
--2 战斗推关处理 
function M:checkUnLoadBundle( type, mode, param)
	if type == 1 then
		local data = GameUtil:getCurStageIdleData();
		local hero_table = ConfigManager:getCfgByName("hero_detail");
		local monster = data.monster;
		for k,v in ipairs(monster) do
			if v.iid and v.iid > 0 then
				local hero_data = hero_table[v.iid];
				self:addHeroCancelUnloadBundle(hero_data)
			end
		end
	elseif type == 2 then
		local stage_cfg = GameUtil:getBattleStageCfg();
		local hero_table = ConfigManager:getCfgByName("hero_detail");
		local battle_id = stage_cfg.battle_id
		--local stage_battle_cfg = ConfigManager:getCfgByName("stage_battle")
		local stage_battle_cfg_item = ConfigManager:getCfgStageBattle(battle_id) or {} --stage_battle_cfg[battle_id] or {}
		local monster = stage_battle_cfg_item.monster or {}
		for k,v in ipairs(monster) do
			if v.id and v.id > 0 then
				local hero_data = hero_table[v.id];
				self:addHeroCancelUnloadBundle(hero_data)
			end
		end
	elseif type == 3 then
		if mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS then
			if not param then param = {} end
			local world_boss = ConfigManager:getCfgByName("world_boss")
			local world_boss_item = world_boss[param.boss_id or 1] or {}
			--local stage_battle = ConfigManager:getCfgByName("stage_battle")
			local battle_cfg = ConfigManager:getCfgStageBattle(world_boss_item.battle_id)--stage_battle[world_boss_item.battle_id]
			local boss = battle_cfg.monster[battle_cfg.worldboss_position]
			local hero_detail = ConfigManager:getCfgByName("hero_detail")
			local boss_cfg = hero_detail[boss.id]
			self:addHeroCancelUnloadBundle(boss_cfg)
		elseif mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
			if not param then param = {} end
			local world_boss = ConfigManager:getCfgByName("active_world_boss")
			local scene_model = SceneManager:getCurSceneModel()
			local world_boss_item = world_boss[scene_model.m_data.m_open_id or 327] or {}
			local boss_cfg = world_boss_item[scene_model.m_data.m_version or 1] or {}
			--local stage_battle = ConfigManager:getCfgByName("stage_battle")
			local battle_cfg = ConfigManager:getCfgStageBattle(boss_cfg.battle_id)--stage_battle[boss_cfg.battle_id]
			local boss = battle_cfg.monster[battle_cfg.worldboss_position]
			local hero_detail = ConfigManager:getCfgByName("hero_detail")
			local boss_cfg = hero_detail[boss.id]
			self:addHeroCancelUnloadBundle(boss_cfg)
		end
	end
	
	--开始强制卸载
	ResourceUtil:StartUnLoadBundle();
end

--加入玩家取消卸载bundle列表
function M:addHeroCancelUnloadBundle(hero_cfg)
	if hero_cfg then
		local prefabName = hero_cfg["prefab"];
		local name_path = string.split(prefabName,"/");
		--预制体的根节点
		local prefabRoot = name_path[1];
		local bundleName = "role3d_"..string.lower(prefabRoot)
		local effectBundleName = "fx_"..string.lower(prefabRoot)
		ResourceUtil:AddCancelUnloadBundle(bundleName);
		ResourceUtil:AddCancelUnloadBundle(effectBundleName);
	end
end

function M:preLoadBattleStageHero()
	local hero_detail = ConfigManager:getCfgByName("hero_detail");
	local stage_cfg = GameUtil:getBattleStageCfg();
	local battle_id = stage_cfg.battle_id
	--local stage_battle_cfg = ConfigManager:getCfgByName("stage_battle")
	local stage_battle_cfg_item = ConfigManager:getCfgStageBattle(battle_id) or {}--stage_battle_cfg[battle_id] or {}
	local monster = stage_battle_cfg_item.monster or {}
	local monster_len = #monster
	local load_len = 0
	local function callBack()
		load_len = load_len + 1
		if monster_len == load_len then
			Logger.log("preLoadBattleStageHero end monster_len = " .. monster_len)
		end
	end
	local function loadProgress()

	end
	for k,v in ipairs(monster) do
		if v.id and v.id > 0 then
			local hero_cfg = hero_detail[v.id];
			local hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(nil, hero_cfg)
			if hero_skin_cfg then
				local prefabName = hero_skin_cfg["prefab"];
				local name_path = string.split(prefabName,"/");
				--预制体的根节点
				local prefabRoot = name_path[1];
				local bundleName = "role3d_" .. string.lower(prefabRoot)
				local effectBundleName = "fx_" .. string.lower(prefabRoot) .. LODUtil:getLodKey()
				ResourceUtil:PreLoadAssetAllAsync(bundleName, callBack, loadProgress)
				ResourceUtil:PreLoadAssetAllAsync(effectBundleName, callBack, loadProgress)
			end
		end
	end
end

--加载完成初始化场景
function M:initScene()
	--初始化场景中的物件
	self:initSceneObjects( self.sceneData )
	--场景开始运行
	SceneManager:scenestart_view();
	SceneManager:setData("show_loading_black", false)
	--发送场景加载完成
	SelectTargetTool_View:resetFixPoint();
	self:dispatchEvent_Local(Battle.EventType.VM_SceneViewLoadFinish)
end

--初始化场景中的物件
function M:initSceneObjects( data )

	self.sceneShow = U3DUtil:GameObject_Find("Scene");
	if IsNull(self.sceneShow) == false then
		local lodSetter = self.sceneShow:GetComponent("LODSetter")
		if lodSetter ~= nil then
			lodSetter:SetLod()
		end
	else
		Logger.logError(" Scene 根节点没有找到 "..self.sceneType )
	end
	
	self.sceneRoot = U3DUtil:GameObject_Find("sceneRoot_"..self.sceneType);
	if self.sceneRoot ~= nil then
		local obj_tran = nil;
		if self.sceneObj_name ~= "" then
			obj_tran = self.sceneRoot.transform:Find(self.sceneObj_name)
			if obj_tran ~= nil then
				self.obj = obj_tran.gameObject;
			end
		end
		
		if self.obj ~= nil then
			self.obj:SetActive(true);
			self.cameraObj = self.obj.transform:Find("Camera")
			self.prefabs = U3DUtil:GameObject_Find( "prefabs" );
			if self.cameraObj ~= nil then
				--摄像机控制器
				self.cameraController = self.cameraObj:GetComponent("CameraController")
				if self.sceneEffect ~= nil then
					self.cameraController.sceneCenter = self.sceneEffect.transform;
				end
				if self.cameraController ~= nil then
					self.cameraController:ResetStart();
				end
				self.camera_3d = self.cameraObj.transform:Find("Camera_3D")
				if self.camera_3d == nil and self.cameraController ~= nil and self.cameraController.Camera_3D ~= nil then
					self.camera_3d = self.cameraController.Camera_3D.gameObject
				end
				if self.camera_3d ~= nil then
					--摄像机控制器
					self.cameraShake = self.camera_3d:GetComponent("CameraShake")
				end
			end
			
			self.sceneEffect = U3DUtil:GameObject_Find( "effectpoint3" );
			--血条显示根节点
			self.hpContent = self.obj.transform:Find("HpBarContent")
			if self.hpContent ~= nil then
				self.hpContent.gameObject.layer = CS.UnityEngine.LayerMask.NameToLayer("UI")
			end
			--战斗场景
			if self.cameraShake ~= nil then
				--self.cameraShake:StartRun();
			end
		end
	end
	
	--通知UI场景加载完毕
	if static_rootControl then
		static_rootControl:updateMsg("load_scene_finish", nil, "GamePanel")
		static_rootControl:updateMsg("load_scene_finish", nil, "Formation")
		static_rootControl:updateMsg("load_scene_finish", nil, "Pops.PlotPop")
	end
	
	--初始化场景物体完成 
	self:initSceneObjectsFinish();
end

--初始化场景物体完成  子类重写
function M:initSceneObjectsFinish()
	if self.enterData ~= nil and self.enterData.m_move_camera == 1 then
		self:setCameraInfo(false,"gve")
	else
		self:setCameraInfo(false)
	end
end


function M:resetCamerInfo()
	if self.enterData ~= nil and self.enterData.m_move_camera == 1 then
		self:setCameraInfo(false,"gve")
	end
end


--找到场景中的固定点
function M:findSceneFixPoint()
	if self.sceneEffect ~= nil then
		return self.sceneEffect.transform.position;
	end
	return Vector3(0,0,0)
end

--实例化一个 GameObject
function M:instanceGameObject( name, parent )
	local inst_obj = self.obj.transform:Find(name);
	local obj_inst = nil;
	if inst_obj ~= nil then
		obj_inst = U3DUtil:Instantiate( inst_obj.gameObject );
		obj_inst:SetActive(true);
		if parent ~= nil then
			obj_inst.transform:SetParent(parent.transform);
		else
			obj_inst.transform:SetParent(nil);
		end
	else
		Logger.logError(name.." 没有找到 ~~~~~~~~~~~~~~ ");
	end
	return obj_inst;
end

--@camp: 阵营 1 己方， 其他为敌人
--@index: 位置序号
function M:findSpawnPosition(camp, index)
	if index >= 0 then
		if camp == 1 then
			if self.heroPoslist.Count > index then
				return self.heroPoslist:get(index)
			else
				return Vector3.New(0,0,0)
			end
		else
			if self.enemyPoslist.Count > index then
				return self.enemyPoslist:get(index)
			else
				return Vector3.New(0,0,0)
			end
		end
	else
		return Vector3.New(0,0,0)
	end
end

--@camp: 阵营 1 己方， 其他为敌人
--@index: 位置序号
function M:findPetSpawnPosition(camp, index)
	if index >= 0 then
		if camp == 1 then
			if self.petPoslist.Count > index then
				return self.petPoslist:get(index)
			else
				return Vector3.New(0,0,0)
			end
		else
			if self.petEnemyPoslist.Count > index then
				return self.petEnemyPoslist:get(index)
			else
				return Vector3.New(0,0,0)
			end
		end
	else
		return Vector3.New(0,0,0)
	end
end

--抖动
function M:Shake( shake )
	self.cameraShake.shake = shake
	self.cameraShake.shakeAmount = 0.7
	self.cameraShake.decreaseFactor = 1
end

function M:setCameraInfo(isBattle, fixCamerInfo)
	local cameraInfoName = fixCamerInfo or self.model:getCurCameraInfoName()
	local camera_info = SceneManager:getCameraInfo(cameraInfoName, isBattle)
	if IsNull(camera_info) == false then
		local camera_3d = self.camera_3d:GetComponent("Camera")
		if isBattle then
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append( self.camera_3d:DOLocalMove(camera_info.position, 1, false):SetEase(Tweening.Ease.Linear))
			sequence:Join( self.camera_3d:DOLocalRotate(camera_info.rotation, 1, Tweening.RotateMode.Fast):SetEase(Tweening.Ease.Linear))
			sequence:Join( camera_3d:DOFieldOfView(camera_info.fov, 1, false):SetEase(Tweening.Ease.Linear))
			sequence:SetAutoKill(true)
		else
			self.camera_3d.localPosition = camera_info.position
			self.camera_3d.localEulerAngles = camera_info.rotation
			camera_3d.fieldOfView = camera_info.fov
		end
	end
end

--删除事件
function M:removeEvent()
	GameMain.removeUpdate("Scene_Unity_Update")
	-- 场景播放特效
	self:removeEventListener_Local(Battle.EventType.MV_SceneModelPlayEffect, {self, self.MV_SceneModelPlayEffect})
	-- 玩家管理器创建完成
	self:removeEventListener_Local(Battle.EventType.MV_PlayerManagerModelCreateFinish,{self, self.MV_PlayerManagerModelCreateFinish})
	-- 监听发送事件
	self:removeEventListener_Local(Battle.EventType.MV_SceneModelSendEvent, {self,self.MV_SceneModelSendEvent})
end

--销毁场景
function M:destroy( nextScene )
	self:removeEvent();
	self.plyMgr:destroy();
	CS.zmhx.EffectManager.Inst:Destroy();
	if not IsNull(self.cameraController) then
		self.cameraController:Clear();
	end
	self.cameraController = nil;
	--向导
	if self.guide ~= nil then
		self.guide:destroy();
		self.guide = nil;
	end
	--将场景返回到对象池
	if nextScene ~= nil then
		if self.obj ~= nil then
			-- ResourceUtil:ReturnItem(self.obj)
			self.obj:SetActive(false);
			self.obj = nil;
		end
	end
	--场景根节点
	if self.sceneRoot ~= nil then
		self.sceneRoot = nil;
	end
	if self.sceneEffect ~= nil then
		self.sceneEffect = nil;
	end
	self.cameraObj = nil
	self.camera_3d = nil
	if self.sceneObjs ~= nil and self.sceneObjs.Count > 0 then
		for i=1,self.sceneObjs.Count do
			ResourceUtil:ReturnItem(self.sceneObjs:get(i-1))
		end
		self.sceneObjs:clear();
	end
	--场景结束_gpm
	SDKUtil:OnSceneEnd()
end

return M