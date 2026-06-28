------------------- ResourceUtil

local M = {}

local __PoolManager = CS.wt.framework.PoolManager.Inst
local __SpriteAtlasHelper = CS.wt.framework.SpriteAtlasHelper
local __ResourcesHelper = CS.wt.framework.ResourcesHelper
local __AssetLoaderHelper = CS.wt.framework.AssetLoaderHelper.Inst
local __AssetBundleHelper = nil;
local __LoaderUpdate = CS.wt.framework.LoaderUpdate.Inst
--是否使用Bundle
local useAssetBundle = __AssetLoaderHelper.isUseBundle
if useAssetBundle then
    __AssetBundleHelper = CS.wt.framework.AssetBundleHelper.Inst
end


function M:LoadGameGloballConfig()
    return __ResourcesHelper.LoadGameGloballConfig()
end

function M:GetUIItem(name, parent, ab_name)
    if useAssetBundle then
        return __PoolManager:GetItem(name, parent, string.lower(ab_name), true)
    else
        return __PoolManager:GetItemFromRes("UI/" .. name, parent, string.lower(ab_name))
    end
end


function M:GetUIEffectItem(name, parent, ab_name, pos)
    if ab_name == nil then
        local names = string.split(name, "/")
        if #names > 1 then
            ab_name = "fxui_" .. names[1]
        else
            Logger.logError("文件路径结构错误，无法生成ab_name ---- " .. name)
            return
        end
    end
    pos = pos or Vector3.zero
    local effect = nil
    if useAssetBundle then
        effect = __PoolManager:GetItem(name, parent, string.lower(ab_name), true)
        
    else
        effect = __PoolManager:GetItemFromRes("FxUI/" .. name, parent, string.lower(ab_name))
    end
    if effect then
        effect.transform.localPosition = pos
    end
    return effect
end



-- pool_type 池的类型
-- common 通用的
-- hero   专门的英雄池
-- enemy  专门的敌人池 
function M:GetItem(name, parent, ab_name, AddRefCount)
    if useAssetBundle then
        if AddRefCount == nil then
            AddRefCount = false;
        end
        return __PoolManager:GetItem(name, parent, string.lower(ab_name), AddRefCount)
    else
        return __PoolManager:GetItemFromRes(name, parent, string.lower(ab_name))
    end
end

-- 异步加载池中物体
function M:GetItemAsync(name, parent, ab_name, loadFinish, addRefCount)
    if useAssetBundle then
        __PoolManager:GetItemAsync(name, parent, string.lower(ab_name), loadFinish, addRefCount);
    else
        __PoolManager:GetItemFromResAsync(name, parent, loadFinish);
    end
end

--清除掉整个bundle中的预制体
function M:UnLoadBundlePrefab( bundleName )
    __PoolManager:ClearBundleItems( bundleName )
    --__AssetLoaderHelper:UnLoadBundlePrefab(bundleName);
end


-- 卸载bundle
function M:UnLoadBundle(name, isForce)
    if useAssetBundle then
        __AssetBundleHelper:UnloadAssetBundleAsync(name, isForce);
    end
end

-- 加入卸载完成回调 
function M:AddUnLoadFinish( callback )
    local function finishCallFunc()
        if callback then
            callback()
        end
        self:UnLoadMemeroy()
        if __LoaderUpdate.SetMaxUnLoadObjCount ~= nil then
            __LoaderUpdate:SetMaxUnLoadObjCount(2)
        end
    end
    if useAssetBundle then
        --  战斗结束需要把延迟时间修改很短，否则等所有卸载完成才回调
        if __LoaderUpdate.SetMaxUnLoadObjCount ~= nil then
            __LoaderUpdate:SetMaxUnLoadObjCount(10)
        end
        __AssetBundleHelper:SetAllUnLoadingDelayTime(0.01)
        __AssetBundleHelper:AddUnLoadFinish(finishCallFunc)
    else
        finishCallFunc()
    end
end

