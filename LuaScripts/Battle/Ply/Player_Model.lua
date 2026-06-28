--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-04-28 15:50:58
]]

---@class PlayerModel : ModelBase @玩家数据层
---@field data PlayerData
---@field heroData Battle_CreatePlayerData
---@field master PlayerModel
---@field position FixVector3
---@field plySkill PlayerSkill_Model
---@field plyData ConfigHeroDetail
---@field trait PlayerTrait
---@field evtMgr AnimEvtManager_Model
---@field beforePos FixVector3
---@field keepMgrAfterDead string  @有某些技能（死亡后要做某事【明教死亡后，造成一次爆炸伤害】）
---@field assistsKiller table<number, number>  @助攻列表，记录
---@field profressionMgr PlayerProfressionManager
---@field talismanMgr TalismanManager
---@field skyStar SkillSkyStarManager
---@field resonance SkillResonanceManager
local M = class("PlayerModel",Battle.ModelBase)

--初始化
--玩家对象 player
--玩家阵营 camp
--玩家外部传入数据 playerData
-- ========================================== 初始化 ==================================
---@param data Battle_CreatePlayerData
function M:init( data )
	--初始化创建数据
	self:initCreateData( data );
	--初始化本地数据
	self:initLocalAttribute();
	--初始化管理器
	self:initManagers();
	--Logger.logError("<[Player_Model]> 玩家数据层创建完成 ")
	--玩家的数据层创建完成,通知 PlayerManager_View 去创建 Player_View
	self.plyMgr:dispatchEvent_Local(Battle.EventType.MV_PlayerModelCreateFinish, self)
	--我和视图 绑定完成
	self:bindViewFinish();
	--延迟1秒执行预制体创建完成
	--模拟创建完成
	TimeTools:delayTime(GlobalTools.base1,function()
		self:BossOperate()
	end)
end

--初始化创建数据
---@param data Battle_CreatePlayerData
function M:initCreateData( data )
	self.heroData = data
	--玩家管理器
	self.plyMgr = data.plyMgr
	--英雄id
	self.playerId = data.playerId
	--当前的英雄数据
	self.plyData = data.plyData
	--玩家的阵营
	self.camp = data.camp;
	--玩家的起始位置
	self.spawnPos = data.pos;
	--外部传入ai
	self.aiEngine = data.ai;
	--初始化index 
	self.index = 0;
	--宠物AI
	self.summonAiType = data.summonAiType;
	--宠物类型
	self.summonType = data.summonType;
	--玩家类型
	self.playerType = data.playerType
	--是否是故事人物
	self.isStoryPlayer = data.isStoryPlayer
	--人物移动方式
	self.moveType = data.moveType
	--玩家品级
	self.evo = data.evo or 1;
	--宠物战斗数据增加气势比拼结果
	self.power_win = data.power_win or 0;
	--宠物心情
	self.mood = data.mood or 0;
	--等级
	self.level = 1;
	--英雄在彩色5星之后，在图鉴中的升级属性增加
	self.book = data.book;
	--等级
	if data.clv and data.clv > 0 then
		self.level = data.clv
	elseif data.lv and data.lv > 0 then
		self.level = data.lv
	end
	
	self.fate_level = data.fate_level
	self.plus_level = data.plus_level

	self.resonance_lv = nil
	if data.resonance_lv ~= nil then
		local resonanceConfig = ConfigManager:getBattleCommonValueById(910)
		for l, v in pairs(resonanceConfig) do
			if v <= data.resonance_lv then
				self.resonance_lv = l
			end
		end
	end

	-- 是否有复活状态
	self.canRelive = false		-- 部分角色有复活状态，如果有英雄可以复活别人，可以将可选择目标设置为canRelive标记
	
	--玩家的重量, 后面通过数据重新赋值
	self.weight = GlobalTools.base100;
	----预制体
	self.prefabName = data.custom_prefab
	self.skill_effect = self.prefabName;
	if self.prefabName == nil then
		local hero_skin_cfg = Battle.BattleConfigManager:getHeroCurSkinCfgByData_Battle(self.heroData, self.plyData)
		if hero_skin_cfg then
			self.prefabName = hero_skin_cfg.prefab or self.plyData.prefab
			self.skill_effect = hero_skin_cfg.skill_effect or self.prefabName;
		else
			self.prefabName = self.plyData.prefab
			self.skill_effect = self.prefabName
		end
	end
	--名字路径
	local name_path = string.split(self.prefabName,"/");
	--预制体的根节点
	self.prefabRoot = name_path[1];
	--玩家类型
	self.plyType = name_path[2]
	
	local effect_name_path = string.split(self.skill_effect,"/");
	--特效预制体的根节点
	self.effect_prefabRoot = effect_name_path[1];
	--特效玩家类型
	self.effect_plyType = effect_name_path[2]
	
	self.defaultSkin_config = Battle.BattleConfigManager:getHeroDefaultSkinCfgByHeroCfg_Battle(self.plyData);
	local default_name_path = string.split(self.defaultSkin_config.prefab,"/");
	--默认皮肤 预制体根节点
	self.default_prefabRoot = default_name_path[1];
	--默认皮肤 玩家类型
	self.default_plyType = default_name_path[2]

	local default_effect_name_path = string.split(self.defaultSkin_config.skill_effect,"/");
	--特效预制体的根节点
	self.default_effect_prefabRoot = default_effect_name_path[1];
	--特效玩家类型
	self.default_effect_plyType = default_effect_name_path[2]

	
	--是否可以显示大招黑屏效果
	self.canBlackScreen = true
	self.player_gameover = false;

	--realDead 死亡后，是否要保留Mgr
	self.keepMgrAfterDead = nil
	
	self.base_scale = GlobalTools.base1
	--Logger.logError(debug.traceback(), "<[Player]> 创建玩家 ~~~~~~~~ "..self.plyType )
end
--初始化本地数据
function M:initLocalAttribute()
	--受伤暂停时间
	self.injurePauseTime = 0
	--是否在技能状态
	self.isInSkillState = false
	--黑屏时间
	self.isInBlackTime = false;
	--时间数据
	self.dtData = {}
	--攻击时候UI发送数据
	self.hitUI = {};
	--攻击时候特效发送数据
	self.hitEffect = {};
	
	if SceneManager.curScene.story ~= nil then
		if SceneManager.curScene.story:hasStory() then
			self.plyInBattle = false;
		else
			self.plyInBattle = true;
		end
	else
		self.plyInBattle = true;
	end

	--在挂机场景下每5秒检测一次人物是否被释放
	self.hangUpCheckTime = 5;
	self.hangUpCurCheckTime = 0;

	--自动索敌时间
	self.autoLockEnemyTime = GlobalTools.base12;
	self.curAutoLockEnemyTime = 0;
	--玩家移动路径
	self.player_path = Battle.List.new()
	--移动索引
	self.player_move_index = 0;
	--当前打我的人
	self.killer_list = Battle.List.new();
	--敌人是我的列表
	self.enemyIsMe_list = Battle.List.new();
	--帮助玩家免死的列表
	self.avoidDeath = {}
	--当前技能敌人列表
	self.curSkillEnemyList = Battle.List.new()
	--锁定我的列表
	self.lockMeList = Battle.List.new()
	--帮助玩家挡子弹的列表
	self.resistBullet = Battle.List.new();
	
	self.injureMoveData = {}
	--嘲讽列表
	self.tauntList = {}
	--召唤物
	self.summonList = Battle.ListMap.new()
	--0 未出生状态 1 活着的状态 -1 死亡状态 -2真正死亡，切换了死亡状态 -3 销毁  -4 假死
	--准备阶段
	self.plyState = 0
	--初始格子
	self.grid_last = nil;
	--之前的位置
	self.beforePos = FixVector3.New(0,0,0)
	--我的杀人数量
	self.killNum = 0
	--损失的总血量
	self.totalLostHp = 0
	self.totalLostHp_float = 0
	--总伤害
	self.totalDamage = 0
	--玩家真正死亡的时间
	self.playerRealDeadTime = 2
	--怒气回复时间
	self.anger_restore_time = 0
	self.apieceIndex = 0

	self.skill3ClearAnger = true
	--助攻列表
	self.assistsKiller = {}
	--强制技能配置
	self:set_forceSkillConfig(nil);
end
--初始化所有人物的管理器
function M:initManagers()
	--玩家数据
	self.data = require("Battle.Ply.PlayerData").new()
	
	--玩家品级
	self.data:set_evo(self.evo);
	self.data:set_level(self.level);
	
	--玩家技能数据
	self.plySkill = require("Battle.Ply.PlayerSkill_Model").new()
	
	--事件帧管理系统 -- 数据层
	self.evtMgr = require("Battle.SM.AnimEvt.AnimEvtManager_Model").new()
	
	--玩家动画系统
	self.animator = require("Battle.SM.Anim.PlayerAnimator_Model").new()
	
	--玩家buf管理器
	self.bufMgr = require("Battle.Buf.BufManager_Model").new()
	
	--子弹管理器
	self.bulletMgr = require("Battle.Blt.BulletManager_Model").new()
	
	--处理技能效果改变
	self.skillImprove = require("Battle.Ply.PlayerSkillImprove").new()
	
	--更具职业增加属性
	if self.book ~= nil then
		self.profressionMgr = require("Battle.Ply.Profression.PlayerProfressionManager").new()
	end
	--符篆套装管理器
	self.talismanMgr = require("Battle.Ply.Talisman.TalismanManager").new()
	--这个好像没有用了
	--技能帧管理器
	--self.skillFrameMgr = require("Battle.Ply.SkillFrameManager").new()
	--self.skillFrameMgr:init(self)
	
	--连线管理器
	self.lineMgr = require("Battle.Line.LineManager_Model").new()
	
	--召唤物管理器
	self.summonMgr = require("Battle.Summon.SummonManager_Model").new()
	
	--移动管理器
	self.moveMgr = require("Battle.Ply.Fuc.MoveFrameManager_Model").new()
	
	--曲线管理器
	self.curveMgr = require("Battle.Ply.CurveManager_Model").new()
	
	--范围检测
	self.targetCheck = require("Battle.Ply.TargetCheck_Model").new()
	
	--角色的附属物品管理器
	self.partMgr = require("Battle.Ply.PlayerPartManager_Model").new()

	--秘籍管理器
	self.mysticMgr = require("Battle.Ply.MysticManager_Model").new()
	
	--神器
	--if playerData.sig ~= nil then
	--	self:traitInit(playerData.sig.lv)
	--end
	
	--ai系统是外部传入的
	if self.aiEngine == nil then
		self.aiEngine = require("Battle.SM.Ai.AIEngine").new()
		Logger.logError("ai系统是 nil，创建玩家需要传入 ai系统")
	end
	
	if self.fate_level ~= nil then
		--天命化星管理器
		self.skyStar = require("Battle.Ply.SkillSkyStar.SkillSkyStarManager").new()
	end

	if self.resonance_lv ~= nil then
		--共鸣
		self.resonance = require("Battle.Ply.SkillResonance.SkillResonanceManager").new()
	end
	
	--神器管理器
	--self.ArtifactMgr = require("Battle.Artifact.ArtifactManager").new()
	
