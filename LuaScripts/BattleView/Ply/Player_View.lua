--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-04-28 15:51:11
]]

---@class Player_View : ViewBase 玩家显示层
---@field plyMgr PlayerManager_View
---@field model PlayerModel
---@field luaViewHelper CS.zmhx.PlayerLuaViewHelper
---@field obj CS.UnityEngine.GameObject
---@field tran CS.UnityEngine.Transform
local M = class("Player_View",Battle.ViewBase)

--初始化
function M:init( data )
	--初始化创建数据
	self:initCreateData( data );
	--初始化本地数据
	self:initLocalAttribute();
	--初始化管理器
	self:initManagers();
	--监听血量改变
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelHpChange,{self,self.PlayerModelHpChange})
	--监听位置改变
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelPositionChange,{self,self.PlayerModelPositionChange})
	--监听怒气更新
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelAngerChange, {self,self.MV_PlayerModelAngerChange})
	--监听数据发来要显示 战斗内弹出字体
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelShowLabel,{self,self.PlayerModelShowLabel})
	--显示攻击UI
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelShowHitUI,{self,self.PlayerModelShowHitUI})
	--监听数据层的 update 
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelUpdate,{self, self.PlayerModelUpdate})
	--监听数据层 设定 缩放值
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelSetScale, {self, self.PlayerModelSetScale})
	--监听数据层 方向改变
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelDirChange, {self, self.PlayerModelDirChange})
	--监听数据层 要求显示数据
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelShowData, {self, self.PlayerModelShowData})
	--监听数据层 大招好之后刷新卡牌
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelSkill3RefreshCard, {self, self.PlayerModelSkill3RefreshCard})
	--监听数据层 销毁
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelDestroy, {self, self.PlayerModelDestroy})
	--监听数据层让 播放特效
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelPlayHitEffect,{self, self.PlayerModelPlayHitEffect})
	--监听数据 销毁所有Hplabel
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelDestoryHpLabel, {self, self.MV_PlayerModelDestoryHpLabel})
	--监听数据层让 播放特效
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelCreateEffect,{self, self.MV_PlayerModelCreateEffect})
	--同步人物实例id
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelSyncInstanceId,{self, self.MV_PlayerModelSyncInstanceId})
	-- 玩家AI状态机退出
	self:addEventListener_Local(Battle.EventType.MV_PlayerModeAIStateExit, {self, self.MV_PlayerModeAIStateExit})
	-- 玩家出生
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelSpawn, {self, self.MV_PlayerModelSpawn})
	-- 设定层级
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelSetLayer, {self, self.MV_PlayerModelSetLayer})
	--进入大招AI状态机
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelEnterAISkill, {self, self.MV_PlayerModelEnterAISkill})
	--开始开始黑屏
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelStartBlack, {self,self.MV_PlayerModelStartBlack})
	--开始结束黑屏
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelStopBlack, {self,self.MV_PlayerModelStopBlack})
	--设定主人
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelSetMaster, {self,self.MV_PlayerModelSetMaster})

	self:addEventListener_Local(Battle.EventType.MV_PlayerModelPlayEffect, {self,self.MV_PlayerModelPlayEffect})
	--设定材质
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelSetMaterial, {self,self.MV_PlayerModelSetMaterial})
	
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelRemoveEffectByName, {self,self.MV_PlayerModelRemoveEffectByName})
	--治疗
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelCure, {self,self.MV_PlayerModelCure})
	--显示血条
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelShowHpBar, {self,self.MV_PlayerModelShowHpBar})
	--隐藏body
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelHideBody, {self,self.MV_PlayerModelHideBody})
	--角色真正死亡
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelRealDead, {self,self.MV_PlayerModelRealDead})
	--提交同步敌人列表
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelSyncEnemyList, {self, self.MV_PlayerModelSyncEnemyList})
	--同步嘲讽列表
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelSyncTauntList, {self,self.MV_PlayerModelSyncTauntList})
	
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelSetEnemy, {self,self.MV_PlayerModelSetEnemy})
	--同步index
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelSetIndex, {self,self.MV_PlayerModelSetIndex})
	--技能结束
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelSkillEnd, {self,self.MV_PlayerModelSkillEnd})
	--旋转设置
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelSetRotationMode, {self,self.MV_PlayerModelSetRotationMode})
	--技能击杀了玩家
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelSkillKillPlayer, {self,self.MV_PlayerModelSkillKillPlayer})
	--设定boss标识 
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelSetBoss, {self, self.MV_PlayerModelSetBoss})
	
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelLeaveBattle, {self, self.MV_PlayerModelLeaveBattle})
	--
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelPlayInjureAnim, {self, self.MV_PlayerModelPlayInjureAnim})

	--监听数据层让 停止延迟buff特效任务的特效播放
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelStopTimeTask,{self, self.MV_PlayerModelStopTimeTask})
	--加载人物和人物特效
	self:loadAllPlayerAssets();

	-- 由逻辑将角色隐藏掉，在切换状态的时候，不会将角色显示出来
	self.isHide = false
end

--初始化创建数据
function M:initCreateData( data )
	self.model = data.model;
	--玩家管理器
	self.plyMgr = data.plyMgr;
	--英雄数据
	self.heroData = self.model:get_heroData();
	--预制体根名字
	self.prefabRoot = self.model:get_prefabRoot();
	--特效预制体根名字
	self.effect_prefabRoot = self.model:get_effect_prefabRoot();
	--玩家名字
	self.plyType = self.model:get_plyType();
	--玩家默认皮肤名字
	self.default_plyType = self.model:get_default_plyType();
	--父节点
	self.parent = data.parent;
	--预制体名字
	self.prefabName = self.model:get_prefabName();
	--获取阵营
	self.camp = self.model:get_camp();
	--人物索引
	self.index = self.model:get_index();
	--天命化星等级
	self.fate_level = self.model:get_fate_level();
	--人物数据
	self.data = self.model:get_data();
	--宠物类型
	self.summonType = self.model:get_summonType()
	--初始化开始的缩放值
	self.scale = GlobalTools.base1;
	--种族
	self.plyData =  self.model:get_plyData();
	--
	self.player_enemyList = Battle.List.new()
	--嘲讽列表
	self.tauntList = Battle.List.new()
	--计算密集区要用到
	self.apieceIndex = 0;
	--是否仅仅旋转X方向
	self.rotationOnlyX = false;
	

	--  PlayerBuf_Model timeTask 任务
	self.timeTaskList = Battle.List.new()
	self.effectList = {}
end

--初始化本地数据
function M:initLocalAttribute()
	self.isUnScale = false
	--玩家掉落物管理数组
	self.drop_list = Battle.List.new();
	--加血列表 
	self.cure_list = Battle.List.new();
	--人物预制体是否加载完成
	self.isPrefabLoadFinish = false;
	--人物特效是否加载完成
	self.isEffectLoadFinish = false;
	--人物是否加载完成
	self.isPlayerLoadFinish = false;
	--玩家的品质特效
	self.standEffects = Battle.List.new();
	--玩家加载的声音bank
	self.banks = {}
	--位置
	self.position_vec = Vector3(0,0,0)
	--方向
	self.dir_vec = Vector3(0,0,0)
	--bundle名字
	self.bundelName = "role3d_"..string.lower(self.prefabRoot)
	self.effectBundleName = "fx_"..string.lower(self.prefabRoot)..LODUtil:getLodKey()
	self.commoneffectBundleName = "commoneffect";

	self.curLoadNum = 3;
	self.taskList = Battle.List.new()
end

--加入任务
function M:addModelTask( func )
	local task = {}
	task.func = func
	self.taskList:add(task);
end

--运行任务
function M:runTask()
	for i = 1, self.taskList.Count do
		local task = self.taskList:get(i-1);
		if task.func ~= nil then
			task.func();
		end
	end
	self.taskList:clear();
end


--初始化管理器
function M:initManagers()
	--玩家技能数据
	self.plySkill = require("BattleView.Ply.PlayerSkill_View").new()
	self.plySkill:init(self)
	
	--事件系统
	self.evtMgr = require("BattleView.SM.AnimEvt.AnimEvtManager_View").new();
	self.evtMgr:init(self, self.plyType)
	
	--动画系统
	self.animator = require("BattleView.SM.Anim.PlayerAnimator_View").new()
	self.animator:init(self)
	
	--玩家buf管理器
	self.bufMgr = require("BattleView.Buf.BufManager_View").new()
	self.bufMgr:init(self)
	
	--子弹管理器
	self.bulletMgr = require("BattleView.Blt.BulletManager_View").new()
	self.bulletMgr:init(self)
	
	--连线管理器
	self.lineMgr = require("BattleView.Line.LineManager_View").new()
	self.lineMgr:init(self)
	
	--召唤物管理器
	self.summonMgr = require("BattleView.Summon.SummonManager_View").new()
	self.summonMgr:init(self)
	
	--移动管理器
	self.moveMgr = require("BattleView.Ply.Fuc.MoveFrameManager_View").new()
	self.moveMgr:init(self)
	
	--角色头顶管理器
	self.headUIMgr = require("BattleView.Ply.HeadUI.HeadUIManager_View").new()
	self.headUIMgr:init(self)
end


function M:clearMgr()
	if self.plySkill ~= nil then
		self.plySkill:destroy();
	end
	if self.evtMgr ~= nil then
		self.evtMgr:destroy();
	end
	if self.animator ~= nil then
		self.animator:destroy();
	end
	if self.bufMgr ~= nil then
		self.bufMgr:destroy();
	end
	if self.bulletMgr ~= nil then
		self.bulletMgr:destroy();
	end
	if self.lineMgr ~= nil then
		self.lineMgr:destroy();
	end
	if self.summonMgr ~= nil then
		self.summonMgr:destroy();
	end
	if self.moveMgr ~= nil then
		self.moveMgr:destroy();
	end
	if self.headUIMgr ~= nil then
		self.headUIMgr:destroy();
	end