-- 加入卸载完成回调 
function M:AddLoadFinishCallBack( callback )
    local function finishCallFunc()
        if callback then
            callback()
        end
    end
    if useAssetBundle then
        __AssetBundleHelper:AddLoadFinishCallBack(finishCallFunc)
    else
        finishCallFunc()
    end
end

-- 加入准备卸载队列
function M:AddReadyUnLoadBundle(name)
    if useAssetBundle then
        __AssetBundleHelper:AddReadyUnloadBundle(name);
    end
end

-- 加入取消卸载队列
function M:AddCancelUnloadBundle(name)
    if useAssetBundle then
        __AssetBundleHelper:AddCancelUnloadBundle(name);
    end
end

-- 加入不卸载列表
function M:AddNoUnLoadBundle(name, deleteBundleName, remove)
    if useAssetBundle then
        if remove == nil then
            remove = false;
        end
        if deleteBundleName == nil then
            deleteBundleName = "";
        end
        __AssetBundleHelper:AddNoUnLoadBundle(name, deleteBundleName, remove);
    end
end

-- 开始卸载
function M:StartUnLoadBundle()
    if useAssetBundle then
        __AssetBundleHelper:StartUnLoadBundle();
    end
end

function M:LoadBundleSync( bundleName, loadFinish)
    if useAssetBundle then
        __AssetBundleHelper:LoadAssetBundleSync(bundleName, loadFinish)
    else
        if loadFinish ~= nil then
            loadFinish();
        end
    end
end

--加载bundle
function M:LoadBundle( bundleName, loadFinish )
    if useAssetBundle then
        __AssetBundleHelper:LoadAssetBundleAsync(bundleName, loadFinish)
    else
        if loadFinish ~= nil then
            loadFinish();
        end
    end
end


function M:clearHeroItem( hero_name )
    if useAssetBundle then
        __PoolManager:ClearHeroItems(hero_name);
    end
end


function M:ReturnItem(obj)
    __PoolManager:ReturnItem(obj)
end


function M:DestroyInstance( inst, instName, bundleName )
    __AssetLoaderHelper:DestoryInstance( inst,instName, bundleName )
end

function M:Destory(assetName, bundleName)
    __AssetLoaderHelper:Destory( assetName, bundleName )
end


function M:ClearItem()
    __PoolManager:ClearItem()
end

function M:LoadFont(name, ab_name)
    return __ResourcesHelper.LoadFont(name, string.lower(ab_name))
end

function M:LoadUIGameObject(name, pos, parent)
    if useAssetBundle then
        return __ResourcesHelper.LoadUIGameObject(name, pos, parent)
    else
        return __ResourcesHelper.LoadFromRes("UI/" .. name, pos, parent)
    end
end

--tip:这个方法是异步的
--evt:加载结束时调用的方法 会返回 scene_name,flag
--flag: 自定义回调标记
function M:LoadScene(scene_name, evt, flag)
    __ResourcesHelper.LoadScene(scene_name, evt, flag)
end


function M:HasGameObject(name, ab_name)
    if useAssetBundle then
        return __ResourcesHelper.hasGameObject(name, string.lower(ab_name))
    else
        return __ResourcesHelper.hasGameObjectFromRes(name, string.lower(ab_name))
    end
end

--[[
    atlas_name 和 ab 一致
]]
function M:GetSprite(name, atlas_name)
    if useAssetBundle then
        return __SpriteAtlasHelper.GetSprite(name, atlas_name, useAssetBundle)
    else
        return __SpriteAtlasHelper.GetSprite(name, "Atlas/"..atlas_name, useAssetBundle)
    end
end

function M:GetSk(name, ab_name)
    return __ResourcesHelper.GetSk("RoleSpine/" .. name, string.lower(ab_name))
end

function M:LoadSprite(name, ab_name)
    return __ResourcesHelper.LoadSprite(name, string.lower(ab_name))
end

function  M:LoadAllSprite(name, child)
    local sprite = __ResourcesHelper.LoadMultipleSpriteFromRes(name, child)
    return sprite
end