end
--视图和数据绑定完成
function M:bindViewFinish()
	--初始化所有管理器
	self.data:init(self)
	self.skillImprove:init( self )
	self.plySkill:init( self, self.plyData.skill, self.heroData.skill )
	--美术文件用 当前皮肤的 特效玩家名称
	--策划和程序用 原皮肤的 特效玩家名称
	self.evtMgr:init(self, self.effect_plyType, self.default_effect_plyType)
	self.animator:init(self)
	self.bufMgr:init(self)
	self.bulletMgr:init(self)
	self.lineMgr:init(self)
	self.summonMgr:init(self)
	self.moveMgr:init(self)
	self.curveMgr:init(self)
	self.targetCheck:init(self)
	self.partMgr:init(self)
	self.mysticMgr:init(self)
	self.aiEngine:init(self)
	
	if self.skyStar ~= nil then
		self.skyStar:init(self, self.fate_level)
	end
	if self.resonance ~= nil then
		self.resonance:init(self, self.resonance_lv)
	end
	if self.profressionMgr ~= nil then
		self.profressionMgr:init(self, self.plyData.role_type, self.book)
	end

	if self.talismanMgr ~= nil then
		self.talismanMgr:init(self)
	end
	--self.ArtifactMgr:init(self)

	--玩家的敌人list
	self:create_player_enemyList()
	--玩家主人
	self:set_master( self.heroData.master );
	--玩家索引
	self:setIndex( self.heroData.index );
	--是否是boss
	self:setBoss(false)
	--设定位置
	--定点数坐标
	self:setPos( self.spawnPos, true )
	self.rotation = FixQuaternion.New(0,0,0,0)
	
	if SceneManager.curScene.sceneId == SceneManager.SceneID.MiGongScene or SceneManager.curScene.sceneId == SceneManager.SceneID.GuJianQiTanScene then
		self:setForward( FixVector3.zero(), true )
	elseif SceneManager.curScene.sceneId == SceneManager.SceneID.WuXingZhenScene then
		self:setForward( FixVector3.right() * -GlobalTools.base1, true )
	elseif SceneManager.curScene.sceneId == SceneManager.SceneID.LegendScene then
		if SceneManager.curScene.legend_stage_cfg.type == 1 then
			local scene_center = SelectTargetTool:findFixPoint(self, "sceneCenter")
			local face_right = true
			if self.camp == 1 then
				face_right = scene_center.x <= self:get_position().x
			else
				face_right = scene_center.x >= self:get_position().x
			end
			if face_right then
				self:setForward( FixVector3.right(), true )
			else
				self:setForward( FixVector3.right() * -GlobalTools.base1, true )
			end
		else
			local right = FixVector3.right();
			local forward = right * GlobalTools:ToFix( self.camp )
			self:setForward( forward, true )
		end
	else
		local right = FixVector3.right();
		local forward = right * GlobalTools:ToFix( self.camp )
		self:setForward( forward, true )
	end
	
	
	if self.camp == -1 then
		if SceneManager.curScene.stageBossData ~= nil and self.index == SceneManager.curScene.stageBossData.index - 1 then
			self.isStageBoss = true
			self:setScale(SceneManager.curScene.stageBossData.scale)
			if SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.DRAGONSWORD then
				self.isBoss = true;
			end
		else
			self:setScale(self.base_scale)
		end
	else
		self.isStageBoss = false
		self:setScale(self.base_scale)
	end
	
	--公会战boss缩放特殊处理，因为他不算boss且camp可能等于1
	if self.plyType == "B_TaiY2" then
		local boss_scale = ConfigManager:getBattleCommonValueById(908, GlobalTools.base0_6, true)
		self:setScale(boss_scale)
	end
	-- 宠物斗技走自己的缩放
	if SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.PET_DOUJI then
		local pet_detailCfg = ConfigManager:getCfgByName("pet_detail")
		local cfg = pet_detailCfg[self.playerId] or {}
		if cfg and cfg.battle_scale then
			self:setScale(GlobalTools:CommonToFix(math.max(cfg.battle_scale,1)))
		end
	end

	self:addEventListener_Local(Battle.EventType.VM_PlayerViewClickDown, {self,self.VM_PlayerViewClickDown})
	self:addEventListener_Local(Battle.EventType.VM_PlayerViewSetIndex, {self,self.VM_PlayerViewSetIndex})
end


function M:setBoss( boss )
	self.isBoss = boss;
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSetBoss, self.isBoss)
end



function M:refreshSkill( skillData )
	self.heroData.skill = skillData
	self.plySkill:init( self, self.plyData.skill, self.heroData.skill, true)
	self.evtMgr:init(self, self.effect_plyType, self.default_effect_plyType)
end

function M:refreshTalisman()
	if self.talismanMgr ~= nil then
		self.talismanMgr:init(self)
	end
end

--提交设定index
function M:VM_PlayerViewSetIndex(eventName, data) 
	self.index = data.index;
	--重新设置出生点位置
	self.spawnPos = SceneManager.curScene:findSpawnPosition(self.camp, self.index)
	self:setPos( self.spawnPos );
end

--视图层点击快捷键
function M:VM_PlayerViewClickDown(eventName, data)
	if data.key == "w" then
		if self.camp == 1 and self:get_master() == nil then
			--切换到大招
			self:useSkill("skill3", true)
		end
	elseif data.key == "a" then
		if self.camp == 1 and (self.aiEngine.curConfig == nil or self.aiEngine.curConfig.anim_name ~= "skill1") then
			--切换到大招
			self:useSkill("skill1", true)
		end
	elseif data.key == "d" then
		if self.camp == 1 and (self.aiEngine.curConfig == nil or self.aiEngine.curConfig.anim_name ~= "skill2") then
			--切换到大招
			self:useSkill("skill2", true)
		end
	elseif data.key == "o" then
		if self.camp == 1 and (self.aiEngine.curConfig == nil or self.aiEngine.curConfig.anim_name ~= "skill0") then
			--切换到大招
			self:useSkill("skill0", true)
		end
	end
end
-- ========================================== 初始化 ==================================

-- ========================================== 对外访问属性 ==================================

function M:set_forceSkillConfig( config )
	self.forceSkillConfig = config;
end

--curSkillConfig 当前的技能配置
---@param config SkillDataConfig
function M:set_curSkillConfig( config )
	self.curSkillConfig = config;
end

--返回技能配置
function M:get_curSkillConfig()
	return self.curSkillConfig;
end

function M:get_summonType()
	return self.summonType
end

--camp
function M:get_camp()
	return self.camp;
end

function M:get_fate_level()
	return self.fate_level;
end

--prefabRoot
function M:get_prefabRoot()
	return self.prefabRoot;
end

--返回特效预制体root地址
function M:get_effect_prefabRoot()
	return self.effect_prefabRoot;
end

---@return FixVector3 position 位置
function M:get_position()
	return self.position;
end

--强制设定位置
function M:get_forceSetPosition()
	return self.forceSetPosition;
end

--获取预制体名字 
function M:get_prefabName()
	return self.prefabName;
end
--人物数据
function M:get_data()
	return self.data;
end

--人物索引
function M:get_index()
	return self.index
end

--关卡boss
function M:get_isStageBoss()
	return self.isStageBoss
end

--设定index
function M:setIndex( index )
	self.index = index;
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSetIndex)
end

--返回英雄数据
function M:get_heroData()
	return self.heroData;
end
--玩家名字，玩家类型
function M:get_plyType()
	return self.plyType;
end
--玩家名字，玩家类型
function M:get_default_plyType()
	return self.default_plyType;
end

--设定缩放值
function M:get_scale()
	return self.scale;
end

function M:get_plyData()
	return self.plyData;
end

function M:get_plySkill()
	return self.plySkill
end

--获取主人
function M:get_master()
	return self.master;
end

-- 是否是侠客
function M:isXiaKe()
	return self.master == nil	-- 没有主人
end

function M:set_master( master )
	self.master = master;
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSetMaster)
end

--加入嘲讽列表
function M:add_tauntList( player )
	table.insert(self.tauntList, player)
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSyncTauntList, {action = "add",enemy = player});
end

--删除嘲讽列表
function M:remove_tauntList( player, removeAll)
	table.removebyvalue(self.tauntList, player, removeAll)
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSyncTauntList, {action = "remove",enemy = player,removeAll = removeAll });
end


function M:create_player_enemyList()
	self.player_enemyList = Battle.List.new()
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSyncEnemyList, {action = "create"});
end


function M:add_player_enemyList( enemy )
	if self.player_enemyList ~= nil then
		self.player_enemyList:add( enemy )
		self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSyncEnemyList, {action = "add", enemy = enemy});
	end
end

function M:remove_player_enemyList( enemy )
	if self.player_enemyList ~= nil then
		self.player_enemyList:remove( enemy )
		self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSyncEnemyList, {action = "remove", enemy = enemy});
	end
end

function M:clear_player_enemyList()
	if self.player_enemyList ~= nil then
		self.player_enemyList:clear()
		self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSyncEnemyList, {action = "clear"});
	end
end

--设定实例id 
function M:set_playerInstanceId( instanceId )
	self.playerInstanceId = instanceId;
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSyncInstanceId);
end

--获取实例id
function M:get_playerInstanceId()
	return self.playerInstanceId
end

-- hit的额外buf 
function M:hitExBuf( bufId )
	self.ex_hit_bufId = bufId;
end

--获取自己的Player
---@return PlayerModel
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

--设定旋转模式
function M:setRotationMode( mode )
	if mode == 1 then
		self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSetRotationMode,{rotationOnlyX = true})
	else
		self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSetRotationMode,{rotationOnlyX = false})
	end
end

--设定基础缩放值
function M:setBaseScale( scale )
	self.base_scale = scale;
	self:setScale(self.base_scale)
end

--设定缩放值
function M:setScale( scale )
	self.scale = scale;
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSetScale)
end

--设定位置
function M:setPos( pos, isForce )
	if self.position == nil then
		self.position = FixVector3.New(0,0,0);
	end
	self.position.x = pos.x;
	self.position.y = pos.y;
	self.position.z = pos.z;
	self.forceSetPosition = isForce;
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelPositionChange);
end

--设定方向
function M:setForward( dir, isForce )
	if self.forward == nil then
		self.forward = FixVector3.New(0,0,0);
	end
	dir:SetNormalize()
	self.forward.x = dir.x;
	self.forward.y = dir.y;
	self.forward.z = dir.z;
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelDirChange);
end

---@return FixVector3 获取向前的方向
function M:getForward()
	return self.forward
end

---@return FixVector3 获取向右的方向
function M:getRight()
	return FixVector3.right()
end

---@return FixVector3 获取向上的方向
function M:getUp()
	return FixVector3.up()
end
-- ========================================== 对外访问属性 ==================================