end


--获取自己的Player
function M:getPlayer(useSelf)
	if useSelf ~= nil then
		if type(useSelf) == "string" then
			useSelf = useSelf == true
		elseif type(useSelf) == "boolean" then
		else
			useSelf = false
		end
	else
		useSelf = false
	end
	if self.master ~= nil and useSelf == false and self.summonType ~= "senior" then
		return self.master
	end
	return self
end

--获取视图的数据层
function M:get_model()
	return self.model;
end

--设定实例id 
function M:set_playerInstanceId( instanceId )
	self.playerInstanceId = instanceId;
end


function M:set_enemy( enemy )
	self.enemy = enemy;
end

function M:get_enemy()
	return self.enemy;
end

function M:get_camp()
	return self.camp;
end

--获取实例id
function M:get_playerInstanceId()
	return self.playerInstanceId
end

--获取主人公
function M:get_master()
	return self.master;
end

--设定index
function M:set_index( index )
	self.index = index;
	if IsNull(self.tranformHelper) == false then
		self.tranformHelper.index = self.index;
	end
	self:dispatchEvent_Local(Battle.EventType.VM_PlayerViewSetIndex, { index = index })
end

--获取index
function M:get_index()
	return self.index;
end


--视图层更新
function M:view_update(dt, unsdt)
	if self.cure_list.Count > 0 then
		if self.cureTask == nil then
			self.cureTask = self.cure_list:get(0)
		end
		if self.cureTask ~= nil and self.cureTask.time > 0 then
			self.cureTask.time = self.cureTask.time - dt;
			if self.cureTask.time <= 0 then
				local value = self.cureTask.data.hp
				if value ~= nil  then
					if value < 0 then
						value = 0
					end
					if value > 0 then
						value = GlobalTools:ToFloat(value)
						if self.head ~= nil then
							--冒血数字
							self:createHpNumberLabel("+", Mathf.Floor(value), 2)
						end
					end
				end
				self.cure_list:removeAt(0)
				self.cureTask = nil;
			end
		end
	end
end

--设定材质
function M:MV_PlayerModelSetMaterial(eventName, data)
	local matName = data.matName;
	local matType = data.matType;
	self.luaViewHelper:AddMaterial(matName,matType);
end

function M:MV_PlayerModelPlayEffect(eventName, data) 
	local effectData = data.data;
	local player = data.ply;
	local effectPlayer = data.effectPly;
	self:playEffect(effectData, player, effectPlayer)
end

function M:MV_PlayerModelSetMaster(eventName ,dat)
	local master_model = self.model:get_master();
	if master_model ~= nil then
		self.master = self.plyMgr:GetPlayerViewByModel(master_model)
	end
end

function M:MV_PlayerModelStopBlack(eventName ,data)
	self:overBlackTimeHandler()
end

--开始黑屏
function M:MV_PlayerModelStartBlack(eventName ,data)
	self:startBlackTimeHandler();
end

--进入大招状态
function M:MV_PlayerModelEnterAISkill(eventName ,data)
	if IsNull(self.footEffect) == false then
		self.footEffect:SetActive(false)
	end
end

function M:MV_PlayerModelSetLayer(eventName, data)
	self:setLayer(data.isBlack)
end

function M:MV_PlayerModelSpawn(eventName, data)
	if self.luaViewHelper ~= nil then
		self:spawn(data.dyns);
	else
		self:addModelTask( function()
			self:spawn(data.dyns);
		end)
	end
end

--玩家AI状态机 退出
function M:MV_PlayerModeAIStateExit(eventName, data)
	local scene_view = SceneManager:getCurSceneView()
	if scene_view.sceneId == SceneManager.SceneID.FightScene or
			scene_view.sceneId == SceneManager.SceneID.BossScene or
			scene_view.sceneId == SceneManager.SceneID.ActiveBossScene or
			scene_view.sceneId == SceneManager.SceneID.TianjiLouFightScene or
			scene_view.sceneId == SceneManager.SceneID.MiGongFightScene or
			scene_view.sceneId == SceneManager.SceneID.GuJianQiTanFightScene then
			if IsNull(self.body) == false then
				if self.body.gameObject.activeSelf == false and self.master == nil then
					if self.isHide ~= true then
						self.body.gameObject:SetActive(true)
						if self.hpBar ~= nil then
							self.hpBar:Show(true)
						end
					end
				end
			end
	end
end

--同步玩家实例id
function M:MV_PlayerModelSyncInstanceId(eventName, data)
	self:set_playerInstanceId( self.model:get_playerInstanceId() )
end

--销毁HpLabel
function M:MV_PlayerModelDestoryHpLabel(eventName, data)
	if self.luaViewHelper ~= nil then
		self.luaViewHelper.m_ui:RemoveAllHpLabel();
	end
end

--创建特效
function M:MV_PlayerModelCreateEffect(eventName, data)
	if self.luaViewHelper ~= nil then
		if data.name == "Buff_XiangKe_001" then
			local obj = ResourceUtil:LoadCommonEffect("Buff_XiangKe_001",nil)
			obj.transform.position = self.head.position + Vector3(0,0.5,0);
			TimeTools:delayTimeUnity(2, function()
				ResourceUtil:ReturnItem(obj);
			end)
		end
	else
		self:addModelTask( function()
			if data.name == "Buff_XiangKe_001" then
				local obj = ResourceUtil:LoadCommonEffect("Buff_XiangKe_001",nil)
				obj.transform.position = self.head.position + Vector3(0,0.5,0);
				TimeTools:delayTimeUnity(2, function()
					ResourceUtil:ReturnItem(obj);
				end)
			end
		end)
	end
end

-- 视图层收到信息播放特效
function M:PlayerModelPlayHitEffect(eventName, data)
	if SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.LEGEND and self.camp == -1 then
		return;
	end
	self:beHitDirect(data.player, data.attackData, data.isCrit)
end

-- 数据层销毁了
function M:PlayerModelDestroy(eventName, data)
	self:playDeadEffect()
	self:destroy(data.isDestroyObj);
	self.plyMgr:destroyPlayer(self.model)
end


function M:playDeadEffect()
	if SceneManager.curScene.sceneId == SceneManager.SceneID.LegendScene then
		ResourceUtil:LoadCommonEffectAsync("Skill_Die_001", nil, function(effect)
			if not IsNull(self.obj) and not IsNull(effect) then
				local pos = effect.transform.localPosition
				pos.x = self.obj.transform.position.x
				pos.y = self.obj.transform.position.y
				pos.z = self.obj.transform.position.z
				effect.transform.localPosition = pos
			end
			if not IsNull(effect) then
				TimeTools:delayTimeUnity(0.5, function()
					ResourceUtil:ReturnItem(effect)
				end)
			end
		end)
	end
end

function M:MV_PlayerModelLeaveBattle()
	self:playDeadEffect()
end

-- 显示攻击UI
function M:PlayerModelShowHitUI(eventName, data)
	local type = data.type;
	local attackData = data.attackData;
	self:ShowHitUI(type, attackData)
end

--大招好了之后刷新UI
function M:PlayerModelSkill3RefreshCard(eventName, data) 
	local show = data.show;
	self:refreshCard(show)
end

--显示玩家的具体数据
function M:PlayerModelShowData(eventName, data)
	self:showData(data.player, data.attackData, data.damage, data.isCrit)
end

--数据层反向改变
function M:PlayerModelDirChange(eventName, data)
	local forward = self.model:getForward();
	local x = GlobalTools:ToFloat(forward.x)
	local y = GlobalTools:ToFloat(forward.y)
	local z = GlobalTools:ToFloat(forward.z)
	self:changeForward(x,y,z);
end

--改变方向
function M:changeForward( x,y,z )
	if self.forward == nil then
		self.forward = {x = 0, y = 0, z = 0}
	end
	self.forward.x = x;
	self.forward.y = y;
	self.forward.z = z;

	self.dir_vec.x = x;
	self.dir_vec.y = y;
	self.dir_vec.z = z;
	--把最新的位置信息，同步到Unity层
	self:refreshTable();
end

--当玩家位置信息更新时通知
function M:PlayerModelPositionChange()
	local position = self.model:get_position();
	local x = GlobalTools:ToFloat(position.x)
	local y = GlobalTools:ToFloat(position.y)
	local z = GlobalTools:ToFloat(position.z)
	self.forceSetPosition = self.model:get_forceSetPosition();
	self:setPositionForce(self.forceSetPosition)
	--更新位置信息
	self:changePosition(x,y,z);
end

--改变位置
function M:changePosition( x,y,z )
	if self.position == nil then
		self.position = {x = 0, y = 0, z = 0}
	end
	self.position.x = x;
	self.position.y = y;
	self.position.z = z;

	self.position_vec.x = x;
	self.position_vec.y = y;
	self.position_vec.z = z;
	--把最新的位置信息，同步到Unity层
	self:refreshTable();
end

--获取View位置
function M:get_position()
	return self.position_vec;
end

--获取方向
function M:get_dir()
	return self.dir_vec
end

--获取向右的方向
function M:getRight()
	return Vector3.right
end

--设定缩放值
function M:PlayerModelSetScale(eventName, data)
	self.scale = self.model:get_scale()
	self:setScale(self.scale)
end

--监听数据层的Update
function M:PlayerModelUpdate(eventName, data)
	self:update(data.dt)
end

--显示 Label 字样
function M:PlayerModelShowLabel(eventName, data)
	self:createHpNumberLabel(data.sign, GlobalTools:ToFloat( data.num ), data.type)
end

--监听怒气更新
function M:MV_PlayerModelAngerChange( eventName, data)
	--更新怒气
	if self.playerHelperArr ~= nil then
		self.playerHelperArr[23] = data.isDirect;
		self.playerHelperArr[24] = GlobalTools:ToFloat( self.data:get_curAnger() )
		self.playerHelperArr[25] = GlobalTools:ToFloat( self.data:get_maxAnger() )
	end
