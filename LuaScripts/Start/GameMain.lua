GameMain = {}

-- 重加载白名单
local LuaFileHelper = CS.wt.framework.LuaFileHelper.Inst

local _updateFunctionTab = {}
GameMain.enter_main_flag = false
GameMain.restart_flag = false
GameMain.download_game_resources = false

local __BundlesDir = "Bundles"
local __GameLocalDataDir = LuaFileHelper:GetReadAndWriteDir() .. "/" .. __BundlesDir

function GameMain.setGameVersion(file_name, value)
    LuaFileHelper:CreateFolderByFile(__GameLocalDataDir)
    value = value or ""
    local fs = LuaFileHelper:Open(__BundlesDir .. "/" .. file_name, 2)
    LuaFileHelper:WriteText(fs,tostring(value))
    LuaFileHelper:CloseStream(fs)
end

function GameMain.getGameVersion(file_name, default_value)
    if LuaFileHelper:FileExist(__BundlesDir .. "/" .. file_name, CS.wt.framework.LuaFileHelper.DirectoryType.ReadAndWritePath) then
        local game_version = LuaFileHelper:ReadAllText(__BundlesDir .. "/" .. file_name)
        return game_version
    end
    return default_value
end

function GameMain.start()
    GameMain.new_client = false
    GameMain.download_game_resources = false
    GameVersionConfig = require("Start.GameVersionConfig")
    if GameVersionConfig.IS_SERVER then
        local server = require("ServerMain")
        return;
    end
    U3DUtil = require("Util.U3DUtil")
    U3DUtil:init()
    
    --local client_verion = U3DUtil:PlayerPrefs_GetString("client_verion")
    local client_verion = GameMain.getGameVersion("client_verion", "")
    local old_client_verion = U3DUtil:PlayerPrefs_GetString("client_verion")
    if old_client_verion ~= nil and old_client_verion ~= "" then -- 兼容老版本
        client_verion = old_client_verion
        GameMain.setGameVersion("client_verion",tostring(old_client_verion))
        U3DUtil:PlayerPrefs_SetString("client_verion", "")
        U3DUtil:PlayerPrefs_Save()
    end
    print("SAVE_CLIENT_VERSION : ", client_verion, "CLIENT_VERSION : ", GameVersionConfig.CLIENT_VERSION, "GAME_RESOURCES_VERION : ", GameVersionConfig.GAME_RESOURCES_VERION)
    
    if client_verion ~= tostring(GameVersionConfig.CLIENT_VERSION) then--覆盖更新,删除老版本下载的资源
        -- TODO : 删除热更目录下的资源
        print("删除热更目录下的资源")
        LuaFileHelper:DeleteDir("Bundles", true)
        LuaFileHelper:DeleteDir("LuaScripts", true)
        LuaFileHelper:DeleteDir("mp4", true)
        LuaFileHelper:DeleteDir("Audio", true)
        LuaFileHelper:DeleteDir("tempZip", true)
        LuaFileHelper:DeleteFile("file_names.txt")
        --U3DUtil:PlayerPrefs_SetString("game_resources_verion",tostring(GameVersionConfig.GAME_RESOURCES_VERION))
        --U3DUtil:PlayerPrefs_SetString("client_verion",tostring(GameVersionConfig.CLIENT_VERSION))
        U3DUtil:PlayerPrefs_SetString("game_resources_verion", "")
        U3DUtil:PlayerPrefs_SetString("client_verion", "")
        GameMain.setGameVersion("game_resources_verion",tostring(GameVersionConfig.GAME_RESOURCES_VERION))
        GameMain.setGameVersion("client_verion",tostring(GameVersionConfig.CLIENT_VERSION))
        U3DUtil:PlayerPrefs_Save()
        if client_verion ~= nil and client_verion ~= "" then
            GameMain.new_client = true
        end
    end

    --GameVersionConfig.GAME_RESOURCES_VERION = U3DUtil:PlayerPrefs_GetString("game_resources_verion",GameVersionConfig.GAME_RESOURCES_VERION) or GameVersionConfig.GAME_RESOURCES_VERION
    local resources_version = GameMain.getGameVersion("game_resources_verion", "")
    local old_resources_version = U3DUtil:PlayerPrefs_GetString("game_resources_verion")
    if old_resources_version ~= nil and old_resources_version ~= "" then -- 兼容老版本
        resources_version = old_resources_version
        GameMain.setGameVersion("game_resources_verion",tostring(old_resources_version))
        U3DUtil:PlayerPrefs_SetString("game_resources_verion", "")
        U3DUtil:PlayerPrefs_Save()
    end
    if resources_version ~= nil and resources_version ~= "" then
        GameVersionConfig.GAME_RESOURCES_VERION = resources_version
    end
    print("old_client_verion : ", old_client_verion, "old_resources_version : ", old_resources_version, "current resources_version : ", GameVersionConfig.GAME_RESOURCES_VERION)
    
    WhalSDKUtil = require("Util.WhaleSdkHelper")
    WhalSDKUtil:OnGameLoadResource()
    WhalSDKUtil:OnGameLoadConfig()
    GameMain.init()
    Logger.log(LuaFileHelper:GetReadAndWritePath(), "LuaFileHelper:GetReadAndWritePath()-->")
    if GameVersionConfig.OPEN_SR_DEBUG then
        CS.LuaGameLaunch.Instance:OpenSRDebug()
    end