-- ========================================== 更新 ==================================
--更新
function M:update(time)
	if SceneManager.curScene.collectData then
		SceneManager.curScene.collectData:markPlayerFrame(self)
	end
	if self.injurePauseTime > 0 then
		self.injurePauseTime = self.injurePauseTime - time
		if self.injurePauseTime <= 0 then
			self.injurePauseTime = 0
		end
	end

	self:caculaPlayerRealDeadTime(time);
	--self:checkAroundPlayer(time);
	--self:updateAutoLockEnemy(time)
	if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
		if self.hangUpCurCheckTime <= 0 then
			self:checkRef();
			self.hangUpCurCheckTime = self.hangUpCheckTime;
		else
			self.hangUpCurCheckTime = self.hangUpCurCheckTime - time;
		end
	end

	--Ai引擎
	if SceneManager.curScene.SceneID ~= SceneManager.SceneID.TianJiLouScene then
		if self.aiEngine ~= nil then
			self.aiEngine:update(time)
		end
	end

	--技能帧
	if self.skillFrameMgr ~= nil then
		self.skillFrameMgr:update(time)
	end

	--职业属性管理
	if self.profressionMgr ~= nil then
		self.profressionMgr:update(time)
	end
	
	--符篆套装管理器
	if self.talismanMgr ~= nil then
		self.talismanMgr:update(time)
	end
	
	--天命化星
	if self.skyStar ~= nil then
		self.skyStar:update(time)
	end

	--共鸣
	if self.resonance ~= nil then
		self.resonance:update(time)
	end
	--召唤物管理器
	if self.summonMgr ~= nil then
		self.summonMgr:update(time)
	end

	--移动管理器
	if self.moveMgr ~= nil then
		self.moveMgr:update(time)
	end

	--曲线管理器
	if self.curveMgr ~= nil then
		self.curveMgr:update(time)
	end

	--玩家技能管理器
	if self.plySkill ~= nil then
		self.plySkill:update(time)
	end

	--子弹管理器
	if self.bulletMgr ~= nil then
		self.bulletMgr:update(time)
	end

	--黑屏期间buff不更新
	if self.plyMgr.blackTimeManager.curBlackTime > 0 then
		--buf管理器
		if self.bufMgr ~= nil then
			self.bufMgr:update(0)
		end
	else
		--buf管理器
		if self.bufMgr ~= nil then
			self.bufMgr:update(time)
		end
	end

	--动画管理器
	if self.animator ~= nil then
		self.animator:update(time)
	end

	--连线管理器
	if self.lineMgr ~= nil then
		self.lineMgr:update(time)
	end

	if self.targetCheck ~= nil then
		self.targetCheck:update(time)
	end

	if self.partMgr ~= nil then
		self.partMgr:update(time)
	end

	if self.trait ~= nil then
		self.trait:update(time)
	end

	--每秒恢复多少怒气
	if self.data:get_restore_anger() > 0 then
		self.anger_restore_time = self.anger_restore_time + time
		if self.anger_restore_time > GlobalTools.base1 then
			self.data:addAnger( self.data:get_restore_anger() )
			self.anger_restore_time = self.anger_restore_time - GlobalTools.base1
		end
	end

	--如果血量小于0，并且没有死亡的buff，人物执行死亡
	if self.data:get_curHp() <= 0 and self.plyState == 1 then
		local buffs = self.bufMgr:findBufByType("NoDeath")
		if table.nums(buffs) <= 0 then
			self:dead(nil, nil);
		end
	end


	if SceneManager.curScene.sceneId == SceneManager.SceneID.FightScene then
		if self.freezePositionY == true then
			self.position.y = self.positionY
		end
	end

	--打印
	if self:isLive() and SceneManager.curScene.startBattle then
		if GameVersionConfig.OPEN_BATTLE_LOG == true then
			--加入战斗log
			if SceneManager.curScene ~= nil and SceneManager.curScene.battleLog ~= nil then
				local m_param = "mode "..self.animator.mode .. " anger "..self.data:get_curAnger();
				SceneManager.curScene.battleLog:logBattleInfo(SceneManager.curScene:get_runframe(), self, m_param)
			end
		end
	end

	--通知视图层也开始更新
	self.dtData.dt = time;
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelUpdate, self.dtData)

	if self:isLive() == true then
		for k,v in pairs(self.assistsKiller) do
			self.assistsKiller[k] = v + time
			if self.assistsKiller[k] > GlobalTools.base5 then
				self.assistsKiller[k] = nil
			end
		end
	end
end

--比Update延后一帧
function M:lateUpdate(dt)

end

--总是更新，不受状态限制
--function M:updateAlways(dt)
	--if SceneManager:getCurSceneModel():get_sceneState() == SceneManager.SceneState.SceneReady or
	--		SceneManager:getCurSceneModel():get_sceneState() == SceneManager.SceneState.SceneInit or
	--		SceneManager:getCurSceneModel():get_sceneState() == SceneManager.SceneState.SceneStop then
	--	--动画管理器
	--	if self.animator ~= nil then
	--		self.animator:update(dt)
	--	end
	--end
--end
-- ========================================== 更新 ==================================

--通知UI 刷新卡牌
function M:refreshCard( show )
	local data = {}
	data.show = show;
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSkill3RefreshCard, data);
end


--通知视图层显示 Label
function M:showLabel( num, sign, type )
	local showData = {}
	showData.sign = sign;
	showData.num = num
	showData.type = type;
	showData.isBoss = self.isBoss
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelShowLabel,showData);
end

-- Boss设置
function M:BossOperate( )
	--bossAI状态机单独设置
	if SceneManager.curScene and SceneManager.curScene.sceneId == SceneManager.SceneID.UnionBossScene then
		self.aiEngine.enableAI = true
		self.aiEngine:changeState("in")
	end
end


--加入锁定我的人物list
function M:addEnemyIsMeList( player )
	if self.enemyIsMe_list:contains(player) == false then
		self.enemyIsMe_list:add( player )
	end
end

--删除敌人是我的list
function M:removeEnemyIsMeList( player )
	if self.enemyIsMe_list:contains(player) then
		self.enemyIsMe_list:remove( player )
	end
end

--所有锁定我的敌人丢失锁定
function M:loseEnemyByEnemyIsMeList()
	for i = 1, self.enemyIsMe_list.Count do
		local player = self.enemyIsMe_list:get(i-1)
		if player ~= nil then
			player:lockEnemy(nil);
		end
	end
end

--重新设置玩家数据
function M:resetAllData()
	self.plySkill.cur_skill_update_time = 0;
	--重新设置出生点位置
	if SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.WORLD_BOSS and self.isBoss then
		self.spawnPos = SceneManager.curScene.bossPoslist:get(1)
	elseif SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE_BOSS and self.isBoss then
		self.spawnPos = SceneManager.curScene.bossPoslist:get(1)
	elseif SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.PET_DOUJI then
		self.spawnPos = SceneManager.curScene:findPetDouJiSpawnPosition(self.camp, self.index)
	else
		self.spawnPos = SceneManager.curScene:findSpawnPosition(self.camp, self.index)
	end
	--所有人切换到idle
	self:setPos(self.spawnPos);
	--重新设置状态
	--print("resetAllData" .. self:get_playerInstanceId())
	if self.aiEngine ~= nil then
		self.aiEngine:changeState("idle")
	end
	--Logger.log(self.plyType.." 重新设置出生位置 ".."("..self.spawnPos.x..","..self.spawnPos.y..","..self.spawnPos.z..")")
end

--大招开始
function M:skill3Start_Model()
	if self.profressionMgr ~= nil then
		self.profressionMgr:skill3Start()
	end

	if self.talismanMgr ~= nil then
		self.talismanMgr:skill3Start()
	end
end

--大招结束
function M:skill3Over_Model()
	if self.profressionMgr ~= nil then
		self.profressionMgr:skill3Over()
	end

	if self.talismanMgr ~= nil then
		self.talismanMgr:skill3Over()
	end
end

--大招开始
function M:skill3Start()
	self.skill_start = true;
	--玩家自身 -- 设定层级
	self:setUnScale(true);
end
--大招结束
function M:skill3Over()
	--黑屏结束改成受到TimeScale影响
	self.skill_start = false;
	self:setUnScale(false);
end

function M:setUnScale(isUnScale)
	--将自己的层级设置成Focus
	-- Hero = 9,
	-- Focus = 14
	self.isUnScale = isUnScale
	if isUnScale then
		if self.animator ~= nil then
			self.animator:setAnimUnscale(2)
		end
		
	else
		if self.animator ~= nil then
			self.animator:setAnimUnscale(0)
		end
	end
end

--神器初始化 
function M:traitInit(level)
	if level ~= nil and level >= 0 then
		local traitId = self.plyData.equip_heroes_id
		local equip_heroes = ConfigManager:getCfgByName("equip_heroes")
		local traitData = equip_heroes[traitId]
		if traitData ~= nil then
			local param = traitData.level_up[level].equip_skill
			if type(param) == "table" and #param > 0 then
				--local traitName = "Battle.Ply.Trait." .. self.plyType .. "_Trait"
				--for i = traitData.level_up[level].stage - 1, 0, -1 do
				--	if Battle.ClassPathUtil:Exists(traitName..i) then
				--		self.trait = require(traitName .. i).new()
				--		self.trait:initData(self, param)
				--	end
				--end
				for k,v in ipairs(param) do
					self.bufMgr:addBufById(tonumber(v), self)
				end
			end
		end
	end
end

--计算玩家真正死亡的时间
function M:caculaPlayerRealDeadTime(dt)
    if self.plyState == -1  then
		if self.playerRealDeadTime > 0 then
			self.playerRealDeadTime = self.playerRealDeadTime - dt
		end
		if self.lockMeList.Count <= 0 or self.playerRealDeadTime <= 0 then
			self.playerRealDeadTime = 0
			self:realDead()
		end	
	end
end

--检测我周围的玩家
--计算玩家给我的推力
--function M:checkAroundPlayer( dt )
--	local time = GlobalTools:Mul( dt, GlobalTools.base1 )
--	if self.master == nil then
--		----我的队友
--		local friends = self.plyMgr:getPlayers(self:get_camp())
--		for i = 1, friends.Count do
--			local ply = friends:get(i-1)
--			if ply.master == nil then
--				local dis_ply = GlobalTools:Distance(self:get_position(), ply:get_position())
--				if dis_ply < GlobalTools:ToFix2( self.data.check_radius ) then
--					local dir_ply = GlobalTools:Dir(self:get_position(), ply:get_position())
--					local pos = self:get_position() + dir_ply * time;
--					self:setPos( pos );
--				end
--			end
--		end
--		local enemys = self.plyMgr:getPlayers(-self:get_camp())
--		for i = 1, enemys.Count do
--			local ply = enemys:get(i-1)
--			if ply.master == nil then
--				local dis_ply = GlobalTools:Distance(self:get_position(), ply:get_position())
--				if dis_ply < GlobalTools:ToFix2( self.data.check_radius ) then
--					local dir_ply = GlobalTools:Dir(self:get_position(), ply:get_position())
--					local pos = self:get_position() + dir_ply * time;
--					self:setPos( pos );
--				end
--			end
--		end
--	end
--end


function M:ShowHpBar( show )
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelShowHpBar,{ show = show })
end