end

--当玩家血量更新时通知显示层更新血量
function M:PlayerModelHpChange( eventName, data )
	--把最新的血量通知 Unity 层
	self:updateHpBar( data );
end

--检测是否是助阵角色
function M:checkApostle()
	return self.model:checkApostle()
end

--设定血量之更新血条
function M:updateHpBar( data )
	--更新血条
	if self.playerHelperArr ~= nil then
		self.playerHelperArr[20] = data.isDirect;
		self.playerHelperArr[21] = GlobalTools:ToFloat( self.data:get_curHp() )
		self.playerHelperArr[22] = GlobalTools:ToFloat( self.data:get_hp() )
		if self.playerHelperArr[22] >= 2147483647 then
			-- 保留两位小数
			self.playerHelperArr[21] = self.playerHelperArr[21]/self.playerHelperArr[22] * 10000	
			self.playerHelperArr[22] = 10000
		end
	end
end

--开始加载人物的资源
function M:loadAllPlayerAssets()
	--人物抖动的曲线数据
	ResourceUtil:LoadCurves(self.prefabRoot, function(shakeCurves)
		--人物曲线异步加载 
		self.shakeCurves = shakeCurves;
	end)
	--创建玩家预制
	self:createPrefab()
	--创建人物的同时去加载特效
	if SceneManager.curScene.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.LEGEND then
		ResourceUtil:LoadAssetAllAsync( self.effectBundleName,function()
			self.isEffectLoadFinish = true;
			self:loadPlayerFinish();
		end);
	else
		self.isEffectLoadFinish = true;
		self:loadPlayerFinish();
	end
end

--创建预制体
function M:createPrefab()
	self.isDestoryMe = false;
	ResourceUtil:LoadRole3dAsync(self.prefabName, self.parent, function(obj)
		if not obj then
			Logger.logError(self.prefabName, "加载预角色制体失败")
		end
		self:LoadFinishRolePrefab(obj);
	end)
end

--加载人物完成
function M:loadPlayerFinish()
	if self.isPrefabLoadFinish and self.isEffectLoadFinish then
		if self.isPlayerLoadFinish == false then
			self:finishCreate();
			self.isPlayerLoadFinish = true;

			if self.plySkill ~= nil then
				self.plySkill:loadFinish({player = self})
			end
		end
	end
end

function M:testHitPlayer()
	local hitFlag = false
	if not IsNull(self.obj) and CS.wt.framework.PhysicsTool.TestGetHitPlayer then
		local objList = CS.wt.framework.PhysicsTool.TestGetHitPlayer(self.obj)
		Logger.log(self.prefabName .. " ==== " .. tostring(objList.Count),"----------------- testHitPlayer objList.Count : ")
		hitFlag = objList.Count > 0
	end
	return hitFlag
end
--创建脚底UI
function M:MakeFootUI()
	if self.obj ~= nil then
		local sceneInfo = Battle.BattleGlobalConfig.SCENE_ID_INFO[SceneManager.curScene.sceneId]
		--战斗，天机楼战斗，迷宫战斗，创建脚底UI
		if sceneInfo and sceneInfo.hero_showLevel then
			if self.camp == 1 then
				self:CreateFootUI();
			end
		end
		if sceneInfo and sceneInfo.enemy_showLevel and SceneManager.curScene.sceneCanshowLV then
			if self.camp == -1 and SceneManager.curScene.mode ~= GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then -- 奇门遁甲boss不创建等级
				self:CreateFootUI();
			end
		end
	else
		self:addModelTask( function()
			local sceneInfo = Battle.BattleGlobalConfig.SCENE_ID_INFO[SceneManager.curScene.sceneId]
			--战斗，天机楼战斗，迷宫战斗，创建脚底UI
			if sceneInfo and sceneInfo.hero_showLevel then
				if self.camp == 1 then
					self:CreateFootUI();
				end
			end
			if sceneInfo and sceneInfo.enemy_showLevel and SceneManager.curScene.sceneCanshowLV then
				if self.camp == -1 then
					self:CreateFootUI();
				end
			end
		end)
	end
end


--人物预制体加载完成
function M:LoadFinishRolePrefab( obj )
	if self.isDestoryMe then
		if self.createFinish ~= nil then
			self:createFinish(self);
		end
		return;
	end
	self.obj = obj;
	if self.obj ~= nil then
		--人物 Transfrom 组件
		self.tran = self.obj:GetComponent("Transform")
		
		--所有 玩家Lua控制
		self.luaViewHelper = self.obj:GetComponent("PlayerLuaViewHelper")
		self.luaViewHelper.enabled = true;
		self.luaViewHelper:RefreshShadow();
		self.meshs = self.obj:GetComponentsInChildren(typeof(CS.UnityEngine.SkinnedMeshRenderer), true)
		
		for i = 1, self.meshs.Length do
			self.meshs[i - 1].gameObject:SetActive(true)
		end
		
		if self.luaViewHelper ~= nil then
			--给人物设置了20个预留位置
			--1~3人物位置信息
			--4~6人物旋转信息
			--7 人物移动速度
			--8 是否直接设置位置
			--9 人物旋转速度
			--10 是否直接设置旋转
			--11 人物动画速度
			--12 ~ 20 给人预留

			self.playerHelperArr = LuaCSharpArr.New(25)
			local CSharpAccess = self.playerHelperArr:GetCSharpAccess()
			self.luaViewHelper:PinTable(CSharpAccess)
			
			--初始化所有
			self.luaViewHelper:InitAll()
			
			self.luaViewHelper.camp = self.camp;
			if self.luaViewHelper ~= nil and self.luaViewHelper.m_effect ~= nil then
				self.luaViewHelper.m_effect.openFootEffect = SceneManager.curScene.use_foot_effect;
			end
			self.luaViewHelper.enabled = true;
			self.luaViewHelper.isSetPosition = true;
			self.luaViewHelper.isSetRotation = true;
			
			----播放声音组件
			if self.luaViewHelper.akGameObj ~= nil then
				self.have_sound = true
				ResourceUtil:LoadRoleSound(self.effect_prefabRoot)
			end

			--人物预制体上 LuaTransformHelper 脚本引用
			self.tranformHelper = self.luaViewHelper.tranformHelper
			self.tranformHelper.camp = self.camp;
			self.tranformHelper.index = self.index;
			
			--寻路组件
			self.navAgent = self.luaViewHelper.navAgent
			if self.navAgent ~= nil then
				self.navAgent.enabled = false;
			end

			--人物显示数据组件
			self.dataShow = self.luaViewHelper.dataShow;

			--数据显示组件,只有编辑器平台才运行
			if self.dataShow ~= nil and GameUtil:getpPlatform() == "Editor" then
				self.dataShow:Init(self.plyType, self.camp)
			end
			
			self:setScale(0)

			--人物点击组件 BoxCoillder
			self.raycheckBox = self.luaViewHelper.raycheckBox
			--人物身体的Transform信息
			self.body = self.luaViewHelper.body
			if self.body ~= nil then
				local scale = self.body.transform.localScale
				if scale.x > 0 then
					scale.x = 1
				else
					scale.x = -1
				end
				scale.y = 1;
				scale.z = 1;
				self.body.transform.localScale = scale
				self.body.gameObject:SetActive(false)
			end
			self.tran.transform.rotation = Quaternion.Euler(0,90,0)
			--人物头部的Transform信息
			self.head = self.luaViewHelper.head or self.body
			--人物脚底位置
			self.foot = self.luaViewHelper.foot or self.body
			--人物脚底射击点
			self.shootPoint = self.luaViewHelper.shootpoint
			--人物胸骨
			self.spine = self.luaViewHelper.spine

			if self.spine == nil then
				self.spine = self.obj
			end
			--动画系统
			self.anim = self.luaViewHelper.m_anim
			--self.anim.enabled = false;
			self.anim.enabled = true;
			
			--人物移动速度 8 
			self.playerHelperArr[7] = 8
			--人物旋转速度 15
			self.playerHelperArr[9] = 15
			--人物动画速度 1 
			self.playerHelperArr[11] = 1
			--设定朝向
			self.playerHelperArr[12] = 1

			self:refreshTable();
			self:CreateTalk();
			
			--还原所有的材质球
			self.luaViewHelper:ResetMaterial(0, true);
			if SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.DRAGONSWORD  then
				if self.camp == -1 then
					self.luaViewHelper:AddMaterial("CopyFiles_w_heh_skill3_born1",3);
				end
			end
		else
			Logger.logError("没有找到  self.luaViewHelper ~~~~~~~~~~~~~~~~~ "..self.obj.name )
		end
	else
		Logger.logError("加载prefab失败")
	end
	
	TimeTools:delayTimeUnity(0.2, function()
		self.isPrefabLoadFinish = true;
		self:loadPlayerFinish();
	end)
end

function M:finishCreate()
	self:runTask();
	self:setScale(self.scale);
	--
	if IsNull(self.body) == false then
		self.body.gameObject:SetActive(true)
	end
	--动画执行加载完成设置
	self.animator:player_loadFinish()
	if SceneManager.curScene ~= nil and SceneManager.curScene.buzheng == true then
		if self.model:get_isStageBoss() and SceneManager.curScene.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
			self:setBossEffect()
		end
	end
	--敌人显示上阵特效
	if self.camp == -1 and SceneManager:getCurSceneModel() and SceneManager:getCurSceneModel():get_sceneState() ~= SceneManager.SceneState.SceneRunning then
		self.m_shangzhen_effect_obj = ResourceUtil:LoadCommonEffect("Skill_ShangZhen_001",nil)
		if self.m_shangzhen_effect_obj ~= nil then
			self.m_shangzhen_effect_obj.transform.position = self.position;
			TimeTools:delayTimeUnity(2, function()
				if not IsNull(self.m_shangzhen_effect_obj) then
					ResourceUtil:ReturnItem(self.m_shangzhen_effect_obj)
					self.m_shangzhen_effect_obj = nil
				end
			end)
		end
	end

	--给model一个回调加载完成
	if self.model.loadPlayerViewFinish ~= nil then
		self.model.loadPlayerViewFinish(self)
	end