function M:LoadRole3d(prefab_name, parent)
    local name_path = string.split(prefab_name,"/")
    local name1 = name_path[1]
    local name = name_path[2]
    local ab_name = "role3d_" .. string.lower(name1)
    local obj = self:GetItem( "Role3d/".. name1 .. "/" .. name, parent, ab_name, false)
    return obj, ab_name
end

--异步加载人物
function M:LoadRole3dAsync(prefab_name, parent, loadFinish, addRefCount)
    local name_path = string.split(prefab_name,"/")
    local name1 = name_path[1]
    local name = name_path[2]
    if addRefCount == nil then
        addRefCount = false
    end
    self:GetItemAsync( "Role3d/".. name1 .. "/" .. name, parent, "role3d_" .. string.lower(name1), loadFinish, addRefCount)
end


function M:LoadRole3dShow(prefab_name, parent)
    local name_path = string.split(prefab_name,"/")
    local name1 = name_path[1]
    local name = name_path[2]
    if name == nil then
        name = prefab_name;
    end
    local obj = self:GetItem( "Role3d/".. name1 .. "/" .. name.."Show", parent, "role3d_" .. string.lower(name1))
    return obj
end


function M:LoadRole3dEffect(player_name,prefab_name, parent)
    local effect = self:LoadCommonEffect(prefab_name, parent)
    if effect == nil then
        local assetName = "Fx/"..player_name.."/"..prefab_name
        local bundleName = "fx_"..string.lower(player_name);
        effect = self:GetItem(assetName, parent, bundleName, false )
        if __PoolManager.AddActive ~= nil then
            __PoolManager:AddActive(effect,assetName,bundleName);
        else
            self:addActive(effect,assetName,bundleName);
        end
    end
    return effect
end

--加入到激活列表
function M:addActive(effect,assetName,bundleName)
    if not IsNull(effect) then
        local name = CS.PathManager.GetAssetName(assetName);
        local item = __PoolManager:GetPoolItem(name, bundleName);
        if not IsNull(item) then
            item:AddActiveObj(effect);
        end
    end
end


function M:LoadRole3dBulletAsync(player_name, prefab_name, parent, loadFinish)
    local prefabName = "Fx/".. player_name .. "/"..prefab_name;
    local ab_name = "fx_" .. string.lower(player_name);
    self:GetItemAsync( prefabName, parent, ab_name, loadFinish, false)
end

function M:LoadCommonEffectAsync(prefab_name, parent,loadFinish)
    self:GetItemAsync("CommonEffect/"..prefab_name, parent, "commoneffect",loadFinish, false )
end


function M:LoadCommonEffect(prefab_name, parent)
    local effect = nil
    effect = self:GetItem("CommonEffect/"..prefab_name, parent, "commoneffect", false )
    return effect
end

function M:LoadCommonAsync(prefab_name, parent, loadFinish )
    self:GetItemAsync("Common/"..prefab_name, parent, "common",loadFinish  )
end


function M:LoadCommon(prefab_name, parent)
    local effect = nil
    effect = self:GetItem("Common/"..prefab_name, parent, "common" )
    return effect
end

function M:LoadRoleSound(name)
    if useAssetBundle then
        __ResourcesHelper.LoadRoleSound(name)
    else
        __ResourcesHelper.LoadRoleSoundRes(name)
    end
end

function M:UnLoadRoleSound(name)
    if useAssetBundle then
        __ResourcesHelper.UnLoadRoleSound(name)
    else
        __ResourcesHelper.UnLoadRoleSoundRes(name)
    end
end

function M:LoadCurves(name, callback)
    if useAssetBundle then
        __ResourcesHelper.LoadShakeCurve("role3d_"..string.lower(name), callback, false)
    else
        __ResourcesHelper.LoadShakeCurveRes(name, callback)
    end
end

function M:LoadConfigObject(name, callback)
    if useAssetBundle then
        __ResourcesHelper.LoadConfigObject(name, callback, false)
    else
        __ResourcesHelper.LoadConfigObjectRes(name, callback)
    end
end

function M:LoadMaterial(name, callback)
    if useAssetBundle then
        __ResourcesHelper.LoadMaterial(name, callback)
    else
        __ResourcesHelper.LoadMaterialRes(name, callback)
    end