--锁定敌人
---@param enemy PlayerModel
function M:lockEnemy( enemy )
	if GameVersionConfig.Debug then
		if self.playerType == "pet" and enemy and enemy.playerType ~= self.playerType then
			Logger.logError("宠物协战 宠物锁定了非宠物目标")
		end
	end
	--之前的敌人
	local lastEnemy = self.enemy;
	if enemy ~= nil then
		if lastEnemy ~= nil then
			lastEnemy:removeEnemyIsMeList(self);
		end
		enemy:addEnemyIsMeList(self);
		--如果自己的敌人 和 目标敌人不相同
		if enemy ~= lastEnemy then
			self.curAutoLockEnemyTime = self.autoLockEnemyTime;
		end
	else
		self.curAutoLockEnemyTime = 0;
		--重新设置，敌人的killer列表
		--丢失目标设置
		if lastEnemy ~= nil then
			--删除敌人是我的列表
			lastEnemy:removeEnemyIsMeList(self);
			--删除攻击我的人的列表
			lastEnemy:removeKillerList(self)
		end
	end
	self.enemy = enemy
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSetEnemy,{enemy = enemy})
end


function M:get_enemy()
	return self.enemy;
end


--更新自动索敌逻辑
function M:updateAutoLockEnemy( dt )
	if self.curAutoLockEnemyTime > 0 then
		self.curAutoLockEnemyTime = self.curAutoLockEnemyTime - dt
		if self.curAutoLockEnemyTime <= 0 then
			--自动索敌到时间
			--直接丢失敌人，让自动索敌
			self:lockEnemy(nil);
		end
	end
end

--锁定敌人方向
function M:lockEnemyDir()
	if self:get_enemy() ~= nil then
		if self.isBoss == false then
			local dir = GlobalTools:Dir( self.enemy.position,self.position);
			self:setForward( dir );
		end
	end
end

function M:setPosition()
	self:caculateGridSix();
end

--找路径
--获取到敌人周围距离最近的空闲的格子
function M:findPath()
	if self:get_enemy() ~= nil and self:get_enemy().grid ~= nil then
		self.player_path = SceneManager.curScene.aStar.sceneData:getAroundGrid_Free_MinDis(self.enemy.grid, self);
	end
end

--治疗
---@param value string
---@param source PlayerModel
---@param value number
---@param sourceSkill SkillDataConfig
---@param notShow boolean
function M:cure(type, source, value, sourceSkill, notShow, sourceBuff)
	if self:isLive() then
		--被动临时属性改变
		if source ~= nil then 
			source.plySkill:killerDataChangeTemp(self, sourceSkill)
			self.plySkill:victimDataChangeTemp(source, sourceSkill)
		end

		--经脉临时属性改变
		if self ~= nil and self.trait ~= nil then
			self.trait:killerDataChangeTemp(self)
		end
		if self.trait ~= nil then
			self.trait:victimDataChangeTemp(self)
		end

		local cure = self.data:getCureValue(type, value, source)
		 if cure ~= nil and cure > 0 then
			 EventDispatcher:dipatchEvent("cure",{source = source, player = self, cure = cure, sourceSkill = sourceSkill})
			 local curHp = self.data:get_curHp()				 
			 self.data:set_curHp(cure + self.data:get_curHp())
			 
			 local overflow = cure - (self.data:get_curHp() - curHp)
			 if overflow > 0 then
				 EventDispatcher:dipatchEvent("cureOverflow",{source = source, player = self, overflow = overflow, sourceSkill = sourceSkill, sourceBuff = sourceBuff})
			 end
			 
			 if notShow ~= true then
				 self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelCure, {hp = cure, source = source, sourceSkill = sourceSkill})
			 end

			 if SceneManager.curScene.collectData then
				 SceneManager.curScene.collectData:causeCure(source, self, sourceSkill, cure, overflow)
			 end
				 
			 --统计治疗量
		 	if SceneManager.curScene.tongjiData then
		 		if source ~= nil then
		 			local instanceId = source:get_playerInstanceId()
		 			if source.master ~= nil then
		 				instanceId = source.master:get_playerInstanceId()
		 			end
		 			SceneManager.curScene.tongjiData:addPlayerCure(instanceId, cure, source.camp)
		 		end
		 	end
		 end
		 --清除临时属性
		 self.data:clearTempData()
		 if source ~= nil then
			 source.data:clearTempData()
		 end
	end
end



function M:useHandSkill3()
	SceneManager:getCurSceneModel():addSkill3Data(self);
end


--使用技能
--isForce 是否强制使用
function M:useSkill(skillId, isForce)
	local skill_name = skillId
	local skill = self.plySkill:getSkillByName(skill_name)
	if skill == nil and skillId == "skill3" then
		skill = self.plySkill:getSkillByName("skill3_plus")
	end
	if skill ~= nil then
		if skill.cur_skill_config.anim_name == "skill3" or skill.cur_skill_config.anim_name == "skill3_plus" then
			if isForce == true or (self.data:isMax_anger() == true and skill.cur_skill_config:canUseSkill3() == true) then
				self.aiEngine.skillConfig = skill.cur_skill_config
				self.aiEngine:changeState("skill")
			end
		else
			if isForce == true or skill.cur_skill_config:canUse() == true then
				self.aiEngine.skillConfig = skill.cur_skill_config
				self.aiEngine:changeState("attack")
			end
		end
	end
end
-------------------------------------- 位移计算相关的 ------------------------------------

function M:equalVec(vec1, vec2)
	if vec1.x == vec2.x and vec1.y == vec2.y and vec1.z == vec2.z then
		return true;
	end
	return false;
end

------------------------------------------ end ----------------------------------------------------

--只是启动动画和AI状态机
function M:startAiEngineAndAnimator( buzhengMove )
	self.buzhengMove = buzhengMove;
	self.plyState = 1;
	
	self.animator:reset();
	--状态机开始运行
	self.aiEngine:start();
	--设置玩家血量为满血
	local curHp = self.data:get_hp();
	--设置当前血量
	self.data:set_curHp(curHp)
end

--隐藏body
function M:hideBody( show )
	self.isHide = not show
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelHideBody,{show = show})
end


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~  流程控制相关 --------------------------------------------
--玩家出生
function M:spawn(dyns)
	--加载神器
	--if self.heroData ~= nil and self.heroData.artifact ~= nil then
	--	self.ArtifactMgr:add(self.heroData.artifact.id, self.heroData.artifact.lv)
	--end
    --设置玩家血量为满血
	self.data:set_curHp(self.data:get_hp())
	--记录一下玩家的Y值
	if self.position ~= nil then
		self.positionY = self.position.y;
	else
		self.positionY = GlobalTools.base0;
	end
	
    --初始化动态属性
	if dyns ~= nil then
		--ToDo 迷宫的初始数据需要修改为定点数处理
		local hp_pct = GlobalTools:Div( dyns.hp_pct, GlobalTools.base10000 );
		local cur_hp_pct = GlobalTools:Mul( self.data:get_curHp(), hp_pct );
		self.data:set_curHp( cur_hp_pct, 1 )
		local mp_pct = GlobalTools:Div( dyns.mp_pct, GlobalTools.base10000 );
		local cur_anger_pct = GlobalTools:Mul( self.data:get_maxAnger(), mp_pct );
		self.data:set_anger( cur_anger_pct )
	end
	
	self.animator:reset();
	--状态机开始运行
	self.aiEngine:start()
	
	--id 为2 是普通推关战斗
	--id 为3 是boss战斗
	--id 为7 天机楼战斗
	--id 为9 迷宫战斗
    if SceneManager.curScene.sceneId == 2  or 
        SceneManager.curScene.sceneId == 7 or 
        SceneManager.curScene.sceneId == 9 then
		--self.ArtifactMgr:gameStart()
    end
	--self:setPos( self.spawnPos );
	--玩家的状态切换到或者状态
    self.plyState = 1
    --初始化被动技能
	for i = 1, self.plySkill.skill_items.Count do
		local config =  self.plySkill.skill_items:get(i - 1).cur_skill_config
		if config ~= nil and config.feature ~= nil then
			config.feature:spawn()
		end
	end
	--经脉
	--if self.trait ~= nil then
	--	self.trait:spawn()
	--end

	if self.heroData.sig ~= nil then
		self:traitInit(self.heroData.sig.lv)
	end
	--敌人加入初始buff
	if SceneManager.curScene.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR then
		self:stageBattleInitBuff()
	end

	self.mysticMgr:spawn()

	--战斗开始
	if self.profressionMgr ~= nil then
		self.profressionMgr:gameStart()
	end

	if self.talismanMgr ~= nil then
		self.talismanMgr:gameStart()
	end
	
	--local skillImproveData = UserDataManager.skillImprove_data.m_skillImprove[self.heroData.id]
	if self.heroData.improve_id ~= nil then
		local skillImproveGroupTable = ConfigManager:getCfgByName("skill_improve_group")
		for k,v in ipairs(skillImproveGroupTable[self.heroData.improve_id].id) do
			self.skillImprove:addItem("skill", v)
		end
	end
	
	--如果是大侠试炼
	if SceneManager.curScene.m_game_mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE or
			SceneManager.curScene.m_game_mode == Battle.BattleGlobalConfig.BATTLE_MODE.FIVE_ARRAY or
			SceneManager.curScene.m_game_mode == Battle.BattleGlobalConfig.BATTLE_MODE.EVIL_SHADOW or
			SceneManager.curScene.m_game_mode == Battle.BattleGlobalConfig.BATTLE_MODE.SORT_CHIVALROUS or
			SceneManager.curScene.m_game_mode == Battle.BattleGlobalConfig.BATTLE_MODE.COMMON_BATTLE or
			SceneManager.curScene.m_game_mode == Battle.BattleGlobalConfig.BATTLE_MODE.DRAGONSWORD or
			SceneManager.curScene.m_game_mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE_BOSS or
			SceneManager.curScene.m_game_mode == Battle.BattleGlobalConfig.BATTLE_MODE.WORLD_BOSS then
		if self.camp == -1 then
			EventDispatcher:registerEvent("bossMaxnum", {self,self.bossMaxnumHandler})
		end
	end

	--加入统计数据
	if SceneManager:getCurSceneModel().tongjiData ~= nil then
		SceneManager:getCurSceneModel().tongjiData:setPlayerMaxHp(self:get_playerInstanceId(), self.data:get_hp(), self:get_camp())
	end
	
    --发送出生消息
	EventDispatcher:dipatchEvent("spawn",{ player = self})
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSpawn, {dyns = dyns})
end

function M:stageBattleInitBuff()
	if self.heroData.buffs ~= nil then
		for i = 1, #self.heroData.buffs do
			self.bufMgr:addBufById(self.heroData.buffs[i], self)
		end
	end
end

function M:bossMaxnumHandler(eventName, data)
	if data.atk_area == nil or table.indexof(data.atk_area, self:get_index() + 1) ~= false then
		--最大数量
		self.bossFuff_maxNum = data["maxnum"]
		--增加攻击力
		self.addAtk = data["addAtk"]

		if self.bossFuff_lastNum == nil then
			self.bossFuff_lastNum = 0;
		end

		--当前的 层数 减去上一次的层数
		local num = self.bossFuff_maxNum - self.bossFuff_lastNum
		if num > 0  then
			local add_atk_fix = GlobalTools:Mul(GlobalTools:ToFix(num), GlobalTools:ToFix(self.addAtk))
			self.data.atk:addToAddList(add_atk_fix)
		end
		self.bossFuff_lastNum = self.bossFuff_maxNum
	end
end

--重新开始
function M:restart()
	self.aiEngine:changeState("patrol")