end

function M:setBossEffect()
	--显示指针
	if IsNull(self.luaViewHelper) == false and self.luaViewHelper ~= nil and self.luaViewHelper.m_ui ~= nil then
		self.stageBossUI = self.luaViewHelper.m_ui:CreateStageBossUI(self.head)
	end
	--显示特效
	ResourceUtil:LoadCommonEffectAsync("Skill_JiaoDi_001", self.obj, function(effect)
		self.stageBossEffect = effect
		local pos = effect.transform.localPosition
		pos.x = 0
		pos.y = 0
		pos.z = 0
		effect.transform.localPosition = pos
	end)
end

--更新
function M:update(dt)
	----更新动画状态机
	--if self.animator ~= nil then
	--	self.animator:update(dt);
	--end
	----连线管理器
	--if self.lineMgr ~= nil then
	--	self.lineMgr:update(dt)
	--end
	----移动管理器
	--if self.moveMgr ~= nil then
	--	self.moveMgr:update(dt)
	--end
	----额外的头顶ui管理器
	--if self.headUIMgr ~= nil then
	--	self.headUIMgr:update(dt)
	--end
	if GameVersionConfig.Debug then
		if self.dataShow ~= nil and self.data ~= nil and GameUtil:getpPlatform() == "Editor" then
			self.dataShow:RefreshData(self.data)
			self.dataShow:RefreshAnger(self.data:get_curAnger())
		end
		--=========================================  测试代码(只在编辑器模式下生效) =================================================
		if GameUtil:getpPlatform() == "Editor" then
			if U3DUtil:Input_GetKeyDown("w") then
				--and (self.aiEngine.curConfig == nil or self.aiEngine.curConfig.anim_name ~= "skill3")
				self:dispatchEvent_Local(Battle.EventType.VM_PlayerViewClickDown, {key = "w"})
			end

			if U3DUtil:Input_GetKeyDown("a") then
				self:dispatchEvent_Local(Battle.EventType.VM_PlayerViewClickDown, {key = "a"})
			end

			if U3DUtil:Input_GetKeyDown("d") then
				self:dispatchEvent_Local(Battle.EventType.VM_PlayerViewClickDown, {key = "d"})
			end

			if U3DUtil:Input_GetKeyDown("o") then
				self:dispatchEvent_Local(Battle.EventType.VM_PlayerViewClickDown, {key = "o"})
			end
		end
	end
end

function M:setForwardForce( isForce )
	if self.playerHelperArr ~= nil then
		if isForce ~= nil and isForce == true then
			self.playerHelperArr[10] = 1
		else
			self.playerHelperArr[10] = 0
		end
	end
end

function M:setPositionForce( isForce )
	if self.playerHelperArr ~= nil then
		if isForce ~= nil and isForce == true then
			self.playerHelperArr[8] = 1
		else
			self.playerHelperArr[8] = 0
		end
	end
end

--通知Unity层更新位置
function M:refreshTable()
	if self.playerHelperArr ~= nil then
		--刷新位置
		if self.position ~= nil then
			self.playerHelperArr[1] = self.position.x
			self.playerHelperArr[2] = self.position.y
			self.playerHelperArr[3] = self.position.z
		end
		--刷新朝向
		--迷宫场景不旋转
		if SceneManager.curScene.sceneId == SceneManager.SceneID.MiGongScene or
				SceneManager.curScene.sceneId == SceneManager.SceneID.JuBaoShanScene or
				SceneManager.curScene.sceneId == SceneManager.SceneID.QiMenDunJiaScene or
				SceneManager.curScene.sceneId == SceneManager.SceneID.GuJianQiTanScene or
				(SceneManager.curScene.sceneId == SceneManager.SceneID.ActiveBossScene and self.camp == -1) or
				(SceneManager.curScene.sceneId == SceneManager.SceneID.BossScene and self.camp == -1)  then
			if self.rotationOnlyX == false then
				self:rotationAll();
			else
				self:rotationOnlyXHandler();
			end
		else
			self:rotationOnlyXHandler();
		end
	end
end


function M:rotationAll()
	if self.forward ~= nil then
		self.playerHelperArr[4] = self.forward.x
		self.playerHelperArr[5] = self.forward.y
		self.playerHelperArr[6] = self.forward.z
	else
		self.playerHelperArr[4] = 0
		self.playerHelperArr[5] = 0
		self.playerHelperArr[6] = 0
	end
end


function M:rotationOnlyXHandler()
	if self.forward ~= nil then
		if self.forward.x >= 0 then
			if self.playerHelperArr[12] < 0 then
				self.playerHelperArr[10] = 1
			end
			self.playerHelperArr[12] = 1
			self.playerHelperArr[4] = 1
		else
			if self.playerHelperArr[12] > 0 then
				self.playerHelperArr[10] = 1
			end
			self.playerHelperArr[12] = -1;
			self.playerHelperArr[4] = -1
		end
	end
	self.playerHelperArr[5] = 0
	self.playerHelperArr[6] = 0
end

--设定位置
function M:setPosition()
	if self.enemy ~= nil and self.enemy.tran ~= nil then
		if self.tranformHelper ~= nil then
			self.tranformHelper:SetTargetEnemy(self.enemy.tran.position)
		end
	end
	if self.player_move_target ~= nil then
		if self.tranformHelper ~= nil then
			self.tranformHelper:SetTarget(self.player_move_target.worldPosition)
		end
	end
end


--设定父级
function M:setParent( obj )
	self.obj.transform:SetParent(obj.transform);
end


function M:MV_PlayerModelHideBody(eventName, data)
	if self.tranformHelper ~= nil then
	    local obj = self.tranformHelper:FindObj(self.tran, "body")
	    obj:SetActive(data.show)
		
		--隐藏阴影
		local shadow = self.tranformHelper:FindObj(self.tran, "shadow")
		if IsNull(shadow) == false then
			shadow:SetActive(data.show)
		end
		
		--Logger.logError(debug.traceback(), " MV_PlayerModelHideBody ")
		self.isHide = not data.show
	end
end


function M:MV_PlayerModelShowHpBar(eventName, data)
	self:ShowHpBar(data.show)
end


--治疗
function M:MV_PlayerModelCure(eventName, data)
	self.cure_list:add({ time = 0.1, data = data });
end


function M:setScale(scale)
	local scale_common = GlobalTools:ToFloat(scale);
    if self.tran ~= nil and IsNull(self.tran) == false then
       self.tran.localScale = Vector3(scale_common,scale_common,scale_common);
    end
end

------------------------ 特效相关 -------------------------
--删除品质特效
function M:deleteLevelEffect()
	for i = 1, self.standEffects.Count do
		local effect = self.standEffects:get(i-1)
		ResourceUtil:ReturnItem(effect);
	end
	self.standEffects:clear()
end

--创建品质特效
function M:createLevelEffect()
	local sceneInfo = Battle.BattleGlobalConfig.SCENE_ID_INFO[SceneManager:getCurSceneModel().sceneId]
	if sceneInfo ~= nil then
		local showStand = false;
		if sceneInfo.hero_showStand and self.camp == 1 then
			showStand = true;
		end
		if sceneInfo.enemy_showStand and self.camp == -1 then
			showStand = true;
		end
		if showStand then
			local effectName = self:getEffectNameByPlayer()
			if effectName ~= "" then
				ResourceUtil:LoadCommonEffectAsync(effectName, SceneManager.curScene.obj, function(effect)
					if effect ~= nil then
						self.standEffects:add(effect);
						local config_pos = SceneManager.curScene:findSpawnPosition(self.camp, self.index);
						if config_pos ~= nil then
							effect.transform.position = config_pos:toVector3()
						else
							effect.transform.position = Vector3(0,0,0)
						end
						local pos = effect.transform.position;
						pos.y = 0.02;
						effect.transform.position = pos;
					end

					if self.isDestoryMe == true then
						self:deleteLevelEffect();
					end
				end)
			end
		end
	end
end


--更新品质特效
function M:updateLevelEffect()
	for i = 1, self.standEffects.Count do
		local effect = self.standEffects:get(i-1)
		if effect ~= nil then
			local spawnPos = SceneManager.curScene:findSpawnPosition(self.camp, self.index);
			spawnPos = spawnPos:toVector3();
			effect.transform.position = spawnPos
			local pos = effect.transform.position;
			pos.y = 0.02;
			effect.transform.position = pos;
		end
	end
end


--获取品质特效名称
function M:getEffectNameByPlayer()
	local evo = self.data:get_evo()
	if evo == 2 then
		return ""
	end
	local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[evo] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
	return quality_item.hero_3d_base
end

function M:resetAllData()

end

function M:getNameByPlyType(name_str)
	name_str = string.gsub(name_str,string.gsub(self.default_plyType,"%d+","") , self.plyType)
	return name_str
end

----------------------------------------- 流程控制相关 --------------------------------------------
--玩家出生
function M:spawn(dyns)
	--id 为2 是普通推关战斗
	--id 为3 是boss战斗
	--id 为7 天机楼战斗
	--id 为9 迷宫战斗
	if self.luaViewHelper ~= nil then
		self.luaViewHelper:Spawn();
	end
	
	local sceneInfo = Battle.BattleGlobalConfig.SCENE_ID_INFO[SceneManager.curScene.sceneId]
	if self.camp == 1 then
		if sceneInfo and sceneInfo.hero_showHp == true then
			--创建血条 
			self:setUI();
		end
	end
	if self.camp == -1 then
		if sceneInfo and sceneInfo.enemy_showHp == true and SceneManager.curScene.sceneCanshowHp then
			--创建血条 
			self:setUI()
		end
	end

	if self.footUI ~= nil then
		self.footUI:Destroy()
	end
	--self:ShowHpBar(false)
	if self.playerHelperArr ~= nil then
		self.playerHelperArr[21] = GlobalTools:ToFloat(math.floor( self.data:get_curHp() ))
		self.playerHelperArr[22] = GlobalTools:ToFloat(math.floor( self.data:get_hp() ))
	end

	if not IsNull(self.stageBossEffect) then
		ResourceUtil:ReturnItem(self.stageBossEffect)
		self.stageBossEffect = nil
	end
	if not sceneInfo then
		Logger.logErrorAlways(SceneManager.curScene.sceneId,"玩家出生 sceneId ==")
	end
