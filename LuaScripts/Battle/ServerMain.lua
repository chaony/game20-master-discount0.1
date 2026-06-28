--
-- Created by IntelliJ IDEA.
-- User: kongliang
-- Date: 2020/1/17
-- Time: 3:33 下午
-- To change this template use File | Settings | File Templates.
--


-- 初始化LGame环境
function initGameEnv(data)
    GameVersionConfig = require("Battle.GameVersionConfig")
    GameVersionConfig.IS_SERVER = data.IS_SERVER
    GameVersionConfig.OPEN_BATTLE_LOG = data.OPEN_BATTLE_LOG
    GameVersionConfig.Debug = data.Debug
    GameVersionConfig.Profile = data.Profile
    GameVersionConfig.LuaScriptsPath = data.LuaScriptsPath
    GameVersionConfig.USE_LOCAL_BATTLE_DATA = data.USE_LOCAL_BATTLE_DATA
    GameVersionConfig.BATTLE_LOG_PATH = data.BATTLE_LOG_PATH  -- 后端要求加入此代码

    ConfigManager = require("Battle.DataCenter.ServerConfigManager")
    ConfigManager:init()
end


-- 导入模块
function importModule()
    require("Battle.Init")
    SocketTools = require("Battle.Tool.SocketTools")
end


function preLoad()
    SceneManager:preLoad()

    if GameVersionConfig.Profile == true then
        mri = require("Battle.Framework.Commom.MemoryReferenceInfo")
        mri.m_cConfig.m_bAllMemoryRefFileAddTime = false

        collectgarbage("collect")
        mri.m_cMethods.DumpMemorySnapshot(GameVersionConfig.LuaScriptsPath, "1-Before", -1)
    end
end


function printData(data)
    Logger.log(data, "print data--->")
end


-- 打印Lua环境
function printLuaEnv()
    print(_VERSION, (jit and jit.version or 'no jit'))
end


function cmsgpackPack(data)
    local cmsgpack = require("cmsgpack")
    local pack_data = cmsgpack.pack(data)
    return pack_data
end


-- 开始战斗
function startBattle(data)
    --     Logger.log(data, "startBattle --->")
    local sceneManager = require("Battle.Sce.SceneManager")

    local t0 = nil
    local socket = nil
    if data.useTime then
        socket = require("socket")
        t0 = socket.gettime()
    end
    local battleResult = sceneManager:serverStart(data)
    if data.useTime then
        local t1 = socket.gettime()
        battleResult.useTime = t1-t0
    end
    EventDispatcher:resetAllList()
    return battleResult
end

-- 结束profile
function endProfile()
    if GameVersionConfig.Profile == true then
        collectgarbage("collect")
        mri.m_cMethods.DumpMemorySnapshot(GameVersionConfig.LuaScriptsPath, "1-After", -1)
    end
end