end

function M:fiveElement(data)
	for k,v in pairs(data) do
		local key,type,value = self:getValue(v)

		if self.data[key] ~= nil then
			if type == 1 then
				self.data[key]:addToAddList(value)
			elseif type == 2 then
				self.data[key]:addToMulList(value)
			elseif type == 3 then
				self.data[key]:addToMAAList(value, "fiveElement")
			end
		end
	end
end

function M:getValue(data)
	local key,paramType,value = nil,nil,nil
	if type(data) == "table" then
		for k,v in ipairs(data) do
			for k1,v1 in ipairs(v) do
				if v1[1] == "heroEnum" then
					key = v1[2]
				elseif v1[1] == "dataCalType" then
					paramType = v[2]
				elseif v1[1] == "param" then
					value = v1[2]
				end
			end
		end
		local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
		key = hero_enumeration[key].user_key
	end
	return key,paramType,value
end

--受伤状态
--伤害           damage
--攻击我的人      player
--攻击附带的buf   bufid
---@param attackData Battle_AttackData
function M:injure( attackData )
	--挂机场景英雄不受伤
    if self.plyMgr.scene.sceneId == SceneManager.SceneID.HangUpScene then
		--挂机场景,只有敌人受伤,但是不会计算怒气
		if self.camp == 1 then
			attackData.noAttack = true
		end
		self:beHit(attackData, false)
	else
		--战斗场景
		self:beHit(attackData, true)
	end
end

--被攻击
--attackData:	攻击数据
--canEnergy: 	是否可以恢复能量
---@param attackData Battle_AttackData
function M:beHit(attackData, canEnergy)
	
	--玩家如果是活着的状态
	if self.plyState > -1 then
		attackData = table.shallow_copy(attackData)
		--MemLeakCheckTools.appendWeakObjMap(attackData, self.plyType )
		--攻击我的人
		self.killer = attackData["player"]
		--伤害类型
		--1 nei伤
		--2 wai伤
		local damageType = attackData["damageType"] or 3
		local isInvincible = self.data:checkInvincible(damageType)
		
		--isInvincible  玩家是否无敌
		if isInvincible == false then
			--被动临时属性改变
			self.plySkill:beforeAttack(attackData, self.killer)
			if self.killer ~= nil then
				self.killer.plySkill:killerBeforeAttack(attackData, self)
			end
			EventDispatcher:dipatchEvent("victimBeforeAttack",{killer = self.killer, victim = self, attackData = attackData})

			--攻击带的类型
			--0 正常
			--3 反弹伤害
			local type = attackData["type"]
			
			--是否有人帮忙顶替伤害
			local resistInjure = self.bufMgr:findBufByType("ResistInjure")
			for k,v in ipairs(resistInjure) do
				if v.source ~= nil and v.source:isLive() and v.source:get_playerInstanceId() ~= self.playerInstanceId and type ~= 3 then
					attackData["type"] = 3
					v.source:injure(attackData)
					return
				end
			end

			--面板攻击伤害
			local form_damage = attackData["damage"]

			--计算前伤害百分比
			local damageFront = attackData["damageFront"]
			if damageFront == nil then
				damageFront = GlobalTools.base1
			end

			--计算后伤害百分比
			local damageLast = attackData["damageLast"]
			if damageLast == nil then
				damageLast = GlobalTools.base1
			end

			local damageExtra = attackData["damageExtra"]
			if damageExtra == nil then
				damageExtra = GlobalTools.base0
			end
			
			--攻击所附带的怒气百分比
			local angerAir = attackData["angerAir"]
			--是否一定暴击
			local mustCrit = attackData["mustCrit"]
			--是否一定闪避
			local mustDodge = attackData["mustDodge"]
			--是否一定闪避外功
			local mustDodgeOut = attackData["mustDodgeOut"]
			--是否一定闪避内功
			local mustDodgeIn = attackData["mustDodgeIn"]
			--是否一定命中
			local mustHit = attackData["mustHit"]
			--受伤位移数据
			local injureMove = attackData["injureMove"]
			--附带技能
			local skillConfig = attackData["skillConfig"]
			--免伤？
			local noAttack = attackData["noAttack"]
			--无法闪避buff
			local hasNoDodge = self.bufMgr:hasBufByTag("NoDodge");
			--绝对闪避buff
			local mustDodgeBuff = self.bufMgr:findBufByType("Dodge");
			for k,v in ipairs(mustDodgeBuff) do
				if v.bufWork ~= nil and v.bufWork:checkDodge() == true then
					mustDodge = true
					break
				end
			end
			--是否播放受击动画
			local hasInjureMove = false
			local hit = false
			--必中
			if mustHit == true then
				hit = true
			else
				if mustDodge == true or 
						(skillConfig ~= nil and skillConfig.atk_type == 2 and mustDodgeOut == true) or 
						(skillConfig ~= nil and skillConfig.atk_type == 1 and mustDodgeIn == true) then
					hit = false
				else
					if hasNoDodge then
						hit = true
					else
						if self.killer ~= nil and self.data:dodgeCal(skillConfig, self.killer) == false then
							hit = true
						end
					end
				end
			end
			
			--命中了才有伤害，如果闪避了没有伤害,内功型技能一定命中
			if hit then
				--被动临时属性改变
				if self.killer ~= nil then
					local killer = self.killer.master or self.killer
					killer.plySkill:killerDataChangeTemp(self, skillConfig)
				end
				self.plySkill:victimDataChangeTemp(self.killer, skillConfig)
				EventDispatcher:dipatchEvent("killerDataChangeTemp",{killer = self.killer, victim = self})

				--经脉临时属性改变
				if self.killer ~= nil and self.killer.trait ~= nil then
					self.killer.trait:killerDataChangeTemp(self)
				end
				if self.trait ~= nil then
					self.trait:victimDataChangeTemp(self.killer)
				end
				
				--遗物临时属性改变
				self.plyMgr.attacker_relicMgr:dataChangeTemp(self.killer, self)
				self.plyMgr.defender_relicMgr:dataChangeTemp(self.killer, self)
				--buff临时属性改变
				if self.killer ~= nil then
					self.killer.bufMgr:killerDataChangeTemp(self)
				end
				self.bufMgr:victimDataChangeTemp(self.killer)

				EventDispatcher:dipatchEvent("attackDataChangeTemp",{ killer = self.killer, victim = self, skill = skillConfig})
				-- 计算暴击
				local isCrit = self.data:critCal(self.killer) or mustCrit
				-- 计算伤害
				local damage = self.data:damageCal(skillConfig, self.killer, form_damage, damageFront, damageLast, damageType, damageExtra, isCrit)
				-- 攻击无效
				if noAttack then
					damage = GlobalTools.base0;
				end
				--=========================================  吸血 start =================================================
				local suck_value = 0
				if self.killer ~= nil then
					--leeching  吸血等级
					suck_value = self.killer.data:leechingCal(damage)
					--如果能吸血就吸血
					if suck_value > 0 then
						self.killer:cure("fix", self.killer, suck_value)
					end
				end
				--=========================================  吸血 end =================================================

				
				--=========================================  怒气计算 start =================================================
				if canEnergy then
					local anger = self.data:getInjureEnemgy(skillConfig, angerAir)
					local angerTable = {anger = anger}
					EventDispatcher:dipatchEvent("victimBeforeAddAnger",{ killer = self.killer, victim = self, skill = skillConfig, angerTable = angerTable})
					self.data:addAnger( angerTable.anger )
					attackData["defenderAnger"] = angerTable.anger
				end
				--=========================================  怒气计算 end =================================================
				
				if self.killer ~= nil then
					--受伤位移处理
					if injureMove ~= nil and table.nums(injureMove) > 0 then
						local canMove = true
						local buffs = self.bufMgr:findBufByType("Immunity")
						for k, v in ipairs(buffs) do
							if v.bufWork:checkHit() == true then
								canMove = false
								break
							end
						end
						--如果可以被攻击位移
						if canMove then
							self.injureMoveData["injureType"] = injureMove["injureType"]
							if self.injureMoveData["injureType"] == nil or self.injureMoveData["injureType"] == "nil" then
								self.injureMoveData["injureType"] = 1
							end
							self.injureMoveData["endType"] = injureMove["endType"]
							if self.injureMoveData["endType"] == nil or self.injureMoveData["endType"] == "nil" then
								self.injureMoveData["endType"] = 1
							end
							self.injureMoveData["type"] = injureMove["type"]
							--位移距离
							self.injureMoveData["distance"] = injureMove["distance"]
							--位移时间
							self.injureMoveData["time"] = injureMove["time"]
							--位移方向
							self.injureMoveData["dir"] = injureMove["injureDir"]
							self.injureMoveData["killer"] = self.killer
							self.injureMoveData["injureAnimName"] = injureMove["injureAnimName"]
							self.injureMoveData["moveType"] = injureMove["moveType"]

							self.aiEngine:changeState("injureMove")
							hasInjureMove = true
						end
					end
				end

				--=========================================  伤害分担 start =================================================
				if self.killer ~= nil and type ~= 3 then
					local hurtShareList = self.bufMgr:findBufByFromMeType("HurtShare")
					local remainHp = 0
					local share = false
					local killer = self.killer
					for k,v in ipairs(hurtShareList) do
						if self:equal(v.source) then
							if v.bufWork ~= nil and v.player:isLive() then
								if v.player.data:checkInvincible(damageType) == false then
									local shareHp = GlobalTools:Mul(v.bufWork.shareValue, damage)
									local remainValue = GlobalTools:Mul(v.bufWork.remainValue, damage)
									local wantdata = {}
									wantdata["damage"]  = shareHp
									wantdata["suck_value"] = GlobalTools.base0;
									local data = {}
									data["type"] = 3
									data["hitEffectList"] = attackData["hitEffectList"]
									v.player:beHitDirect(killer, data, wantdata, false, false)
									remainHp = GlobalTools:Max(remainHp, remainValue)
									share = true
								else
									v.player:ShowHitUI(7, attackData);
								end
							end
							
						end
					end
					if share then
						damage = remainHp
					end

					local otherHurtShareList = self.bufMgr:findBufByType("HurtShareOther")
					local otherRemainHp = 0
					local othershare = false
					for k,v in ipairs(otherHurtShareList) do
						if self:equal(v.player) then
							if v.bufWork ~= nil then
								if v.source.data:checkInvincible(damageType) == false then
									local shareHp = GlobalTools:Mul(v.bufWork.shareValue, damage)
									local remainValue = GlobalTools:Mul(v.bufWork.remainValue, damage)
									local wantdata = {}
									wantdata["damage"]  = shareHp
									wantdata["suck_value"] = GlobalTools.base0;
									local data = {}
									data["type"] = 3
									data["hitEffectList"] = attackData["hitEffectList"]
									v.source:beHitDirect(self.killer, data, wantdata, false, false)
									otherRemainHp = GlobalTools:Max(otherRemainHp, remainValue)
									othershare = true
								else
									v.source:ShowHitUI(7, attackData);
								end
							end
						end
					end
					if othershare then
						damage = otherRemainHp
					end
				end
				--=========================================  伤害分担 end =================================================
				
				--=========================================  反伤计算 start =================================================
				--不是反弹伤害才能反弹
				if self.killer ~= nil then
					if type ~= 3 then
						if self.data.reboundDmg > 0 then
							local reboundData = {}
							--计算反弹伤害
							reboundData["damage"] = GlobalTools:Mul(damage, self.data.reboundDmg)
							reboundData["player"] = self
							reboundData["type"] = 3
							reboundData["injureBuf"] = 0
							reboundData["damageType"] = 0
							reboundData["angerAir"] = GlobalTools.base0;
							self.injureMoveData["killer"] = self.killer
							self.killer:injure(reboundData)
						end
					end
				end
				
				--=========================================  反伤计算 end =================================================
				
				--清除临时属性
				self.data:clearTempData()
				if self.killer ~= nil then
					self.killer.data:clearTempData()
				end

				-- 直接给伤害
				if self.killer ~= nil then
					local wantdata = {}
					wantdata["damage"] = damage
					wantdata["suck_value"]  = suck_value
					wantdata["hasInjureMove"]  = hasInjureMove
					self:beHitDirect(self.killer, attackData, wantdata, isCrit, type ~= 3)
				end
			else
				attackData.isDodge = true
				EventDispatcher:dipatchEvent("dodge",{ killer = self.killer, victim = self})
                self:ShowHitUI(6, attackData);
			end
        else
			attackData.isGod = true
			self:ShowHitUI(7, attackData);
		end
	end
	--被攻击者监听被击
	if self.profressionMgr ~= nil then
		self.profressionMgr:BeHitOver()
	end

	if self.talismanMgr ~= nil then
		self.talismanMgr:BeHitOver()
	end
	self:hitOverCheckEnemy()
