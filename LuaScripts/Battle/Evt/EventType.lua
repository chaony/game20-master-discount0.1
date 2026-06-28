--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-01-19 16:09:28
]]

--事件类型
local EventType = {}

--MV 表示事件是从 Model 到 View
--VM 表示事件是从 View 到 Model

-- TimeManager
-- 全局事件 TimeManager 设定时间
EventType.MV_TimeManagerSetTime = "MV_TimeManagerSetTime";


-- Scene ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

EventType.MV_SceneModelPlayEffect = "MV_SceneModelPlayEffect"
--场景数据层初始化完成，通知视图层
EventType.MV_SceneModelCreateFinish = "MV_SceneModelCreateFinish"
--重新设置UI
EventType.MV_SceneModelResetUI = "MV_SceneModelResetUI"
--场景数据层Enter 
EventType.MV_SceneModelEnter = "MV_SceneModelEnter"
--场景数据层Enter 
EventType.MV_SceneModelCameraShow = "MV_SceneModelCameraShow"
--场景销毁
EventType.MV_SceneModelDestory = "MV_SceneModelDestory"
--场景数据层初始化完成，通知视图层
EventType.MV_SceneModelInitFinish = "MV_SceneModelInitFinish"
--场景数据层初始化完成，通知视图层发送事件
EventType.MV_SceneModelSendEvent = "MV_SceneModelSendEvent"
--战斗开始
EventType.MV_SceneModelBattleStart = "MV_SceneModelBattleStart"
--战斗一次
EventType.MV_SceneModelBattleOnce = "MV_SceneModelBattleOnce"
--更新玩家UI
EventType.MV_SceneModelUpdatePlayerUI = "MV_SceneModelUpdatePlayerUI"
--创建玩家特效
EventType.MV_SceneModelCreateEffect = "MV_SceneModelCreateEffect"
--布阵
EventType.MV_SceneModelArray = "MV_SceneModelArray"
--更新阵法数据
EventType.MV_SceneModelUpdateDeployment = "MV_SceneModelUpdateDeployment"
--设定场景的状态
EventType.MV_SceneModelSetState = "MV_SceneModelSetState"
--设定场景的状态
EventType.MV_SceneModelPlayerSpawn = "MV_SceneModelPlayerSpawn"
--处理特效和摄像机
EventType.MV_SceneModelHandleEffectAndCamera = "MV_SceneModelHandleEffectAndCamera"
--下阵处理
EventType.MV_SceneModelGoDownBattle = "MV_SceneModelGoDownBattle"
--游戏结束
EventType.MV_SceneModelGameOver = "MV_SceneModelGameOver"
--配置战斗开始
EventType.MV_SceneModelConfigStart = "MV_SceneModelConfigStart"
--江湖传说--- 更新击杀数量
EventType.MV_LegendFightSceneModelUpdateKillNum = "MV_LegendFightSceneModelUpdateKillNum"
--江湖传说--- 更新生存模式buff属性
EventType.MV_LegendFightSceneModelUpdateBuff = "MV_LegendFightSceneModelUpdateBuff"


--宠物对战
--宠物对战开始
EventType.MV_SceneModel_PetContestStart = "MV_SceneModel_PetContestStart"
EventType.MV_PetContestValueChanged = "MV_PetContestValueChanged"
EventType.MV_PetContestResult = "MV_PetContestResult"

--宠物
EventType.VM_SceneModel_PetContestStart = "VM_SceneModel_PetContestStart"
EventType.VM_SceneModel_PetContestResult = "VM_SceneModel_PetContestResult"


--队伍数据
EventType.MV_TeamModelCreateFinish = "MV_TeamModelCreateFinish"
EventType.VM_TeamModelCreateFinish = "VM_TeamModelCreateFinish"




-- @@@@@@@@
--场景加载完成
EventType.VM_SceneViewLoadFinish = "VM_SceneViewLoadFinish"
--剧情设定玩家属性
EventType.VM_SceneViewSetPlayerAttr = "VM_SceneViewSetPlayerAttr"
--剧情战斗开始
EventType.VM_SceneViewCallBattleStart = "VM_SceneViewCallBattleStart"

-- SceneGuide ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 场景向导 创建完成
EventType.MV_SceneGuideModelCreateFinish = "MV_SceneGuideModelCreateFinish"
-- 场景向导 同步位置
EventType.MV_SceneGuideModelSyncPosition = "MV_SceneGuideModelSyncPosition"
-- 销毁
EventType.MV_SceneGuideModelDestory = "MV_SceneGuideModelDestory"


