Vector2		= require("Framework.UnityEngine.Vector2")
Vector4		= require("Framework.UnityEngine.Vector4")
Quaternion	= require("Framework.UnityEngine.Quaternion")
Color		= require("Framework.UnityEngine.Color")
ColorHexHelper		= require("Framework.UnityEngine.ColorHexHelper")
Ray			= require("Framework.UnityEngine.Ray")
Bounds		= require("Framework.UnityEngine.Bounds")
RaycastHit	= require("Framework.UnityEngine.RaycastHit")
Touch		= require("Framework.UnityEngine.Touch")
LayerMask	= require("Framework.UnityEngine.LayerMask")
Plane		= require("Framework.UnityEngine.Plane")
Time		= require("Framework.UnityEngine.Time")
require("Framework.UnityEngine.Object")

Utf8 = require("Framework.Commom.Utf8")
TimeUtil = require("Framework.Commom.TimeUtil")

if GameVersionConfig.IS_SERVER == false then
	LuaCSharpArr = require("Framework.Commom.LuaCSharpArr")
	UIUtil = require("Framework.Commom.UIUtil")
	LuaBehaviourUtil = require("Framework.Commom.LuaBehaviourUtil")
	LikeOO = {}
	LikeOO.OOMsgList = require("Framework.LikeOO.OOMsgList")
	LikeOO.OOStack = require("Framework.LikeOO.OOStack")
	LikeOO.OOControlBase = require("Framework.LikeOO.OOControlBase")
	LikeOO.OODataBase = require("Framework.LikeOO.OODataBase")
	LikeOO.OOViewBase = require("Framework.LikeOO.OOViewBase")
	LikeOO.OOPopBase = require("Framework.LikeOO.OOPopBase")
	LikeOO.OOSceneBase = require("Framework.LikeOO.OOSceneBase")
	LikeOO.OOUIbase = require("Framework.LikeOO.OOUIbase")
	LikeOO.OOGuideBase = require("Framework.LikeOO.OOGuideBase")
	LikeOO.Map2DControl = require("UI.WorldMap.Map2D.Map2DControl").new()
	LikeOO.BattleTalkControl = require("UI.Pops.BattleTalkPop.BattleTalkControl").new()
	LikeOO.NewMap2DControl = require("UI.WorldMapNew.Map2D.Map2DControl").new()
end

function LuaReload( moduleName )
    package.loaded[moduleName] = nil
    return require(moduleName)
end

function CustomRequire( moduleName )
	if GameVersionConfig.LUA_RELOAD_DEBUG then
		return LuaReload(moduleName)
	else
		return require(moduleName)
	end
end