end


--每次攻击之后
function M:hitOverCheckEnemy()
	if self:get_enemy() ~= nil and self.killer ~= nil then
		--我的敌人和攻击者不是一个人
		if self:get_enemy() ~= self.killer then
			if self.killer_list:contains(self.killer) == false then
				self:lockEnemy(nil);
				self.killer_list:add(self.killer)
			end
		end
	end
end


--删除攻击者列表
function M:removeKillerList( player )
	--if self.killer_list:contains(player) then
		self.killer_list:clear()
	--end
end


function M:checkRef()
	local killer = self.injureMoveData["killer"];
	if killer ~= nil then
		if killer:isDestroy() then
			self.injureMoveData["killer"] = nil;
		end
	end

	killer = self.killer
	if killer ~= nil then
		if killer:isDestroy() then
			self.killer = nil;
		end
	end
	local enemyIsMe_list = self.enemyIsMe_list;
	for i = enemyIsMe_list.Count, 1,-1 do
		local ply = enemyIsMe_list:get(i-1);
		if ply ~= nil and ply:isDestroy() then
			enemyIsMe_list:remove(ply);
		end
	end
	for i = self.killer_list.Count, 1,-1 do
		local ply = self.killer_list:get(i-1);
		if ply ~= nil and ply:isDestroy() then
			self.killer_list:remove(ply);
		end
	end
	
	if self.lastSelect ~= nil then
		for i = self.lastSelect.Count, 1,-1 do
			local ply = self.lastSelect:get(i-1);
			if ply ~= nil and ply:isDestroy() then
				self.lastSelect:remove(ply);
			end
		end
	end
end


--直接攻击受伤
---@param player PlayerModel
---@param attackData Battle_AttackData
---@param wantdata Battle_BeHitDirectData_WantData
function M:beHitDirect(player, attackData, wantdata, isCrit, sendEvent)
	self:playHitEffect(player, attackData, isCrit);
	local attackHandleData = { killer = player, victim = self, damage = wantdata["damage"], attackData = attackData,isCrit = isCrit}
	wantdata["damage"] = self.plySkill:afterAttack(attackHandleData)
	attackData["isCrit"] = isCrit
	if player ~= nil then
		attackHandleData.damage = wantdata["damage"]
		local killer = player:getPlayer(false)
		wantdata["damage"] = killer.plySkill:killerAfterAttack(attackHandleData)
		--杀人者攻击
		if killer.profressionMgr ~= nil then
			killer.profressionMgr:Attack(attackHandleData)
		end

		if killer.talismanMgr ~= nil then
			killer.talismanMgr:Attack(attackHandleData, wantdata)
		end
		--被攻击者监听被击
		if self.profressionMgr ~= nil then
			self.profressionMgr:BeHit(attackHandleData)
		end
		
		if self.talismanMgr ~= nil then
			self.talismanMgr:BeHit(attackHandleData)
		end
		
		if killer ~= nil then
			if killer.skyStar ~= nil then
				killer.skyStar:attackOver(self, killer, wantdata)
			end
			if killer.resonance ~= nil then
				killer.resonance:attackOver(self, killer, wantdata)
			end
			killer.mysticMgr:attackOver(self, player, wantdata, attackData)
		end
	end

	if sendEvent == nil or sendEvent == true then
		EventDispatcher:dipatchEvent("injure",{ killer = player, victim = self, wantdata = wantdata, attackData = attackData})
		if wan3tdata.avoidInure ~= nil and wantdata.avoidInure == true then
			wantdata.damage = 0
			self:ShowHitUI(7,attackData)
		end
	end


	
	-- HurtShare分摊伤害没有走injure的监听这里补一个allInjure处理分摊伤害
	EventDispatcher:dipatchEvent("allInjure",{ killer = player, victim = self, wantdata = wantdata, attackData = attackData})
	
	local damage = wantdata["damage"]
	if damage > 0 then
		self:showData(player, attackData, damage, isCrit)
	end

	--普通攻击结束
	self.plyMgr.attacker_relicMgr:attackOver(self, player, wantdata["damage"])
	self.plyMgr.defender_relicMgr:attackOver(self, player, wantdata["damage"])
	

	--统计伤害
	if SceneManager.curScene.tongjiData ~= nil then
		if player ~= nil then
			--local instanceId = player:get_playerInstanceId()
			if player.master ~= nil then
				SceneManager.curScene.tongjiData:addPlayerAtk(player.master, damage, player.camp)
			else
				SceneManager.curScene.tongjiData:addPlayerAtk(player, damage, player.camp)
			end
		end
		SceneManager.curScene.tongjiData:addPlayerDef(self, damage, self.camp)
	end

	--这次攻击会造成死亡
	if self.data:get_curHp() - damage <= 0 then
		--致命伤害
		if self.profressionMgr ~= nil then
			damage = self.profressionMgr:attackBeforeDead(damage)
		end
		
		--死亡前执行
		damage = self.plyMgr.attacker_relicMgr:beforeDead(self, player, damage)
		damage = self.plyMgr.defender_relicMgr:beforeDead(self, player, damage)
	end

	--计算额外血量 护盾什么的 
	local hp_damage = damage
	
	if attackData["ignoreGuard"] ~= true then
		local shieldBuf = self.bufMgr:findBufByType("Shield")
		for k,v in ipairs(shieldBuf) do
			if v.bufWork.value > 0 then
				--护盾击破
				--BreakShield
				if v.bufWork.value > hp_damage then
					v.bufWork.value = v.bufWork.value - hp_damage
					hp_damage = GlobalTools.base0
					break
				else
					hp_damage = hp_damage - v.bufWork.value
					v.bufWork.value = GlobalTools.base0
					self.bufMgr:removeBuf(v)
				end
			end
		end
		if damage > hp_damage then
			--老板说：不显示减少护盾
			--self:showLabel(damage - hp_damage,"-", 3);
		end
	end

	--防御击破
	if attackData["armorBreak"] == true then
		self.bufMgr:removeBufByType("Shield")
	end

	--计算总掉血量
	self:calculateTotalLostHp(hp_damage)
	
	--计算伤害
	if player ~= nil then
		player:calculateDamage(hp_damage)
		if player:get_playerInstanceId() ~= nil then
			self.assistsKiller[player:get_playerInstanceId()] = 0
		end
	end

	--设置血量
	self.data:set_curHp(self.data:get_curHp() - hp_damage)
	self:showHitLabel(hp_damage, isCrit)


	if SceneManager.curScene.collectData then
		SceneManager.curScene.collectData:causeDamage(self, attackData, wantdata)
	end

	if self.data:get_curHp() <= 0 then
		local canDead = true
		if attackData["ignoreAvoidDeath"] ~= true or self.isBoss == true then --boss都不能被无视免死
			--检测免死(生效一次，保留1血)
			for k, v in ipairs(self.avoidDeath) do
				if v:checkSkill(self) then
					--self.data:set_curHp(GlobalTools.base1)
					canDead = false
					break;
				end
			end

			--是否能死亡
			canDead = self.plySkill:dead({killer = player, attackData = attackData}) and canDead
			--检测免死buff(不死但掉血)
			local buffs = self.bufMgr:findBufByType("NoDeath")
			if table.nums(buffs) > 0 then
				EventDispatcher:dipatchEvent("NoDeath",{ ply = self })
				for k,v in ipairs(buffs) do
					v.bufWork:use()
					canDead = false
				end
			end
		end

		if canDead then
			if player ~= nil then
				player.plySkill:killPlayer({victim = self, attackData = attackData})
			end
			self:dead(attackData, player);
			--普通攻击结束玩家死亡回调 
			self.plyMgr.attacker_relicMgr:playDead(self, player)
			self.plyMgr.defender_relicMgr:playDead(self, player)
		end
	else
		--攻击时附带的buf
		local injureBuf = string.split(attackData["buffId"], ",")
		--优先加入buf
		--攻击时加入的buf
		if #injureBuf > 0 then
			for k,v in ipairs(injureBuf) do
				if v ~= "nil" then
					self.bufMgr:addBufById(tonumber(v), player, attackData.skillConfig);
				end
			end
		end
		
		--攻击时附带的RichBuff
		if attackData.richBuff then
			for i, v in ipairs(attackData.richBuff) do
				if v.rate == GlobalTools.base100 or GlobalTools:CheckRandom100(v.rate) then
					if v.target == "target" then
						self.bufMgr:addBufById(v.id, player, attackData.skillConfig)
					elseif v.target == "self" then
						player.bufMgr:addBufById(v.id, player, attackData.skillConfig)
					end
				end
			end
		end
		
		-- 造成伤害附带的buff，加完后处理
		EventDispatcher:dipatchEvent("afterAddBuff",{ killer = player, victim = self, wantdata = wantdata, attackData = attackData})
		
		if self.aiEngine ~= nil and self.aiEngine.curState ~= nil and self.aiEngine.curState.key ~= "injureMove" then
			local canMove = true
			local buffs = self.bufMgr:findBufByType("Immunity")
			for k, v in ipairs(buffs) do
				if v.bufWork:checkHit() == true then
					canMove = false
					break
				end
			end
			if canMove then
				local power = attackData["power"] or GlobalTools.base30
				if hp_damage > GlobalTools:Mul( self.data:get_hp(), GlobalTools.base0_0_7 ) then --0.07
					power = GlobalTools:Mul(power, GlobalTools.base2)
				elseif hp_damage > GlobalTools:Mul( self.data:get_hp(), GlobalTools.base0_2 ) then --0.2
					power = GlobalTools:Mul(power, GlobalTools.base3)
				end

				if power >= GlobalTools:Mul(self.weight, GlobalTools.base5) then
					self.injureMoveData["injureType"] = 4
					self.injureMoveData["endType"] = 3
					self.injureMoveData["hSpeed"] = GlobalTools.base50
					self.injureMoveData["vSpeed"] = GlobalTools.base10
				elseif power >= GlobalTools:Mul(self.weight, GlobalTools.base4 ) then
					self.injureMoveData["injureType"] = 3
					self.injureMoveData["endType"] = 3
					self.injureMoveData["hSpeed"] = GlobalTools.base15
					self.injureMoveData["vSpeed"] = GlobalTools.base10
				elseif power >= GlobalTools:Mul(self.weight, GlobalTools.base3 ) then
					self.injureMoveData["injureType"] = 2
					self.injureMoveData["endType"] = 2
					self.injureMoveData["hSpeed"] = GlobalTools.base10
					self.injureMoveData["vSpeed"] = GlobalTools.base0;
				elseif power >= GlobalTools:Mul(self.weight, GlobalTools.base2 ) then
					self.injureMoveData["injureType"] = 2
					self.injureMoveData["endType"] = 1
					self.injureMoveData["hSpeed"] = GlobalTools.base0;
					self.injureMoveData["vSpeed"] = GlobalTools.base0;
				elseif power >= self.weight then
					self.injureMoveData["injureType"] = 1
					self.injureMoveData["endType"] = 1
					self.injureMoveData["hSpeed"] = GlobalTools.base0;
					self.injureMoveData["vSpeed"] = GlobalTools.base0;
				end
				self.injureMoveData["type"] = nil
				self.injureMoveData["killer"] = player
				local dir = attackData["injureDir"]
				if attackData["injureDir"] == nil then
					if player ~= nil then
						dir = player:getForward()
					else
						dir = GlobalTools:Mul( self:getForward() , -GlobalTools.base1 )
					end
				end
				self.injureMoveData["dir"] = FixVector3.New(0,0,0);
				if dir.x >= GlobalTools.base0 then
					self.injureMoveData["dir"].x = GlobalTools.base1
				else
					self.injureMoveData["dir"].x = -GlobalTools.base1
				end
				self.injureMoveData["dir"].y = GlobalTools.base0
				self.injureMoveData["dir"].z = GlobalTools.base0
				
				if power >= self.weight then
					self.aiEngine:changeState("injureMove")
					wantdata["hasInjureMove"] = true
				end
			end
		end

		if wantdata["hasInjureMove"] ~= true then
			self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelPlayInjureAnim)
		end
	end
