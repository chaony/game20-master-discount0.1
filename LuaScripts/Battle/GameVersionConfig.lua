------------- GameVersionConfig
local DevelopRootPath = "C:\\Company\\zmhx-client\\"
local M = {
	BATTLE_LOG_PATH = DevelopRootPath .. "ResProject\\Assets\\StreamingAssets\\LuaScripts\\Battle\\Log\\";
	LUA_ROOT_PATH =   DevelopRootPath .. "ResProject\\Assets\\StreamingAssets\\";
	Debug = true,
	LUA_RELOAD_DEBUG = true,
	OPEN_BATTLE_LOG = false,
	IS_SERVER = true,
	USE_LOCAL_BATTLE_DATA = true, -- 是否使用本地战斗数据
}

return M