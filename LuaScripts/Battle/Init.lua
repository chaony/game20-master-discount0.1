Mathf		= require("Battle.Framework.UnityEngine.Mathf")
Vector3 	= require("Battle.Framework.UnityEngine.Vector3")

require("Battle.Framework.Commom.Functions")
require("Battle.Framework.Commom.IoUtil")
require("Battle.Framework.Commom.StringUtil")
require("Battle.Framework.Commom.TableUtil")

Logger = require("Battle.Framework.Commom.Logger")
Json = require("Battle.Framework.Commom.Json")
MemLeakCheckTools = require("Battle.Framework.Commom.MemLeakCheckTools")
EventDispatcher = require("Battle.Framework.Commom.EventDispatcher")
--表池类
TablePoolUtil = require("Battle.Framework.Commom.TablePoolUtil")
TablePoolUtil:init();

Battle = {}
Battle.EnumData = require("Battle.Data.EnumData")
Battle.BattleGlobalConfig = require("Battle.BattleGlobalConfig")
Battle.BattleConfigManager = require("Battle.Tool.BattleConfigManager")
Battle.EventType = require("Battle.Evt.EventType")
Battle.SkillEventType = require("Battle.Evt.SkillEventType")
Battle.List = require("Battle.Tool.List")
Battle.ListMap = require("Battle.Tool.ListMap")
GlobalTools = require("Battle.Tool.GlobalTools")
XXX = require("Battle.Tool.XXX")

--加载场景管理
require("Battle.Sce.SceneManager")

Battle.AIEngine = require("Battle.SM.Ai.AIEngine")
Battle.AIState = require("Battle.SM.Ai.AIState")
Battle.AIStateAttack_Player = require("Battle.SM.Ai.AIStateAttack_Player")
Battle.AIStateMove_Player = require("Battle.SM.Ai.AIStateMove_Player")
Battle.AIStatePatrol_Player = require("Battle.SM.Ai.AIStatePatrol_Player")


Battle.BattleFSM = require("Battle.SM.Battle.BattleFSM")
Battle.BattleState = require("Battle.SM.Battle.BattleState")
Battle.BattleState_Battle = require("Battle.SM.Battle.BattleState_Battle")
Battle.BattleState_Pet_Contest = require("Battle.SM.Battle.BattleState_Pet_Contest")

TimeManager = require("Battle.Tool.TimeManager")

Battle.SceneGuide_Model = require("Battle.Sce.Guide.SceneGuide_Model")
Battle.GuideModeBase_Model = require("Battle.Sce.Guide.GuideModeBase_Model")
Battle.SceneGridConfig = require("Battle.SceneGridDataConfig");
--基础类
Battle.BaseAll = require("Battle.Base.BaseAll")
Battle.ModelBase = require("Battle.Base.ModelBase")
Battle.ViewBase = require("Battle.Base.ViewBase")
--数据
Battle.Scene_Model = require("Battle.Sce.Scene_Model")
Battle.SceneArrayBase_Model = require("Battle.Sce.SceneArrayBase_Model")
Battle.FightScene_Model = require("Battle.Sce.FightScene_Model")
Battle.Bullet_Model = require("Battle.Blt.Bullet_Model")
Battle.WorldSceneBase_Model = require("Battle.Sce.WorldSceneBase_Model")
Battle.Player_Model = require("Battle.Ply.Player_Model")

Battle.ClassPathUtil = require("Battle.Tool.ClassPathUtil")
Battle.ClassPathUtil:init()
WRandom = require("Battle.Tool.WRandom")
StateSoundManager = require("Battle.SM.Anim.StateSoundManager")

VectorHelper = require("Battle.Tool.VectorHelper")
FixVector3 = require("Battle.Tool.FixVector3")
FixQuaternion = require("Battle.Tool.FixQuaternion")
BufWork_Model = require("Battle.Buf.BufWork_Model")
SkillFeatures_Model = require("Battle.Ply.SkillFeatures.SkillFeatures_Model")
SkillSkyStar = require("Battle.Ply.SkillSkyStar.SkillSkyStar")
SkillResonance = require("Battle.Ply.SkillResonance.SkillResonance")
Mystic = require("Battle.Ply.Mystic.Mystic")
PlayerTrait = require("Battle.Ply.Trait.PlayerTrait")
TimeTools = require("Battle.Tool.TimeTools")
TimeTools:init()
--
BattleTool = require("Battle.Tool.BattleTool")
SelectTargetTool = require("Battle.Tool.SelectTargetTool")
SelectTargetTool:init();
SelectTargetUtil = require("Battle.Tool.SelectTargetUtil")


if GameVersionConfig.IS_SERVER == false then
	--战斗相关 视图
	TimeManager_View = require("BattleView.Tool.TimeManager_View")
	Battle.SceneGuide_View = require("BattleView.Sce.Guide.SceneGuide_View")
	Battle.GuideModeBase_View = require("BattleView.Sce.Guide.GuideModeBase_View")
	Battle.Scene_View = require("BattleView.Sce.Scene_View")
	Battle.SceneArrayBase_View = require("BattleView.Sce.SceneArrayBase_View")
	Battle.FightScene_View = require("BattleView.Sce.FightScene_View")
	Battle.Bullet_View = require("BattleView.Blt.Bullet_View")
	Battle.WorldSceneBase_View = require("BattleView.Sce.WorldSceneBase_View")
	Battle.Player_View = require("BattleView.Ply.Player_View")
	BufWork_View = require("BattleView.Buf.BufWork_View")
	SkillFeatures_View = require("BattleView.Ply.SkillFeatures.SkillFeatures_View")
	PlayerHeadUI_View = require("BattleView.Ply.HeadUI.PlayerHeadUI_View")

	SelectTargetTool_View = require("BattleView.Tool.SelectTargetTool_View")
	SelectTargetTool_View:init();
end