end

--- 预判攻击是否会致死
---@param attackData Battle_AttackData
---@param wantdata Battle_BeHitDirectData_WantData
function M:isAttackCauseDeath(attackData, wantdata)
	if self.data:get_curHp() <= wantdata.damage then
		local shieldValue = 0
		if attackData["ignoreGuard"] ~= true then
			local shieldBuf = self.bufMgr:findBufByType("Shield")
			for k,v in ipairs(shieldBuf) do
				if v.bufWork.value > 0 then
					shieldValue = shieldValue + v.bufWork.value
				end
			end
		end
		return self.data:get_curHp() + shieldValue <= wantdata.damage
	end
	return false
end

function M:beHitRealDamage( damage, killer, skill )
	local attackData = BattleTool:getBaseAttackData()
	attackData["damage"] = damage
	attackData["player"] = killer
	attackData["skillConfig"] = skill
	attackData["injureType"] = skill and "skill" or ""
	attackData["damageFront"] = GlobalTools.base1
	attackData["damageLast"] = GlobalTools.base1
	attackData["angerAir"] = 0
	attackData["type"] = 0
	attackData["injureBuf"] = 0
	attackData["damageType"] = 1
	attackData["ignoreGuard"] = true

	local wantdata = {}
	wantdata["damage"] = attackData["damage"]
	wantdata["suck_value"]  = 0

	self:beHitDirect(killer, attackData, wantdata, false)
end


function M:addMaterialToPlayer( materialName, materialType )
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSetMaterial,{ matName = materialName, matType = materialType})
end

function M:playEffect( effectData ,player, effectPlayer)
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelPlayEffect,{ data = effectData, ply = player, effectPly = effectPlayer})
end

function M:removeEffectByName( effect_name)
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelRemoveEffectByName,{ effect_name = effect_name})
end


--创建特效
function M:CreateEffect( name )
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelCreateEffect,{name = name})
end


--播放被击特效
function M:playHitEffect(player, attackData, isCrit)
	if self.hitEffect ~= nil then
		self.hitEffect.player = player;
		self.hitEffect.attackData = attackData;
		self.hitEffect.isCrit = isCrit;
		self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelPlayHitEffect,self.hitEffect)
	end
end

--通知视图 销毁 HpLabel 
function M:callViewDestroyHpLabel()
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelDestoryHpLabel)
end

function M:skillEnd(skillConfig, skillEndData)
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSkillEnd,{skillConfig = skillConfig, skillEndData = skillEndData})
end

--显示UI
function M:ShowHitUI( type, attackData )
	if self.hitUI ~= nil then
		self.hitUI.type = type;
		self.hitUI.attackData = attackData;
		self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelShowHitUI, self.hitUI)
	end
end

--显示伤害的 Label
function M:showHitLabel(damage, isCrit)
	if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
		return
	end
	--冒血数字
	local attackType = 0
	if isCrit == true then
		attackType = 1
	end
	--暂时的，后面看下伤害为什么 是 0
	if damage > GlobalTools.base0 then
		self:showLabel(damage, "-", attackType);
	end
end

function M:showData(player, attackData, damage, isCrit)
	local showPlayerData = {}
	showPlayerData.player = player;
	--攻击数据
	showPlayerData.attackData = attackData;
	--伤害
	showPlayerData.damage = damage;
	--是否是暴击
	showPlayerData.isCrit = isCrit;
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelShowData, showPlayerData)
end

--我杀人了
function M:kill(player)
	--杀人增加怒气,杀人增加怒气200
	self.killNum = self.killNum + 1;
	self.data:addAnger(self.data:getKillEnergy());
end
--计算总的血量丢失
function M:calculateTotalLostHp(hp_damage)
	if hp_damage >= 0 then
		self.totalLostHp = self.totalLostHp + hp_damage
		self.totalLostHp_float = self.totalLostHp_float + Mathf.Floor(GlobalTools:ToFloat(hp_damage))
		self.plyMgr:setLostHpData(self, self.totalLostHp_float, self.totalLostHp)
		EventDispatcher:dipatchEvent("calculateDamage",{ player = self, totalLostHp = self.totalLostHp_float} )
	else
		Logger.logError(hp_damage, "ERROR: calculateTotalLostHp damage can not negative number")
	end
end
--统计伤害量
function M:calculateDamage(hp_damage)
	self.totalDamage = self.totalDamage + hp_damage
end

--玩家死亡
---@param attackData Battle_AttackData
---@param player PlayerModel
function M:dead(attackData, player)
	if SceneManager.curScene.replayFix and SceneManager.curScene.replayFix.isReplay then
		local replayFix = SceneManager.curScene.replayFix
		if not replayFix:isDeadFix(self) then  -- 修正数据没有记录死亡
			replayFix:fixPlayerInfo(SceneManager.curScene:get_loopTimeNormal(), self)
			--Logger.log(string.format("%s 角色死亡被ReplayFix拦截", tostring(self.plyType)))
			return
		end
	end
	
	if self:isLive() then
		--玩家状态切换到死亡
		self.plyState = -1
		EventDispatcher:dipatchEvent("killPlayer",{ killer = player, victim = self, attackData = attackData} )
		if player ~= nil and attackData ~= nil then
			local injureBuf = attackData["buffType"]
			if injureBuf ~= nil and injureBuf ~= "None" and injureBuf ~= 0 then
				if attackData["isDeadbuff"] ~= nil and attackData["isDeadbuff"] == true then
					player.bufMgr:addBuf(attackData, player);
				end
			end
			player:kill(self)
			self.killer_player = player
			if attackData.skillConfig ~= nil then
				attackData.skillConfig:killPlayer()
				player:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSkillKillPlayer, {skillConfig = attackData.skillConfig})
			end
		end

		if self.grid ~= nil then
			self.grid:setValue(0);
			self:setGrid(nil);
		end

		--加入玩家死亡
		if SceneManager.curScene.tongjiData ~= nil then
			SceneManager.curScene.tongjiData:addDeadNode(self)
		end
		
		-- if self.obj ~= nil then
		-- 	self.obj:SetActive(false)
		-- end
		if self.lockMeList.Count <= 0 then
			self:realDead()
		end
	end
end

-- 复活
function M:relived()
	self.plyState = 1  -- 角色复活
	self.plyMgr:removeHide(self)
	EventDispatcher:dipatchEvent("relive", {player = self})
end

-- 移除延迟展示的buf特效
function M:removeDelayTimeBufEffect()
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelStopTimeTask)
end

--真正死亡
function M:realDead()
	if self.canRelive == true then
		self:enterSuspended()
	else
		self:enterRealDead()
	end
end

--- 进入假死，可以复活
function M:enterSuspended()
	self.plyState = -4
	EventDispatcher:dipatchEvent("PlayerSuspended",{ data = self } )
	
	self:clearMgr(false)
	self.data:set_curHp(GlobalTools.base1)
	if self.aiEngine ~= nil then
		self.aiEngine:changeState("die_into")
	end
end

--- 真死亡逻辑
function M:enterRealDead()
	--设置玩家状态
	self.plyState = -2
	EventDispatcher:dipatchEvent("PlayerDead",{ data = self } )
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelRealDead)
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelStopTimeTask)
	--清空格子数据
	if self.grid ~= nil then
		self.grid:setValue(0);
		self:setGrid(nil);
	end

	--神器结束
	--self.ArtifactMgr:gameover()
	--动画切换到死亡. 如果此时没有进入die逻辑，需要自己处理角色的destroy逻辑
	if self.aiEngine ~= nil and not self.doNotEnterDie then
		if SceneManager.curScene.sceneId ~= SceneManager.SceneID.LegendScene then
			self.aiEngine:changeState("die")
		else
			self:destroy()
		end
	end

	if not self.keepMgrAfterDead then
		self:clearMgr(true)
	end
end


--设定移动目标
function M:setMoveTarget( target )
	self.player_move_target_last = self.player_move_target;
	if self.player_move_target_last ~= nil then
		self.player_move_target_last:change(0)
	end
	if target ~= nil then
		target:change(2)
	end
	self.player_move_target = target;
end


function M:findMoveTarget()
	--self:findPath();
	----设定移动目标
	--local moveTarget = self:get_move_target()
	--if moveTarget ~= nil then
	--	self:setMoveTarget( moveTarget );
	--end
end