end

function GameMain.init()
    require("Start.Init")
    LODUtil = require("Util.LODUtil")
    _updateFunctionTab = {}
    if GameMain.new_client then
        GameMain.reStart()
        return
    end
    GameMain.initFont()

    SDKUtil:getPlatform(function()
        LikeOO.OOControlBase:openView("Login")
        --LikeOO.OOControlBase:openView("Splash")
        local screen_effect = require("UI.Common.ScreenClickEffect")
        GameMain.screen_effect = screen_effect.new(nil, {parent = static_root_node})
    end)
end

-- 初始化字体
function GameMain.initFont()
    U3DUtil:Set_Font();
end

-- 初始化声音
function GameMain.initSound()
    audio:init()
end

-- 初始化游戏画质,1底画质 2高画质
function GameMain.initPictureQuality()
    local flag = U3DUtil:PlayerPrefs_GetInt("picture_quality", 2)
    GameMain.setPictureQuality(flag)
end

-- 设置画质品质高低
function GameMain.setPictureQuality(flag)
    --CS.zmhx.PhoneHelper.SetUnAutoPhoneLevel(flag);
end

function GameMain.reStart()
    if static_rootControl then
        static_rootControl:closeAllViewPop()
        static_rootControl:openView("Splash.RestartSplash")
    else
        LikeOO.OOControlBase:openView("Splash.RestartSplash")
    end
end

function GameMain.update(dt, unsdt)
	for k,v in pairs(_updateFunctionTab) do
        if v.available then
            v.func(dt, unsdt)
        end
	end
    for k,v in pairs(_updateFunctionTab) do
        if not v.available then
            _updateFunctionTab[k] = nil
        end
    end

    if SceneManager ~= nil then
        SceneManager:update(dt, unsdt)
    end
    if TimeTools ~= nil then
        TimeTools:update_dt_unity(dt)
    end
end

function GameMain.fixedUpdate(fdt)
    if SceneManager ~= nil then
        --Logger.log(" fdt -------- >>>> [ "..fdt.." ]");
        SceneManager:fixedUpdate(fdt);
    end
end

function GameMain.lateUpdate(dt, unsdt)
    if SceneManager ~= nil then
        SceneManager:lateUpdate(dt, unsdt);
    end
end

function GameMain.onDestroy()
    
end

function GameMain.addUpdate(key, updateFunction)
    if not _updateFunctionTab[key] then
        _updateFunctionTab[key] = {name = key, func = updateFunction, available = true}
    else
        _updateFunctionTab[key].available = true;
        _updateFunctionTab[key].func = updateFunction
    end
end

function GameMain.removeUpdate(key)
    if _updateFunctionTab[key] then
        _updateFunctionTab[key].available = false
    end
end

function GameMain.removeAllUpdate()
    _updateFunctionTab = {}
end

function GameMain.hasUpdate(key)
    return _updateFunctionTab[key] ~= nil
end

function GameMain.onApplicationQuit()
    if Logger then
        Logger.log("OnApplicationQuit")
    end
end

local enter_background_time = os.time()

function GameMain.onApplicationFocus(focus)
    if Logger then
        Logger.log("OnApplicationFocus : " .. tostring(focus))
    end
    if EventDispatcher then
        EventDispatcher:dipatchEvent("onApplication", focus);
    end
    if SceneManager ~= nil then
        if focus == true then
            SceneManager.delayFrame = 3;
            local diff_time = os.time() - enter_background_time
            if EventDispatcher then
                EventDispatcher:addjustTimer(diff_time)
                EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.ON_APPLICATION_WAKE_UP, {total_time = diff_time})
            end
        else
            enter_background_time = os.time()
        end
        SceneManager.start = focus;
    end
end

function GameMain.luaExceptionError(mssage, stack_trace)
    if GameUtil then
        GameUtil:sendLuaError(mssage, stack_trace)
    end
end

return GameMain