end

--游戏暂停
function M:pause()
	if self.animator ~= nil then
		self.animator.anim.speed = 0
	end
end

--游戏继续
function M:continue()
	if self.animator ~= nil then
		self.animator.anim.speed = self.data:getHaste()
	end
end

--设定UI
function M:setUI()
	self:CreateHp()
	self:CreateBuffLabel()
	self:CreatePetLightEffect()
	--被动中设置创建血条
	local skill_items = self.model:get_plySkill().skill_items
	for i = 1, skill_items.Count do
		local config =  skill_items:get(i - 1).cur_skill_config
		if config ~= nil and config.feature ~= nil then
			config.feature:CreateHp()
		end
	end
	--if self.stageBossUI ~= nil then
	--	self.stageBossUI:Destroy()
	--end
end


--创建血条
function M:CreateTalk()
	if self.player_talk == nil then
		if IsNull(self.luaViewHelper) == false and self.luaViewHelper ~= nil and self.luaViewHelper.m_ui ~= nil then
			self.player_talk = self.luaViewHelper.m_ui:CreateTalk( self.head )
		end
	end
end

--设定 talk 的缩放
function M:SetTalkScale( scale )
	if self.player_talk ~= nil then
		self.player_talk:SetScale( scale )
	end
end

function M:talk( text, time )
	if true then
		return
	end
	time = time or 2.5
	if self.player_talk ~= nil then
		self.player_talk:talk( text ,time );
	end
end


--创建血条
function M:CreateHp()
	if SceneManager.curScene ~= nil and SceneManager.curScene.buzheng then -- 斗技第一阶段创建
		return
	end
	if SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE then
		if SceneManager.curScene.hero_train_cfg == nil then
			return;
		end
		local battle_id = SceneManager.curScene.hero_train_cfg.stage_battle
		local stage_battle_tab = ConfigManager:getCfgByName("stage_battle_active")
		local hp_switch = stage_battle_tab[battle_id].hp_switch
		if self.camp == -1 and hp_switch[self.index + 1] == 0 then
			return
		end
	elseif SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.WORLD_BOSS then
		if self.camp == -1 then
			return
		end
	elseif SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
		if self.camp == -1 then
			return
		end
	elseif SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
		if self.camp == -1 then
			return
		end
	elseif SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.LEGEND then
		if self.camp == -1 and SceneManager.curScene.battle_mode == 2 then
			return
		end
	end
	if self.hpBar == nil and self.summonType ~= "special" then
		if IsNull(self.luaViewHelper) == false and self.luaViewHelper ~= nil and self.luaViewHelper.m_ui ~= nil then
			self.hpBar = self.luaViewHelper.m_ui:CreateHpBar(self.camp, self.data:get_hp(), self.head, self.model:get_isStageBoss());
			local luaBehaviour = UIUtil.findLuaBehaviour(self.hpBar.m_obj)
			if not IsNull(self.hpBar.m_obj) then
				self.hpNode = luaBehaviour:FindGameObject("hp");
			end
			if not IsNull(self.hpBar.m_obj) and self.fate_level ~= nil then
				local fate_common = ConfigManager:getCfgByName("fate_common")
				local fate_common_config = fate_common[self.plyData.id]
				if fate_common_config ~= nil then
					local bg = luaBehaviour:FindImage("bg");
					local skyStarImg = luaBehaviour:FindImage("skyStarImg")
					if not IsNull(bg) then
						local bg_canvas_group = bg:GetComponent("CanvasGroup")
						if not IsNull(bg_canvas_group) then
							DOTweenModuleUI.DOFade(bg_canvas_group, 1, 0.2)
						end
					end
					skyStarImg.gameObject:SetActive(true)
					UIUtil.setImg(skyStarImg, fate_common_config.battle_head, "language_zh_cn")
					local time = 1
					if fate_common_config.battle_head_show ~= nil then
						time = fate_common_config.battle_head_show
					end
					TimeTools:delayTimeUnity(time - 0.2, function()
						if not IsNull(bg) then
							local bg_canvas_group = bg:GetComponent("CanvasGroup")
							if not IsNull(bg_canvas_group) then
								DOTweenModuleUI.DOFade(bg_canvas_group, 0, 0.2)
							end
						end
					end)
				end
			end
		end
    end
end

--创建 Buff 列表
function M:CreateBuffLabel()
	local sceneInfo = Battle.BattleGlobalConfig.SCENE_ID_INFO[SceneManager.curScene.sceneId]
	if self.camp == 1 and sceneInfo and sceneInfo.hero_showBuffLabel ~= true then
		return
	end
	if self.camp == -1 and sceneInfo and sceneInfo.enemy_showBuffLabel ~= true then
		return
	end
	if sceneInfo and self.hpBar ~= nil then
		if self.luaViewHelper ~= nil then
			self.buffLabel = ResourceUtil:GetUIItem("Battle/BuffLabel", self.hpBar.m_obj, "ui_prefabs")
			if self.buffLabel ~= nil then
				local rect = self.buffLabel:GetComponent("RectTransform")
				local pos = rect.anchoredPosition3D
				pos.y = 24
				pos.x = 60
				pos.z = 0
				rect.anchoredPosition3D = pos
				local content = UIUtil.findTrans(rect, "content")
				self.bufMgr:initIcon()
				for i = 1, content.childCount do
					local child = content:GetChild(i - 1)
					local img = child:GetComponent("Image")
					local count_tran = child:GetChild(0)
					local text = count_tran:GetComponent("Text")
					self.bufMgr:addIcon( {image = img, count_text = text} )
				end
				self.bufMgr:refreshBuffIcon()
			end
		end
	end
end

--创建 斗技第一阶段灯光 列表
function M:CreatePetLightEffect()
	if Battle.BattleFSM.curState ~= Battle.BattleFSM.BATTLE_STATES.PetContest then -- 斗技第一阶段创建
		--return
	end
	if self.camp == 1 and SceneManager.curScene.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.PET_DOUJI then
		return
	end
	if self.camp == -1 and SceneManager.curScene.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.PET_DOUJI then
		return
	end
	if self.hpBar ~= nil and self:get_master() == nil then
		if self.index == 1 then
			self.hpBar.m_obj.transform:SetAsFirstSibling()
		end
		if self.luaViewHelper ~= nil then
			self.lightEffect = ResourceUtil:GetUIItem("Battle/PetLightLabel", self.hpBar.m_obj, "ui_prefabs")
			if self.lightEffect ~= nil then
				local rect = self.lightEffect:GetComponent("RectTransform")
				local pos = rect.anchoredPosition3D
				pos.y = 10
				pos.x = 50
				pos.z = 0
				rect.anchoredPosition3D = pos
				self.lightEffect:SetActive(false)
			end
			local luaBehaviour = UIUtil.findLuaBehaviour(self.lightEffect)
			if not IsNull(luaBehaviour) then
				local power_text = luaBehaviour:FindText("power_text")
				power_text.text = Language:getTextByKey("pet_battle_power")
				local effectNode = luaBehaviour:FindGameObject("EffectNode")
				local winIcon = luaBehaviour:FindGameObject("winIcon")
				local moodIcon = luaBehaviour:FindImage("moodIcon")
				local mood_randomCfg = ConfigManager:getCfgByName("mood_random")
				local mood_cfg = mood_randomCfg[self.model.mood]
				if mood_cfg and moodIcon and mood_cfg.icon then -- 心情
					LuaBehaviourUtil.setImg(luaBehaviour,"moodIcon", mood_cfg.icon, "battle_ui")
				else
					moodIcon.gameObject:SetActive(false)
				end
				if winIcon then
					winIcon:SetActive(false)
				end
				local power_content = luaBehaviour:FindRectTransform("power_content")
				local power_content_luaBehaviour = power_content:GetComponent("LuaBehaviour")
				self:refreshNum(GlobalTools:ToFloat(self.model.data.power:getValue()), power_content, power_content_luaBehaviour)
				if not IsNull(self.hpNode) then
					self.hpNode:SetActive(false)
				end
				local pos = self.model.index or 0
				TimeTools:delayTimeUnity(pos+1 , function()
					if self.lightEffect then
						self.lightEffect:SetActive(true)
					end
					audio:SendEvtUI("UI_GSu")
					self:playPetContestEffect({autodestoryTime = 1, prefab = "P_Pet_DouQi", autoMirror = true}, self, self)
					self:playPetContestEffect({autodestoryTime = 1, prefab = "P_Pet_GuangShu", autoMirror = true}, self, self)
					if winIcon and self.model.power_win == 1 then -- 胜利标志
						winIcon:SetActive(true)
						--self:playPetContestEffect({autodestoryTime = 1, prefab = "P_Pet_ShengLi"}, self, self)
						self:playPetContestEffect({autodestoryTime = 999, prefab = "P_Pet_ShengLi02", autoMirror = false}, self, self)
					end
					
				end)
			end
		end
	end
end

function M:showPetHpNode()
	if not IsNull(self.hpNode) then
		self.hpNode:SetActive(true)
	end
end

function M:refreshNum(num, rect, luaBehaviour)
	local num_str = tostring(math.floor(num))
	for i = 1, 5 do
		if i <= string.len(num_str) then
			LuaBehaviourUtil.setImg(luaBehaviour, "num"..tostring(i), "a_jhcg_"..string.sub(num_str,i,i), "main_ui")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num"..tostring(i), true)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num"..tostring(i), false)
		end
	end