--AStar移动
function M:move_astar(dt)
	--如果没有移动目标
	self:findMoveTarget()
	--目标移动
	if self.player_move_target ~= nil then
		--移动目标和玩家格子不相同
		if self.player_move_target.IsVisi == false and self.player_move_target ~= self.grid then
			--朝向我的移动目标移动
			local fix_move_target = GlobalTools:ToFixVector3(self.player_move_target.worldPosition);
			if SceneManager.curScene.sceneId ~= SceneManager.SceneID.HangUpScene then
				SceneManager.curScene:getAreaPosition(fix_move_target);
			end
			local distance = GlobalTools:Distance(fix_move_target, self.position);
			if distance < GlobalTools:ToFix2(0.2) then
				return true;
			else
				local dir = GlobalTools:Dir(fix_move_target,self.position);
				if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene and self.camp == 1 and self.position.x > fix_move_target.x then
					dir = FixVector3.right();
				end
				self:move_no_coillder(dir, dt);
				self:rotaTo(dir, dt);
			end
		end
	else
		if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene and self.camp == 1 then
			return true;
		end
		if self.grid ~= nil then
            local fix_target_pos = GlobalTools:ToFixVector3(self.grid.worldPosition);
			if SceneManager.curScene.sceneId ~= SceneManager.SceneID.HangUpScene then
				SceneManager.curScene:getAreaPosition(fix_target_pos);
			end
			local distance = GlobalTools:Distance(fix_target_pos, self.position);
			--if SceneManager.curScene.sceneId == 1 and self.camp == 1 and self.position.x > fix_target_pos.x then
			if distance < GlobalTools:ToFix2(0.2) then
				return true;
			else
				local dir = GlobalTools:Dir(fix_target_pos,self.position);
				self:move_no_coillder(dir, dt);
				self:rotaTo(dir, dt);
			end
		end
	end
	return false;
end

--设定格子
function M:setGrid( gridData )
	if self.grid ~= nil then
		self.grid:setValue(0);
	end
	self.grid = gridData;
	if self.grid ~= nil then
		self.grid:setValue(1);
	end
end

--计算格子
function M:caculateGridSix()
	if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
		if self:isLive() then
			self:method1();
		end
	elseif (SceneManager.curScene.sceneId == SceneManager.SceneID.FightScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.TianjiLouFightScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.MiGongFightScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.GuJianQiTanFightScene) then
		if self:isLive() then
			if SceneManager.curScene:get_runframe() > 0 then
				self:method1();
			end
		end
	end
end

--计算方法1
function M:method1()
	if self:isLive() then
		local grid = SceneManager.curScene.aStar:setGrid(self.position, self.grid)
		if grid ~= nil then
			self:setGrid(grid)
		end
	end
end
--获取移动目标
function M:get_move_target()
	local move_target = nil;
	if self.player_path.Count > 0 then
		move_target = self.player_path:get(0);
		self.player_path:clear();
	end
	return move_target;
end

--移动无碰撞
function M:move_no_coillder(dir, dt)
	local spd = self.data:getSpd()
	local pos = self.position + dir * spd * dt
	if SceneManager.curScene.getAreaPosition ~= nil then
		SceneManager.curScene:getAreaPosition(pos)
	end
	self:setPos( pos );
end

--定点旋转到
function M:rotaTo( dir,dt )
    if GlobalTools:Abs(dir.x) + GlobalTools:Abs(dir.z) > 0 then
        if self.isBoss == false then
            self:setForward(dir)
        end
    end
end

--设置当前技能配置
function M:setCurSkillConfig()
	if self:isLive() then
		local skillConfig = self.plySkill:getCanUseMostPriority();
		if skillConfig ~= nil then
			--Logger.log(" 技能配置 ~~~~~~~~~~~~~~ "..skillConfig.name.." LoopTime "..SceneManager.curScene:get_runframe() )
		else
			--Logger.log(" 技能配置 ~~~~~~~~~~~~~~ null " .." LoopTime "..SceneManager.curScene:get_runframe() )		
		end
		return skillConfig
	end
end


--战斗结束
function M:gameover( re )
	self.player_gameover = true;
	--删除宠物列表 
	for i = 1, self.summonList.list.Count do
		local key = self.summonList.list:get(i-1)
		local plys = self.summonList:get(key)
		for i, v in ipairs(plys) do
			self.plyMgr:destoryPlayer(v)
		end
	end
	self.summonList:clear();
	
	if self.master ~= nil then
		self.plyMgr:destoryPlayer(self)
	end
	self:clearMgr(true)

	if self.aiEngine ~= nil then
		self.aiEngine:changeState("over", {re = re})
	end
end

--是否是死亡状态
function M:isDead()
	return self.plyState == -1 or self.plyState == -2 or self.plyState == -3
end
function M:isRealDead()
	return self.plyState == -2 or self.plyState == -3
end
function M:isDestroy()
	return self.plyState == -3
end
function M:isLive()
	return self.plyState == 1
end

function M:destroy(isDestroyObj)
	self.isDestoryMe = true;
	self.plyState = -3
	self:clearMgr(true)

	-- 角色销毁时存一下当前最大生命值
	--加入统计数据
	local tongjiData = SceneManager:getCurSceneModel().tongjiData
	if tongjiData ~= nil then
		tongjiData:setPlayerMaxHp(self:get_playerInstanceId(), self.data:get_hp(), self.camp)
		tongjiData:setPlayerHp(self:get_playerInstanceId(), self.data:get_curHp(), self.camp)
	end

	--ai状态机停止运行
	if self.aiEngine ~= nil then
		self.aiEngine:destroy()
		self.aiEngine = nil
	end
	if self.animator ~= nil then
		self.animator:destroy()
		self.animator = nil
	end
	if self.skyStar ~= nil then
		self.skyStar:destroy()
		self.skyStar = nil
	end
	if self.resonance ~= nil then
		self.resonance:destroy()
		self.resonance = nil
	end
	if self.dataShow ~= nil then
		self.dataShow = nil;
	end
	if self.profressionMgr ~= nil then
		self.profressionMgr = nil
	end

	if self.talismanMgr ~= nil then
		self.talismanMgr:destroy()
		self.talismanMgr = nil
	end
	self.hitEffect = nil;
	self.hitUI = nil;
	--self.ArtifactMgr:destroy()
	-- 是否真正销毁物体
	local destroyData = {}
	destroyData.isDestroyObj = isDestroyObj;
	-- 通知视图层 数据销毁了
	EventDispatcher:unRegisterEvent("bossMaxnum", {self,self.bossMaxnumHandler})
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelDestroy, destroyData)
end


--清理管理器
function M:clearMgr(isDestroy)
	--删除技能帧
	if self.skillFrameMgr ~= nil and isDestroy then
		self.skillFrameMgr:destroy()
	end
	--删除buff
	if self.bufMgr ~= nil then
		if isDestroy then
			self.bufMgr:destroy()
		else
			self.bufMgr:clearBuf()	
		end
	end
	if self.summonMgr ~= nil then
		if isDestroy then
			self.summonMgr:destroy()
		else
			self.summonMgr:clear()			
		end
	end

	if self.plySkill ~= nil and isDestroy then
		self.plySkill:destroy()
	end
	
	if self.mysticMgr ~= nil and isDestroy then
		self.mysticMgr:destroy()
	end

	self.bulletMgr:clear()
	self.moveMgr:clear()

	-- 如果有召唤物则清除召唤物
	-- 宠物列表
	for i = 1, self.summonList.list.Count do
		local key = self.summonList.list:get(i-1)
		local plys = self.summonList:get(key)
		for i, v in ipairs(plys) do
			--if v.summonData.dieWithMaster == true then
				self.plyMgr:destoryPlayer(v)
			--end
		end
	end
	self.summonList:clear();

	if self.master ~= nil then
		for i = 1, self.master.summonList.list.Count do
			local key = self.master.summonList.list:get(i-1)
			local plys = self.master.summonList:get(key)
			for i, v in ipairs(plys) do
				if self:equal(v) == true then
					plys[i] = nil
					break
				end
			end
		end
	end
	self:clear_player_enemyList();
	
	if self.killer_list ~= nil then
		self.killer_list:clear();
	end
	if self.enemyIsMe_list ~= nil then
		self.enemyIsMe_list:clear();
	end
	if self.curSkillEnemyList ~= nil then
		self.curSkillEnemyList:clear();
	end
	if self.lockMeList ~= nil then
		self.lockMeList:clear();
	end
	if self.player_path ~= nil then
		self.player_path:clear();
	end
	if self.resistBullet ~= nil then
		self.resistBullet:clear();
	end

	if self.lineMgr ~= nil then
		self.lineMgr:clear()
	end
	
	SelectTargetTool:clearPlayer(self);
	
	if self.partMgr ~= nil and isDestroy then
		self.partMgr:destroy()
	end

	if self.trait ~= nil and isDestroy then
		self.trait:destroy()
	end
	if self.data and SceneManager.curScene.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.LEGEND then
		--清除临时属性
		self.data:clearTempData()
	end

	if self.evtMgr ~= nil and isDestroy then
		self.evtMgr:destroy()
		self.evtMgr = nil
	end
	self.plyMgr:removeHide(self)
	self.plyMgr:removePlayerFromOtherPlayerList(self)
	self.killer = nil
	self.lastSelect = nil
	self.injureMoveData["killer"] = nil
end

function M:removeOtherPlayer(ply)
	self:remove_player_enemyList(ply)
	if self.killer_list ~= nil then
		self.killer_list:remove(ply)
	end
	if self.enemyIsMe_list ~= nil then
		self.enemyIsMe_list:remove(ply)
	end
	if self.curSkillEnemyList ~= nil then
		self.curSkillEnemyList:remove(ply)
	end
	if self.lockMeList ~= nil then
		self.lockMeList:remove(ply)
	end
	if self.bufMgr ~= nil then
		self.bufMgr:destoryBuffByPlayer(ply)
	end
	if self.lastSelect ~= nil then
		self.lastSelect:remove(ply)
		if self.lastSelect ~= nil and self.lastSelect.Count == 0 then
			self.lastSelect = nil
		end
	end
end

--player之间是否相等
function M:equal(player)
	if player ~= nil and player:get_playerInstanceId() == self.playerInstanceId then
		return true
	else
		return false
	end
end

--受伤暂停
function M:injurePause(time)
	self.injurePauseTime = time
end

function M:setFollowPart(part)
	self.followPart = part
end

--设定层级
function M:setLayer( isBlack )
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelSetLayer,{isBlack = isBlack})
end

--设置动画速度
function M:setAnimSpeed(speed)
	self.animator:set_animSpeed(speed)
end

---暂停自身的动作（不影响自身的mgr的update）
function M:pauseAnim()
	self.animator:pause()
end

---恢复自身的动作
function M:resumeAnim()
	self.animator:resume()
end

--检测是否是助阵角色
function M:checkApostle()
	if self.heroData.apostle_flag  or self.heroData.mastor_apostle_flag or self.heroData.novice_apostle_flag then
		return true
	end
	return false
end

--是否在黑屏之中
function M:inBlackTime()
	return self.isInBlackTime;
end

function M:setWeight(weight)
	self.weight = weight
end

-- ********************************************************************
-- 黑屏处理
-- ********************************************************************

--黑屏结束处理
function M:overBlackTimeHandler()
	self.isInBlackTime = false;
	--黑屏结束发送事件
	EventDispatcher:dipatchEvent("BlackOver",{ data = self })
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelStopBlack)
end

--开始设定黑屏的时候做的处理
function M:startBlackTimeHandler()
	self.isInBlackTime = true;
	--开始黑屏
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerModelStartBlack)
end

return M;