end

function M:LoadRoleCV(name)

    if useAssetBundle then
        __ResourcesHelper.LoadRoleCV(name)
    else
        __ResourcesHelper.LoadRoleCVRes(name)
    end
end

function M:UnLoadRoleCV(name)
    if useAssetBundle then
        __ResourcesHelper.UnLoadRoleCV(name)
    else
        __ResourcesHelper.UnLoadRoleCVRes(name)
    end
end

function M:LoadBank(name)

    if useAssetBundle then
        __ResourcesHelper.LoadBank(name)
    else
        __ResourcesHelper.LoadBankRes(name)
    end
end

function M:UnLoadBank(name)
    if useAssetBundle then
        __ResourcesHelper.UnLoadBank(name)
    else
        __ResourcesHelper.UnLoadBankRes(name)
    end
end

function M:createMaterial(name)
    return __ResourcesHelper.CreateMaterial(name)
end

function M:spriteAtlasRealClear()
    local print_log = GameVersionConfig and GameVersionConfig.Debug
    __SpriteAtlasHelper.RealClear(print_log)
end

function M:LoadAssetAllAsync(bundleName, callBack, loadProgress )
    if useAssetBundle then
        __AssetLoaderHelper:LoadAssetAllAsync(string.lower(bundleName), callBack, loadProgress)
    else
        callBack()
    end
end

function M:PreLoadAssetAllAsync(bundleName, callBack, loadProgress)
    if useAssetBundle then
        __AssetLoaderHelper:PreLoadAssetAllAsync(string.lower(bundleName), callBack, loadProgress)
    else
        callBack()
    end
end

function M:LoadAtlasAsync(bundleName, callBack)
    __SpriteAtlasHelper.LoadSpriteAtlasAnsyc(string.lower(bundleName), callBack)
end

-- 加载Multiple单个图片
function M:LoadMultipleSprites(path_name)
    if path_name then
        if useAssetBundle then
            local ab_name = string.gsub(path_name, "/", "_")
            if __SpriteAtlasHelper.LoadMultipleSpriteUseBundle then
                return __SpriteAtlasHelper.LoadMultipleSpriteUseBundle(string.lower(ab_name))
            else
                return nil
            end
        else
            if __SpriteAtlasHelper.LoadMultipleSpriteUseRes then
                return __SpriteAtlasHelper.LoadMultipleSpriteUseRes(path_name)
            else
                return nil
            end
        end
    end
end

function M:HasObject(name, bundleName)
    if useAssetBundle then
        return __PoolManager:HasObject(name, bundleName);
    end
    return false;
end


function M:HasBundle(bundleName)
    if useAssetBundle then
        local abObj = __AssetBundleHelper:GetAssetBundleObjectFromCache(bundleName);
        if abObj ~= nil then
            return true
        end
    end
    return false;
end

function M:UnLoadMemeroy()
    __ResourcesHelper.UnLoadMemeroy()
end

function M:luaGCStop()
    collectgarbage("stop")
end

function M:luaGCRestart()
    collectgarbage("restart")
end

function M:luaGCStep(n)
    local ret_step = collectgarbage("step", n)
    Logger.logAlways(ret_step, "lua step return value : ")
end

function M:printLuaTotalMem()
    local count = collectgarbage("count") -- 以 KB 为单位
    local men_str = string.format("%0.2fMB", count/1024)
    Logger.logAlways(men_str, "lua total memory : ")
end

function M:printMonoTotalMem()
    if __ResourcesHelper.GetMonoUsedSize then
        local count = __ResourcesHelper.GetMonoUsedSize() -- 以 Bytes 为单位
        local men_str = string.format("%0.2fMB", count/1048576)
        Logger.logAlways(men_str, "mono total memory : ")
    end
end

local cur_lan = Language:getCurLanguage()
M.m_texture_path = "Texture/" .. cur_lan
M.m_lan_atlas = "language_" .. cur_lan

function M:getTexturePath()
    return self.m_texture_path
end

function M:getLanAtlas()
    return self.m_lan_atlas
end

return M