end

function M:hidePetPowerNode()
	if self.lightEffect ~= nil then
		self.lightEffect:SetActive(false)
	end
end

--显示隐藏血条
function M:ShowHpBar(show)
	if IsNull(self.hpBar) == false then
		self.hpBar:Show(show)
		if show then
			self.hpBar:Refresh()
		end
	end
end

--创建脚底UI
function M:CreateFootUI()
	if self:get_master() == nil then
		local race_data = GlobalConfig.TYPE_HERO_RACE[self.plyData.race]
		local level = GameUtil:getDisplayLvByLevel( self.data:get_level(), SceneManager:getCurSceneModel().mode)
		if SceneManager:getCurSceneModel().m_ext_data.fair and SceneManager:getCurSceneModel().m_ext_data.fair == 1 then
			local h_cfg = UserDataManager.hero_data:getHeroConfigByCid(self.model.playerId)
			local mode = SceneManager:getCurSceneModel().mode
			if mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_ONE or mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_THREE then
				local show_fair_lv_cfg = ConfigManager:getCommonValueById(721) or {{3,150},{5,300}}
				local commonHeroData1 = show_fair_lv_cfg[1]
				local commonHeroData2 = show_fair_lv_cfg[2]
				if h_cfg.evo == commonHeroData1[1] then
					level = commonHeroData1[2]
				elseif h_cfg.evo == commonHeroData2[1] then
					level = commonHeroData2[2]
				end
			end
		end
		local race_icon = race_data.race_icon
		if self.model.playerType == "pet" or  SceneManager:getCurSceneModel().mode == GlobalConfig.BATTLE_MODE.PET_DOUJI  then
			level = GameUtil:getPetRealLevelByLv(level)
			race_icon = GameUtil:getPetEvoIconByEvo(self.model.evo)
		end
		if not IsNull(self.luaViewHelper) and not IsNull(self.luaViewHelper.m_ui) then
			self.footUI = self.luaViewHelper.m_ui:CreateFootUI(self.camp,
					self.head,
					race_icon,
					level, 
					Language:getTextByKey("new_str_0428") )
			if not IsNull(self.footUI) then
				self.footUI:ResetTarget(self.head)
			end
		end	
	end
end

--显示攻击UI
function M:ShowHitUI( m_type, attackData )
	local player = attackData["player"]
	local player_view = self.plyMgr:GetPlayerViewByModel(player)
	local skill = attackData["skillConfig"]
	if IsNull(self.luaViewHelper) == false and self.luaViewHelper ~= nil and self.luaViewHelper.m_ui ~= nil then
		local attackerAnger = attackData["attackerAnger"] or 0
		local defenderAnger = attackData["defenderAnger"] or 0
		if m_type == 6 then
			self:createHpLabel("", 6)

			--闪避了，可以弹出字体 闪避字样
			if GameUtil:getpPlatform() == "Editor" then
				local skillName = ""
				if skill ~= nil then
					skillName = skill.anim_name
				end
				if player_view ~= nil and player_view.dataShow ~= nil  then
					self:addDamageData(player_view, true, self.plyType, 0, skillName, false, false, true, attackerAnger, defenderAnger)
				end
				if self.dataShow ~= nil and player ~= nil then
					self:addDamageData(self, false, player.plyType, 0, skillName, false, false, true, attackerAnger, defenderAnger)
				end
			end
		elseif m_type == 7 then
			--无敌了，可以弹出字体 免疫字样
			self:createHpLabel("", 7)
			if GameUtil:getpPlatform() == "Editor" then
				local skillName = ""
				if skill ~= nil then
					skillName = skill.anim_name
				end
				if player_view ~= nil and player_view.dataShow ~= nil  then
					self:addDamageData(player_view, true, self.plyType, 0, skillName, false, true, false, attackerAnger, defenderAnger)
				end
				if self.dataShow ~= nil  then
					self:addDamageData(self, false, player.plyType, 0, skillName, false, true, false, attackerAnger, defenderAnger)
				end
			end
		end
	end
end

--bool isKiller, string plyType, float damage, string skill, bool crit, bool god, bool dodge

---@param player Player_View
function M:addDamageData(player, isKiller, plyType, damage, skill, crit, god, dodge, attackerAnger, defenderAnger)
	if SceneManager.curScene.sceneId ~= SceneManager.SceneID.HangUpScene then
		player.dataShow:AddDamageData(isKiller, plyType, damage, skill, crit, god, dodge, attackerAnger, defenderAnger)
		if player:get_playerInstanceId() ~= nil then
			local data = {}
			data.isKiller = isKiller;
			data.plyType = plyType;
			data.damage = damage;
			data.skill = skill;
			data.crit = crit;
			data.god = god;
			data.dodge = dodge;
			
			local playerShowData = SceneManager:getData(player:get_playerInstanceId());
			if playerShowData == nil then
				playerShowData = {}
			end
			if isKiller then
				if playerShowData.attack_list == nil then
					playerShowData.attack_list = {}
				end
				table.insert(playerShowData.attack_list,1, data)
			else
				if playerShowData.injure_list == nil then
					playerShowData.injure_list = {}
				end
				table.insert(playerShowData.injure_list,1, data)
			end
			SceneManager:setData(player:get_playerInstanceId(), playerShowData);
		end
	end
end


--直接攻击的UI表现
--prefabName 预制名称
--attackData 攻击数据
--isCrit 是否暴击
--damage 伤害
---@param player PlayerModel
function M:beHitDirect(player, attackData, isCrit)
	local hitAudio = attackData["hitAudio"]
	local key = "injureHit"
	
	if attackData["hitEffectList"] ~= nil then
		--如果配置了暴击特效，则尝试播放暴击特效
		local hasCritEffect = false
		for k,v in ipairs(attackData["hitEffectList"]) do
			if v.type == "critHit" then
				hasCritEffect = true
				break
			end
		end
		if hasCritEffect == true then
			if isCrit == true then
				key = "critHit"
			end
		end
		for k,v in ipairs(attackData["hitEffectList"]) do
			if v.type == key then
				local effectData = {}
				effectData["prefab"] = v["prefab"]
				effectData["hitEffectAngle"] = v["eulerAngle"] or Vector3.New(0,0,0)
				effectData["hitEffectScale"] = v["scale"] or Vector3.New(1,1,1)
				effectData["autodestoryTime"] = v["autoDestroy"]
				if effectData["autodestoryTime"] == nil or effectData["autodestoryTime"] <= 0 then
					effectData["autodestoryTime"] = 3
				end
				effectData["parent"] = v["parent"]

				if attackData ~= nil then
					effectData["injurePosition"] = v["position"]
				end
				self:playInjureEffect(effectData, self,  player);
			end
		end
	end


	if hitAudio ~= nil and hitAudio ~= "" and hitAudio ~= "nil" and player ~= nil then
		if string.find(hitAudio, ":")  then
			local info = string.split(hitAudio, ":")
			if #info == 2 then
				local bankName = info[1]
				local soundName = info[2]
				local playerView = self.plyMgr:getPlayerByInstanceId(player:get_playerInstanceId())
				playerView = playerView or self
				if playerView.banks[bankName] == nil then
					playerView.banks[bankName] = 1
					ResourceUtil:LoadBank(bankName)
				end
				StateSoundManager:playSkillSoundFromBank(soundName, bankName);
			else
				Logger.logError(hitAudio, "错误的受击音效")
			end
		else
			StateSoundManager:playSkillSound(hitAudio, player)
		end
	end

	--闪光
	if IsNull(self.luaViewHelper) == false then
		--不是 Boss 才闪光
		if self.isBoss == false then
			self.luaViewHelper:BeHit();
		end
	end
end

function M:showData(player, attackData, damage, isCrit)
	if GameUtil:getpPlatform() == "Editor" then
		local skill = attackData.skillConfig
		local skillName = ""
		if skill ~= nil then
			skillName = skill.anim_name
		end
		if attackData.injureType ~= nil and (attackData.injureType == "dot" or attackData.injureType == "buff" or attackData.injureType == "realDamage") then
			skillName = skillName .. "_" .. attackData.injureType
		end
		local player_view = self.plyMgr:GetPlayerViewByModel(player)

		local attackerAnger = attackData["attackerAnger"] or 0
		local defenderAnger = attackData["defenderAnger"] or 0

		if player_view ~= nil and player_view.dataShow ~= nil  then
			self:addDamageData(player_view, true, self.plyType, damage, skillName, isCrit, false, false, attackerAnger, defenderAnger)
		end
		if self.dataShow ~= nil  then
			if player ~= nil then
				self:addDamageData(self, false, player.plyType, damage, skillName, isCrit, false, false, attackerAnger, defenderAnger)
			else
				self:addDamageData(self, false, "", damage, skillName, isCrit, false, false, attackerAnger, defenderAnger)
			end
		end
	end
end

function M:addSkillEffectList(skillName, effect)
	if self.effectList[skillName] == nil then
		self.effectList[skillName] = {}
	end
	table.insert(self.effectList[skillName], effect)
end

function M:removeEffect( effect )
	if IsNull(self.luaViewHelper) == false and self.luaViewHelper.m_effect ~= nil then
		self.luaViewHelper.m_effect:RemoveEffect( effect )
	end
end

function M:MV_PlayerModelRemoveEffectByName( eventName, data )
	if IsNull(self.luaViewHelper) == false and self.luaViewHelper.m_effect ~= nil then
		self.luaViewHelper.m_effect:RemoveEffectByName( data.effect_name )
	end
end