-- PlayerManager ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 玩家管理器
--玩家管理器的数据层创建完成
EventType.MV_PlayerManagerModelCreateFinish = "MV_PlayerManagerModelCreateFinish";
--玩家出生
EventType.MV_PlayerManagerPlayerSpawn = "MV_PlayerManagerPlayerSpawn";
--玩家管理器销毁
EventType.MV_PlayerManagerDestroy = "MV_PlayerManagerDestroy";
--黑屏处理
EventType.MV_PlayerManagerBlackScreen = "MV_PlayerManagerBlackScreen";
--战斗开始
EventType.MV_PlayerManagerStartBattle = "MV_PlayerManagerStartBattle";
--重新设置玩家位置
EventType.MV_PlayerManagerResetPlayerPosition = "MV_PlayerManagerResetPlayerPosition";
--游戏暂停
EventType.MV_PlayerManagerPause = "MV_PlayerManagerPause";
--游戏继续
EventType.MV_PlayerManagerContinue = "MV_PlayerManagerContinue";
--游戏结束
EventType.MV_PlayerManagerGameOver = "MV_PlayerManagerGameOver";





-- Player ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  玩家
--玩家的数据层创建完成
EventType.MV_PlayerModelCreateFinish = "MV_PlayerModelCreateFinish";
--玩家血量更新了
EventType.MV_PlayerModelHpChange = "MV_PlayerModelHpChange";
--玩家的位置改变了
EventType.MV_PlayerModelPositionChange = "MV_PlayerModelPositionChange";
--玩家的方向改变了
EventType.MV_PlayerModelDirChange = "MV_PlayerModelDirChange";
--玩家怒气值更新通知
EventType.MV_PlayerModelAngerChange = "MV_PlayerModelAngerChange";
--显示提示数字
EventType.MV_PlayerModelShowLabel = "MV_PlayerModelShowLabel";
--大招好了通知刷新UI
EventType.MV_PlayerModelSkill3RefreshCard = "MV_PlayerModelSkill3RefreshCard";
--玩家数据层 update 消息
EventType.MV_PlayerModelUpdate = "MV_PlayerModelUpdate";
--玩家设定缩放值
EventType.MV_PlayerModelSetScale = "MV_PlayerModelSetScale"
--玩家 数据层 通知 显示层，要显示数据
EventType.MV_PlayerModelShowData = "MV_PlayerModelShowData"
-- PlayerModel 显示攻击UI
EventType.MV_PlayerModelShowHitUI = "MV_PlayerModelShowHitUI";
-- PlayerModel 数据层销毁
EventType.MV_PlayerModelDestroy = "MV_PlayerModelDestroy";
-- 数据层 通知 视图层 播放特效
EventType.MV_PlayerModelPlayHitEffect = "MV_PlayerModelPlayHitEffect";
-- 数据层 通知 视图层 播放特效
EventType.MV_PlayerModelDestoryHpLabel = "MV_PlayerModelDestoryHpLabel";
-- 数据层 通知 视图层 创建特效
EventType.MV_PlayerModelCreateEffect = "MV_PlayerModelCreateEffect";
-- 数据层 通知 视图层 播放受击位移
EventType.MV_PlayerModelPlayInjureAnim = "MV_PlayerModelPlayInjureAnim";
-- 同步实例id
EventType.MV_PlayerModelSyncInstanceId = "MV_PlayerModelSyncInstanceId";
-- 玩家AI退出发送事件
EventType.MV_PlayerModeAIStateExit = "MV_PlayerModeAIStateExit"
-- 玩家出生
EventType.MV_PlayerModelSpawn = "MV_PlayerModelSpawn";
-- 玩家设定层级
EventType.MV_PlayerModelSetLayer = "MV_PlayerModelSetLayer";
-- 进入大招 AI Skill
EventType.MV_PlayerModelEnterAISkill = "MV_PlayerModelEnterAISkill";
--开始黑屏
EventType.MV_PlayerModelStartBlack = "MV_PlayerModelStartBlack";
--停止黑屏
EventType.MV_PlayerModelStopBlack = "MV_PlayerModelStopBlack";
--设定主人
EventType.MV_PlayerModelSetMaster = "MV_PlayerModelSetMaster";
--播放特效
EventType.MV_PlayerModelPlayEffect = "MV_PlayerModelPlayEffect";
--变化材质
EventType.MV_PlayerModelSetMaterial = "MV_PlayerModelSetMaterial";
--通过特效名删除特效
EventType.MV_PlayerModelRemoveEffectByName = "MV_PlayerModelRemoveEffectByName";
--治疗
EventType.MV_PlayerModelCure = "MV_PlayerModelCure";
--显示血条 
EventType.MV_PlayerModelShowHpBar = "MV_PlayerModelShowHpBar";
--隐藏body
EventType.MV_PlayerModelHideBody = "MV_PlayerModelHideBody";
--玩家真正死亡
EventType.MV_PlayerModelRealDead = "MV_PlayerModelRealDead";
--同步敌人列表
EventType.MV_PlayerModelSyncEnemyList = "MV_PlayerModelSyncEnemyList"
--同步嘲讽列表 
EventType.MV_PlayerModelSyncTauntList = "MV_PlayerModelSyncTauntList"
--设定敌人
EventType.MV_PlayerModelSetEnemy = "MV_PlayerModelSetEnemy";
--数据通知视图View 
EventType.MV_PlayerModelSetIndex = "MV_PlayerModelSetIndex";
--技能结束
EventType.MV_PlayerModelSkillEnd = "MV_PlayerModelSkillEnd";
--技能结束
EventType.MV_PlayerModelSetRotationMode = "MV_PlayerModelSetRotationMode";
--技能击杀了玩家
EventType.MV_PlayerModelSkillKillPlayer = "MV_PlayerModelSkillKillPlayer";
--设定Boss 标识
EventType.MV_PlayerModelSetBoss = "MV_PlayerModelSetBoss";
--角色离场
EventType.MV_PlayerModelLeaveBattle = "MV_PlayerModelLeaveBattle";
-- 停止延迟buff特效任务的特效播放
EventType.MV_PlayerModelStopTimeTask = "MV_PlayerModelStopTimeTask";

