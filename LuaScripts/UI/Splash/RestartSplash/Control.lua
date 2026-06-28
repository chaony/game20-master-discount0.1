local M = class("RestartSplashControl",LikeOO.OOControlBase)

--- 页面不可返回
M.m_needBack = false

local __ResourcesHelper = CS.wt.framework.ResourcesHelper
local __SpriteAtlasHelper = CS.wt.framework.SpriteAtlasHelper
local __PoolManager = CS.wt.framework.PoolManager

local _reload_white_map = {
    _G = true,
    coroutine = true,
    io = true,
    table = true,
    string = true,
    debug = true,
    utf8 = true,
    math = true,
    package = true,
    os = true,
}

function M:onEnter()
    audio:SendEvtUI("Stop_Music")
    if SceneManager ~= nil and SceneManager.curScene ~= nil then
        SceneManager.curScene:destroy();
        SceneManager:destroy()
        SceneManager.curScene = nil;
    end
    self:changeScene()
end

function M:changeScene()
    ResourceUtil:LoadScene("empty",function (scene_name, flag)
        GameMain.restart_flag = true
        if SceneManager ~= nil then
            SceneManager.start = false;
        end
        self:restart()
    end,"1")
end

function M:restart()
    EventDispatcher:registerTimeEvent("delay_restart_time",function()
        if GameMain.screen_effect then
            GameMain.screen_effect:destroy()
            GameMain.screen_effect = nil
        end
        if static_rootControl then
            static_rootControl:destroy()
            static_rootControl = nil
        end
        ChatUtil:closeSocket()
        UserDataManager:delete()
        ConfigManager:delete()
        for k,v in pairs(package.loaded) do
            if _reload_white_map[k] == nil then
                package.loaded[k] = nil
            end
        end

        __PoolManager.Inst:ClearItem()
        __SpriteAtlasHelper.reset()
        local function finishCallFunc()
            self:clearFinish()
        end
        if __ResourcesHelper.useAssetBundle then
            local function loadFinish()
                __ResourcesHelper.cleanBundle(false)
                finishCallFunc()
            end
            CS.wt.framework.AssetBundleHelper.Inst:AddLoadFinishCallBack(loadFinish)
        else
            finishCallFunc()
        end
    end,1,1)
end

function M:clearFinish()
    if __ResourcesHelper.useAssetBundle then
        CS.wt.framework.AssetBundleHelper.Inst:LoadMainfest()
        __ResourcesHelper.WarmupAllShaders()
    else
        __ResourcesHelper.WarmupAllShadersRes()
    end
    GameMain.start()
end

return M
	