function M:playEffect( effectData, ownerPlayer, effectPlayer, loadFinishCallBack )
	local effectPlayerTypeName = "";
	local obj = nil
	if ownerPlayer ~= nil then
		obj = ownerPlayer.obj;
		if obj == nil then
			local ownerPlayer_view = self.plyMgr:GetPlayerViewByModel(ownerPlayer);
			if ownerPlayer_view ~= nil then
				obj = ownerPlayer_view.obj;
			end
		end
	end
	if effectPlayer ~= nil then
		effectPlayerTypeName = effectPlayer.effect_prefabRoot;
	end

	--预制体
	local prefab = effectData.prefab;
	local parent = effectData.parent or nil;
	local directionType = effectData.directionType;
	local scaleType = effectData.scaleType;
	local positionType = effectData.positionType;
	local useUserSet = effectData.prefabTrans.useUserSet == true
	local autodestoryTime = tonumber(effectData.autodestoryTime);
	local isPutUpInParent = effectData.isPutUpInParent == true
	local position_x = tonumber(effectData.prefabTrans.position[1]);
	local position_y = tonumber(effectData.prefabTrans.position[2]);
	local position_z = tonumber(effectData.prefabTrans.position[3]);
	local rotation_x = tonumber(effectData.prefabTrans.rotation[1]);
	local rotation_y = tonumber(effectData.prefabTrans.rotation[2]);
	local rotation_z = tonumber(effectData.prefabTrans.rotation[3]);
	local scale_x = tonumber(effectData.prefabTrans.scale[1]);
	local scale_y = tonumber(effectData.prefabTrans.scale[2]);
	local scale_z = tonumber( effectData.prefabTrans.scale[3]);
	local autoMirror = effectData.autoMirror == true
	local mirrorPrefab = effectData.mirrorPrefab == true
	local isMirror = false
	if self.forward ~= nil and self.forward.x < 0 then
		if autoMirror then
			isMirror = true
		else
			if mirrorPrefab then
				prefab = prefab .. "_mirror"
			end
		end
	end
	if IsNull(self.luaViewHelper) == false and IsNull(self.luaViewHelper.m_effect) == false then
		local effect = self.luaViewHelper.m_effect:PlayEffect(prefab,
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
				obj, effectPlayerTypeName,
				loadFinishCallBack,
				isMirror);
		---- 解决特效中加animator暂停后speed是0，退出战斗特效加入缓存池，再次开始战斗animator的speed没有恢复
		--if self.luaViewHelper.ResumeEffectSpeed then
		--	self.luaViewHelper:ResumeEffectSpeed()
		--end
		TimeManager_View:resetEffectSpeed(self, effect, prefab)
		return effect
	end
end


function M:playInjureEffect( effectData, ownerPlaeyr, effectPlayer )
	effectData["isPutUpInParent"] = false
	--effectData["autodestoryTime"] = effectData["autoDestroy"]
	effectData["directionType"] = "playerForward"
	effectData["scaleType"] = "world"
	effectData["positionType"] = "parentOffset"
	
	local prefabTrans = {}
	prefabTrans["useUserSet"] = true
		--受伤位置
	local injurePos = effectData["injurePosition"]
	if injurePos ~= nil then
	--	effectData["positionType"] = "worldFix"
	--	prefabTrans["position"] = 
	--	{
	--		[1] = injurePos.x,
	--		[2] = injurePos.y,
	--		[3] = injurePos.z,
	--	}
	--else
		prefabTrans["position"] = 
		{
			[1] = injurePos.x,
			[2] = injurePos.y,
			[3] = injurePos.z,
		}
	end
	
	local injureRot = effectData["hitEffectAngle"]
	if injureRot ~= nil then
		prefabTrans["rotation"] = {
			[1] = effectData["hitEffectAngle"].x,
			[2] = effectData["hitEffectAngle"].y,
			[3] = effectData["hitEffectAngle"].z,
		}
	else
		prefabTrans["rotation"] = {
			[1] = 0,
			[2] = 0,
			[3] = 0,
		}
	end

	local injureScale = effectData["hitEffectScale"]
	if injureScale ~= nil then
		prefabTrans["scale"] = {
			[1] = effectData["hitEffectScale"].x,
			[2] = effectData["hitEffectScale"].y,
			[3] = effectData["hitEffectScale"].z,
		}
	else
		prefabTrans["scale"] = {
			[1] = 1,
			[2] = 1,
			[3] = 1,
		}
	end
	effectData["prefabTrans"] = prefabTrans
	self:playEffect( effectData ,ownerPlaeyr, effectPlayer );
end

--
----计算总的血量丢失
--function M:calculateTotalLostHp(hp_damage)
--    --发送事件
--	EventDispatcher:dipatchEvent("calculateDamage",{ player = self, totalLostHp = self.totalLostHp} )
--end

--我杀人了
function M:kill(player)

	if IsNull(self.luaViewHelper) == false and self.luaViewHelper ~= nil and self.luaViewHelper.m_ui ~= nil then
		if self.camp == 1 then
			self:createHpNumberLabel("+", self.data:getKillEnergy(), 9)
		else
			self:createHpNumberLabel("+", self.data:getKillEnergy(), 8)
		end

		if SceneManager.curScene.sceneId ~= 1 then
			TimeTools:delayTimeUnity(0.6,function()
				if IsNull(self.luaViewHelper) == false and self.luaViewHelper ~= nil and self.luaViewHelper.m_ui ~= nil then
					if self.killNum == 2 then
						self:createHpLabel("", 10)
					elseif self.killNum == 3 then
						self:createHpLabel("", 11)
					elseif self.killNum == 4 then
						self:createHpLabel("", 12)
					elseif self.killNum == 5 then
						self:createHpLabel("", 13)
					end
				end
			end)
		end
	end
end


function M:MV_PlayerModelSetIndex(eventName, data)
	self.index = self.model:get_index()
	if self.tranformHelper ~= nil then
		self.tranformHelper.index = self.index;
	end
end

function M:MV_PlayerModelSetRotationMode(eventName, data)
	self.rotationOnlyX = data.rotationOnlyX;
end

--受伤位移
function M:MV_PlayerModelPlayInjureAnim(eventName, data)
	if self.luaViewHelper ~= nil and self.luaViewHelper.InjureAnim ~= nil then
		if self.isBoss == false then
			--self.luaViewHelper:InjureAnim();
		end
	end
end

function M:MV_PlayerModelSetBoss(eventName, data)
	self.isBoss = data;
	if self.luaViewHelper ~= nil and self.luaViewHelper.SetBossTag ~= nil then
		self.luaViewHelper:SetBossTag(self.isBoss);
	end
end

function M:MV_PlayerModelSkillKillPlayer(eventName, data)
	if self.camp == 1 and data.skillConfig.kill_num > 0 and data.skillConfig.hasTalk == false then
		local hasTalk = LikeOO.BattleTalkControl:checkBattleTalk(1, data.skillConfig.kill_num)
		if hasTalk == true then
			data.skillConfig.hasTalk = true
		end
	end
end

function M:MV_PlayerModelSkillEnd(eventName, data)
	local skillConfig = data.skillConfig
	local skillEndData = data.skillEndData
	if skillConfig ~= nil and self.effectList ~= nil and skillConfig.skill_work == false and skillEndData.normalEnd ~= true then
		if self.effectList[skillConfig.anim_name] ~= nil then
			for k,v in pairs(self.effectList[skillConfig.anim_name]) do
				if v ~= nil then
					self:removeEffect(v)
				end
			end
		end
	end
end

function M:MV_PlayerModelSetEnemy(eventName, data)
	local enemy = data.enemy;
	if enemy ~= nil then
		local enemy_view = self.plyMgr:GetPlayerViewByModel(enemy)
		self:set_enemy(enemy_view)
	else
		self:set_enemy(nil)
	end
end


function M:MV_PlayerModelSyncTauntList(eventName, data)
	local action = data.action
	if action == "add" then
		local enemy = data.enemy;
		local enemy_view = self.plyMgr:GetPlayerViewByModel(enemy)
		self.tauntList:add(enemy_view)
	elseif action == "remove" then
		local removeAll = data.removeAll;
		if removeAll == true then
			self.tauntList:clear();
		else
			local enemy = data.enemy;
			local enemy_view = self.plyMgr:GetPlayerViewByModel(enemy)
			self.tauntList:remove(enemy_view)
		end
	end
end

--提交同步敌人列表
function M:MV_PlayerModelSyncEnemyList(eventName, data) 
	local action = data.action
	if action == "add" then
		if self.player_enemyList ~= nil then
			local enemy = data.enemy;
			local enemy_view = self.plyMgr:GetPlayerViewByModel(enemy)
			self.player_enemyList:add(enemy_view)
		end
	elseif action == "clear" then
		if self.player_enemyList ~= nil then
			self.player_enemyList:clear();
		end
	elseif action == "create" then
		self.player_enemyList = Battle.List.new()
	elseif action == "remove" then
		if self.player_enemyList ~= nil then
			local enemy = data.enemy;
			local enemy_view = self.plyMgr:GetPlayerViewByModel(enemy)
			self.player_enemyList:remove(enemy_view)
		end
	end
end

--真正死亡
function M:MV_PlayerModelRealDead(eventName, data)
	if IsNull(self.luaViewHelper) == false then
		if SceneManager.curScene.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.LEGEND then
			self.luaViewHelper:Dead();
		end
	end
    --删除脚底UI
	if IsNull(self.footEffect) == false then
		ResourceUtil:ReturnItem(self.footEffect)
		self.footEffect = nil;
	end
	self:removeHpBar()
	self:MV_PlayerModelStopTimeTask()
end

--游戏结束
function M:gameover( re )
	--删除特效
	if self.luaViewHelper ~= nil and self.luaViewHelper.m_effect ~= nil then
		self.luaViewHelper.m_effect:Destroy();
	end
end