--点击事件
EventType.VM_PlayerViewClickDown = "VM_PlayerViewClickDown"
--设定Index
EventType.VM_PlayerViewSetIndex = "VM_PlayerViewSetIndex"


-- PlayerAnimator ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 动画状态机
-- 动画状态机切换状态
EventType.MV_PlayerAnimatorChangeState = "MV_PlayerAnimatorChangeState";
-- 动画状态机设定模式
EventType.MV_PlayerAnimatorSetMode = "MV_PlayerAnimatorSetMode";
-- 动画状态机某个状态切换完毕
EventType.MV_PlayerAnimatorStateExit = "MV_PlayerAnimatorStateExit";
-- 动画控制器中设定动画速度
EventType.MV_PlayerAnimatorSetAnimSpeed = "MV_PlayerAnimatorSetAnimSpeed";


-- AnimEvtFrame 美术的帧触发
EventType.MV_AnimEvtFrameMeiShuTrigger = "MV_AnimEvtFrameMeiShuTrigger";
-- AnimEvtFrameModel 创建完成
EventType.MV_AnimEvtFrameModelCreateFinish = "MV_AnimEvtFrameModelCreateFinish";
-- AnimEvtFrame hit帧播放范围攻击特效
EventType.MV_AnimEvtFrameMeiShuHitAoeEffect = "MV_AnimEvtFrameMeiShuHitAoeEffect";

-- PlayerSkill ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 玩家技能
-- SkillFeatures ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 玩家技能的Model创建完成
EventType.MV_SkillFeaturesModelCreateFinish = "MV_SkillFeaturesModelCreateFinish";
-- 技能模式通知 技能开始
EventType.MV_SkillFeaturesModelSkillStart = "MV_SkillFeaturesModelSkillStart";
-- 技能模式通知 技能结束
EventType.MV_SkillFeaturesModelSkillEnd = "MV_SkillFeaturesModelSkillEnd";
-- 技能模式通知 出生
EventType.MV_SkillFeaturesModelSpawn = "MV_SkillFeaturesModelSpawn";
-- 技能模式通知 出生结束
EventType.MV_SkillFeaturesModelSpawnFinish = "MV_SkillFeaturesModelSpawnFinish";
-- 技能模式通知 销毁特效
EventType.MV_SkillFeaturesModelDestroyEffect = "MV_SkillFeaturesModelDestroyEffect";
-- 技能模式通知 技能Model更新
EventType.MV_SkillFeaturesModelUpdate = "MV_SkillFeaturesModelUpdate";
-- 技能模式通知 销毁通知
EventType.MV_SkillFeaturesModelDestroy = "MV_SkillFeaturesModelDestroy";

-- 数据层 通知 视图层 更新头顶UI
EventType.MV_SkillFeaturesModelCreateHeadUI = "MV_SkillFeaturesModelCreateHeadUI";
-- 数据层 通知 视图层 更新头顶UI
EventType.MV_SkillFeaturesModelUpdateHeadUI = "MV_SkillFeaturesModelUpdateHeadUI";
-- 数据层 通知 视图层 移除头顶UI
EventType.MV_SkillFeaturesModelRemoveHeadUI = "MV_SkillFeaturesModelRemoveHeadUI";

-- PlayerBuf ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  玩家的Buf
-- PlayerBufModel 创建完成
EventType.MV_PlayerBufModelCreateFinish = "MV_PlayerBufModelCreateFinish";
-- PlayerBufModel 播放特效
EventType.MV_PlayerBufModelPlayEffect = "MV_PlayerBufModelPlayEffect";
-- PlayerBufModel 刷新Icon
EventType.MV_PlayerBufModelRefreshIcon = "MV_PlayerBufModelRefreshIcon";
-- PlayerBufModel 播放音乐
EventType.MV_PlayerBufModelPlayAudio = "MV_PlayerBufModelPlayAudio";
-- PlayerBufModel 停止播放音乐
EventType.MV_PlayerBufModelStopAudio = "MV_PlayerBufModelStopAudio";
-- PlayerBufModel 删除特效
EventType.MV_PlayerBufModelDeleteEffect = "MV_PlayerBufModelDeleteEffect";
-- PlayerBufModel 删除特效
EventType.MV_PlayerBufModelReset = "MV_PlayerBufModelReset";

-- BufManager ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  玩家的Buf
-- BufManager 刷新图标
EventType.MV_BufManagerModelRefreshIcon = "MV_BufManagerModelRefreshIcon";


-- BufWorkModel 创建成功
EventType.MV_BufWorkModelCreateFinish = "MV_BufWorkModelCreateFinish";
-- BufWorkModel 发生作用
EventType.MV_BufWorkModelWork = "MV_BufWorkModelWork";
-- BufWorkModel 停止发生作用
EventType.MV_BufWorkModelStop = "MV_BufWorkModelStop";
-- BufWorkModel 重新发生作用
EventType.MV_BufWorkModelReset = "MV_BufWorkModelReset";
-- BufWorkModel 更新
EventType.MV_BufWorkModelUpdate = "MV_BufWorkModelUpdate";
-- BufWorkModel 更新
EventType.MV_BufWorkModelShowBufIcon = "MV_BufWorkModelShowBufIcon";
-- BufWorkMark_Model
EventType.MV_BufWorkModelMarkPlayerEffect = "MV_BufWorkModelMarkPlayerEffect";
-- BufWorkBloodThirsty
EventType.MV_BufWorkBloodThirstyShowHitLable = "MV_BufWorkBloodThirstyShowHitLable";


EventType.MV_BulletManagerClear = "MV_BulletManagerClear";

-- Bullet ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 玩家子弹
-- 子弹的model创建完成
EventType.MV_BulletModelCreateFinish = "MV_BulletModelCreateFinish";
-- 同步子弹 真死亡
EventType.MV_BulletModelBandFinish = "MV_BulletModelBandFinish";
-- 同步子弹的位置
EventType.MV_BulletModelSyncPosition = "MV_BulletModelSyncPosition";
-- 同步子弹的方向
EventType.MV_BulletModelSyncDir = "MV_BulletModelSyncDir";
-- 同步子弹播放特效
EventType.MV_BulletModelPlayEffect = "MV_BulletModelPlayEffect";
-- 同步子弹敌人
EventType.MV_BulletModelSetEnemy = "MV_BulletModelSetEnemy";
-- 同步子弹 真死亡
EventType.MV_BulletModelDead = "MV_BulletModelDead";
-- 同步子弹 射击出去
EventType.MV_BulletModelShoot = "MV_BulletModelShoot";
-- 创建子弹线
EventType.MV_BulletModelCreateLine = "MV_BulletModelCreateLine";
-- 同步子弹状态
EventType.MV_BulletModelSyncState = "MV_BulletModelSyncState";


--线创建完毕
EventType.MV_LineModelCreateFinish = "MV_LineModelCreateFinish"
--线同步位置
EventType.MV_LineModelSyncPosition = "MV_LineModelSyncPosition"
--线同步
EventType.MV_LineModelSyncUpdate = "MV_LineModelSyncUpdate"
--线销毁
EventType.MV_LineModelDestroy = "MV_LineModelDestroy"


--Summon ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 宠物
-- 宠物的model 创建完成
EventType.MV_SummonModelCreateFinish = "MV_SummonModelCreateFinish";
-- 宠物的model 播放特效
EventType.MV_SummonModelPlayEffect = "MV_SummonModelPlayEffect";
-- 宠物的model 停止
EventType.MV_SummonModelStop = "MV_SummonModelStop";
-- 宠物的model 销毁
EventType.MV_SummonModelDestroy = "MV_SummonModelDestroy";

return EventType