--正真销毁 连bundle都要销毁掉
function M:destroy( isDestroyObj )
	if self.banks ~= nil then
		for k,v in pairs(self.banks) do
			ResourceUtil:UnLoadBank(k)
		end
		self.banks = nil
	end
	self.player_enemyList:clear();
	self.tauntList:clear();
	if not IsNull(self.obj) then
		if not IsNull(self.body) then
			local scale = self.body.transform.localScale
			scale.x = Mathf.Abs(scale.x)
			self.body.transform.localScale = scale
		end

		self.head = nil;
		self.body = nil;
		self.spine = nil;
		self.foot = nil;
		self.anim = nil;
		self.enemy = nil;
		self.tran = nil

		self:MV_PlayerModelStopTimeTask()
		self:removeHpBar()
		self:clearMgr();
		if not IsNull(self.footUI) then
			self.footUI:Destroy();
			self.footUI = nil;
		end

		if not IsNull(self.stageBossUI) then
			self.stageBossUI:Destroy();
			self.stageBossUI = nil;
		end

		if not IsNull(self.stageBossEffect) then
			ResourceUtil:ReturnItem(self.stageBossEffect)
			self.stageBossEffect = nil;
		end

		if self.player_talk ~= nil then
			self.player_talk:Destroy();
			self.player_talk = nil;
		end

		--删除特效
		if not IsNull(self.luaViewHelper) then
			self.luaViewHelper:Destroy();
			self.luaViewHelper = nil;
		end

		self:deleteLevelEffect();

		if self.dataShow ~= nil and GameUtil:getpPlatform() == "Editor" then
			self.dataShow:Clear()
			self.dataShow = nil;
		end

		TimeTools:stopTask(self.delayDestoryTask)

		if isDestroyObj == true then
			self:destoryAsset();
			self.obj = nil;
			if self.have_sound then
				ResourceUtil:UnLoadRoleSound(self.effect_prefabRoot)
			end
		else
			if self.camp == -1 then
				self:destoryAsset();
				self.obj = nil;
				if self.have_sound then
					ResourceUtil:UnLoadRoleSound(self.effect_prefabRoot)
				end
			else
				ResourceUtil:ReturnItem(self.obj);
				self.obj = nil;
			end
		end
	end
end

--销毁资源
function M:destoryAsset()
	--把人物先放回池中
	ResourceUtil:ReturnItem(self.obj)
	--根据引用计数删除bundle
	--移除玩家预制体
	ResourceUtil:AddReadyUnLoadBundle(self.bundelName, false );
	--移除特效文件
	ResourceUtil:AddReadyUnLoadBundle(self.effectBundleName, false );
	--销毁曲线数据
	if self.shakeCurves ~= nil then
		ResourceUtil:Destory("shakes",self.bundelName)
		self.shakeCurves = nil;
	end
	if not IsNull(self.m_shangzhen_effect_obj) then
		ResourceUtil:ReturnItem(self.m_shangzhen_effect_obj)
		self.m_shangzhen_effect_obj = nil
	end
	if not IsNull(self.luaViewHelper) then
		self.luaViewHelper:ResetMaterial(self.changeMaterialId, true)
	end
end

function M:removeHpBar()
	--血条销毁
	if self.hpBar ~= nil then
		if self.buffLabel ~= nil then
			ResourceUtil:ReturnItem(self.buffLabel)
			self.buffLabel = nil
		end
		if self.lightEffect ~= nil then
			ResourceUtil:ReturnItem(self.lightEffect)
			self.lightEffect = nil
		end
		if self.headUIMgr ~= nil then
			self.headUIMgr:destroy()
		end

		self.hpBar:Destroy()
		self.hpBar = nil
	end
	if not IsNull(self.stageBossUI) then
		self.stageBossUI:Destroy()
	end
	self.stageBossUI = nil

	if not IsNull(self.stageBossEffect) then
		ResourceUtil:ReturnItem(self.stageBossEffect)
	end
	self.stageBossEffect = nil
end

--斗技第一阶段灯光特效数字等 移除
function M:removeLightEffect()
	if self.lightEffect ~= nil then
		ResourceUtil:ReturnItem(self.lightEffect)
		self.lightEffect = nil
	end
end

--刷新卡牌
function M:refreshCard(show)
	if static_rootControl then
		static_rootControl:updateMsg("refreshCardEffect", {index = self.index, show = show}, "GamePanel")
	end
end


--受伤暂停
function M:injurePause(time)
	self.anim.speed = 0
end

--设置动画速度
function M:setAnimSpeed(speed)
	if IsNull(self.luaViewHelper) == false then
		if self.playerHelperArr ~= nil then
			self.playerHelperArr[11] = speed
		else
			Logger.logError(self.plyType.." self.playerHelperArr 没有初始化 ~~~ ")
		end
	end
end

-- ********************************************************************
-- 黑屏处理
-- ********************************************************************

--开始设定黑屏的时候做的处理
function M:startBlackTimeHandler()
	
	--给Unity设定黑屏时间
	if IsNull(self.luaViewHelper) == false then
		self.luaViewHelper:StartBlackTime();
	end

	--摄像机动画
	--if self.tran ~= nil then
	--	if self.camp == 1 then
	--		if self.position.x <= self.friendCenter.x then
	--			SceneManager.curScene.cameraController:Focus(self.tran);
	--		end
	--	end
	--end
end

--黑屏结束处理
function M:overBlackTimeHandler()
	--给Unity设定黑屏时间
	if IsNull(self.luaViewHelper) == false then
		self.luaViewHelper:OverBlackTime()
	end
end

function M:setLayer(isBlack)
	if IsNull(self.luaViewHelper) == false then
		if isBlack == true then
			self.luaViewHelper:SetLayer(14)
		else
			self.luaViewHelper:SetLayer(9)
		end
	end
end

function M:createHpLabel(str, type)
	local sceneInfo = Battle.BattleGlobalConfig.SCENE_ID_INFO[SceneManager.curScene.sceneId]
	if self.camp == 1 and sceneInfo and sceneInfo.hero_showHpLabel ~= true then
		return
	end
	if self.camp == -1 and sceneInfo and sceneInfo.enemy_showHpLabel ~= true then
		return
	end
	if sceneInfo and IsNull(self.luaViewHelper) == false and self.luaViewHelper.m_ui ~= nil then
		local hpLabelPos = 0;
		if self.model.playerId == 9001 then
			hpLabelPos = 1;
		end
		self.luaViewHelper.m_ui:CreateHpLabel(str, type, hpLabelPos)
	end
end

function M:createHpNumberLabel(sign, number, type)
	local sceneInfo = Battle.BattleGlobalConfig.SCENE_ID_INFO[SceneManager.curScene.sceneId]
	if self.camp == 1 and sceneInfo and sceneInfo.hero_showHpLabel ~= true then
		return
	end
	if self.camp == -1 and sceneInfo and sceneInfo.enemy_showHpLabel ~= true then
		return
	end

	if type == nil then
		--Logger.logError(type, "createHpNumberLabel type is nil" )
	end

	number = Mathf.Floor(tonumber(number))
	local unit = ""
	local hpLabelConfig = self:getHpLabelConfig()
	if hpLabelConfig then
		for i, cfg in ipairs(hpLabelConfig) do
			if (number > cfg[1] and (cfg[2] == -1 or number <= cfg[2])) then
				number = Mathf.Floor(number / cfg[3])
				unit = cfg[4]
				break
			end
		end
	end
	self:createHpLabel(sign .. tostring(number) .. unit, type)
	--self.luaViewHelper.m_ui:CreateHpLabel("112233891ABkm", type or 0)
	--Logger.log(Json.encode({real_number, sign .. tostring(number) .. unit}), "hp label --------------------")
end

function M:getHpLabelConfig()
	if M.hpLabelConfigInit then	
		return M.HPLabelConfig
	end
	
	if not M.HPLabelConfig then
		M.hpLabelConfigInit = true	-- 初始化结果
		local initHpLabelConfig = function()
			local value = ConfigManager:getCommonValueById(687)
			if value then
				local CSConfig = CS.Config and CS.Config.Instance
				local openHpNumUnit = CSConfig.GlobalConfig and CSConfig.GlobalConfig.openHpNumUnit
				if openHpNumUnit == true then
					value = table.copy(value)
					for i, cfg in ipairs(value) do
						cfg[1] = tonumber(cfg[1])
						cfg[2] = tonumber(cfg[2])
						cfg[3] = tonumber(cfg[3])
					end
					M.HPLabelConfig = value
				end
			end
		end
		pcall(initHpLabelConfig)
		--initHpLabelConfig()
	end
	return M.HPLabelConfig
end
-- 移除延迟展示的buf特效
function M:MV_PlayerModelStopTimeTask()
	for i = 0, self.timeTaskList.Count -1 do
		---@type TimeTask_View
		local timeTask = self.timeTaskList:get(i)
		if timeTask then
			timeTask:timeTaskFinish()
		end
	end
	self.timeTaskList:clear()
end




---@param effectData BattlePlayerView_PetContestEffect
function M:playPetContestEffect( effectData, ownerPlayer, effectPlayer, effectParent )
	effectData["isPutUpInParent"] = true
	--effectData["autodestoryTime"] = effectData["autoDestroy"]
	effectData["directionType"] = "parent"
	effectData["scaleType"] = "parent"
	effectData["effectType"] = "nearFight"
	effectData["positionType"] = "parentOffset"
	effectData["isSkill"] = false
	effectData["parent"] = effectParent or "effectpoint0"
	effectData["eventName"] = "PlayEffect"
	effectData["effect_bundle"] = "commoneffect"
	effectData["mirrorPrefab"] = false
	effectData["triggerTime"] = 0
	local prefabTrans = {}
	prefabTrans["useUserSet"] = true
	prefabTrans["position"] =
	{
		[1] = 0,
		[2] = 0,
		[3] = 0,
	}
	prefabTrans["rotation"] = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
	}
	prefabTrans["scale"] = {
		[1] = 1,
		[2] = 1,
		[3] = 1,
	}
	effectData["prefabTrans"] = prefabTrans
	self:playEffect( effectData ,ownerPlayer, effectPlayer );
end


return M;