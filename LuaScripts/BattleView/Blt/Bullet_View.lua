--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-04-30 13:43:54
]]
---@class Bullet_View : ViewBase
local M = class("Bullet_View",Battle.ViewBase)

function M:init( player,effectData, model )
    self.model = model;
    self.player = player;
    self.effectData = effectData;
    self.prefabName = self.effectData["prefab"]
    self.delayBoomEffect = {}
    self.parDestroyTime = 0;

    --受击特效数据
    self.hitEffectList = {}
    self.bombEffectList = {}
    self.dalayBoomEffectList = {}
    if self.effectData ~= nil and self.effectData["prefabList"] ~= nil then
        for k,v in pairs(self.effectData["prefabList"]) do
            if v.type == "injureHit" or v.type == "critHit" then
                table.insert(self.hitEffectList, v)
            elseif v.type == "bombHit" then
                table.insert(self.bombEffectList, v)
            elseif v.type == "dalayBoomHit" then
                table.insert(self.dalayBoomEffectList, v)
            end
        end
    end

    --父级
    self.parentName = self.effectData["parent"]
    --生命周期
    self.lifeTime = self.effectData["lifeTime"]
    self.isDestroy = false
    self.speed = tonumber(self.effectData["speed"])
    local pool_type = "hero";
    if self.player.camp == -1 then
        pool_type = "enemy";
    end
    self.bulletState = 0;
    --GameMain.addUpdate("Bullet_View_Update",handler(self,self.BulletViewUpdate))
    --数据层和视图层，同步位置
    self:addEventListener_Local(Battle.EventType.MV_BulletModelSyncPosition, {self, self.MV_BulletModelSyncPosition});
    --数据层和视图层，同步方向
    self:addEventListener_Local(Battle.EventType.MV_BulletModelSyncDir, {self, self.MV_BulletModelSyncDir});
    --数据层 通知 视图层 播放特效
    self:addEventListener_Local(Battle.EventType.MV_BulletModelPlayEffect, {self, self.MV_BulletModelPlayEffect})
    --数据层 通知 视图层 子弹销毁
    self:addEventListener_Local(Battle.EventType.MV_BulletModelDead, {self, self.MV_BulletModelDead})
    --数据层 通知 视图层 我们绑定成功
    self:addEventListener_Local(Battle.EventType.MV_BulletModelBandFinish, {self, self.MV_BulletModelBandFinish})
    --数据层 通知 视图层 子弹射击
    self:addEventListener_Local(Battle.EventType.MV_BulletModelShoot,{self, self.MV_BulletModelShoot})
    --同步敌人
    self:addEventListener_Local(Battle.EventType.MV_BulletModelSetEnemy,{self,self.MV_BulletModelSetEnemy})
    --同步状态
    self:addEventListener_Local(Battle.EventType.MV_BulletModelSyncState, {self,self.MV_BulletModelSyncState})
end

--同步状态 
function M:MV_BulletModelSyncState()
    --同步子弹状态
    self.bulletState = self.model:getState();
end

--同步我的敌人
function M:MV_BulletModelSetEnemy( eventName, data )
    local enemy_model = self.model:get_enemy();
    if enemy_model ~= nil then
        self.enemy = self.player.plyMgr:GetPlayerViewByModel(enemy_model);
    end
end

-- 加载完成
function M:loadFinish()

end

function M:changeToUnity( value ) 
    local vec = Vector3(0,0,0);
    vec.x = value.x;
    vec.y = value.y;
    vec.z = value.z;
    return vec;
end



function M:MV_BulletModelUpdate(eventName,data)
    self:update(data.dt)
end

function M:MV_BulletModelShoot(eventName,data)
    --if self.luaViewHelper ~= nil then
    --    self.luaViewHelper:SetStartTransform( self:changeToUnity(self.position), self:changeToUnity(self.bulletDir) );
    --end
end

--Model和View 绑定完成
function M:MV_BulletModelBandFinish(eventName,data)
    --if self.luaViewHelper ~= nil then
    --    self.luaViewHelper:SetStartTransform( self:changeToUnity(self.position), self:changeToUnity(self.bulletDir) );
    --end
    --1~3人物位置信息
    --4~6人物旋转信息
    --7 人物移动速度
    --8 是否直接设置位置
    --9 人物旋转速度
    --10 是否直接设置旋转
    ResourceUtil:LoadRole3dBulletAsync(self.player.prefabRoot, self.prefabName, nil, function(obj)
        self.obj = obj;
        if self.isDestroy then
            self:destroy()
        else
            if self.obj ~= nil then
                self.luaViewHelper = self.obj:GetComponent("LuaViewHelper")
                if self.luaViewHelper ~= nil then

                    self.mesh = self.luaViewHelper.mesh
                    self.par = self.luaViewHelper.par

                    self.helperArr = LuaCSharpArr.New(10)
                    local CSharpAccess = self.helperArr:GetCSharpAccess()
                    self.luaViewHelper:PinTable(CSharpAccess)
                    --子弹旋转速度
                    self.helperArr[9] = 90
                    --子弹移动速度
                    self.helperArr[7] = self.speed;
                    --向Unity 同步一次位置
                    self:syncPosToUnity(true);
                    --向Unity 同步一次方向
                    self:syncDirToUnity(true)
                    -- 销毁时间
                    self.parDestroyTime = self.luaViewHelper.parDestroyTime
                    -- 射击
                    self.luaViewHelper:Shoot()
                    -- 加载完成设定位置
                    if self.position ~= nil and self.bulletDir ~= nil then
                        self.luaViewHelper:SetStartTransform( self:changeToUnity(self.position), self:changeToUnity(self.bulletDir) );
                    end
                    -- 加载完成
                    self:loadFinish()
                else
                    Logger.logError(" 子弹 "..obj.name.." 没有 LuaViewHelper ")
                end
            end
        end
    end)
end


function M:BulletViewUpdate(dt, unsdt) 
    self:update(dt,unsdt);
end

-- 子弹死亡了
function M:MV_BulletModelDead(eventName, data) 
    self:dead();
end

-- 子弹播放被攻击特效
function M:MV_BulletModelPlayEffect(eventName, data)
    if SceneManager.curScene.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.LEGEND then
        if data.type == 1 then
            --播放攻击到特效
            self:playHitEffect();
        elseif data.type == 2 then
            --播放延迟爆炸特效
            self:playDelayBoomEffect();
        elseif data.type == 3 then
            --播放延迟爆炸特效
            self:clearDelayBoomEffect();
        end
    end
end

-- 子弹同步位置
function M:MV_BulletModelSyncPosition(eventName, data)
    -- 是否强制设定位置
    local forcePosition = self.model:get_positionForce();
    -- 定点数位置
    local position = self.model:get_position()
    --记录子弹的位置
    if self.position == nil then
        self.position = Vector3(0,0,0)
    end
    self.position.x = GlobalTools:ToFloat(position.x)
    self.position.y = GlobalTools:ToFloat(position.y)
    self.position.z = GlobalTools:ToFloat(position.z)
    
    -- 设定 Unity 位置
    self:syncPosToUnity(forcePosition);
end

-- 子弹同步方向
function M:MV_BulletModelSyncDir(eventName, data)
    -- 是否强制设定位置
    local forceDir = self.model:get_dirForce();
    -- 定点数方向
    local dir = self.model:get_dir()
    if self.bulletDir == nil then
        self.bulletDir = Vector3(0,0,0)
    end
    self.bulletDir.x = GlobalTools:ToFloat(dir.x)
    self.bulletDir.y = GlobalTools:ToFloat(dir.y)
    self.bulletDir.z = GlobalTools:ToFloat(dir.z)
    -- 设定 Unity 方向
    self:syncDirToUnity(forceDir)
end


-- 同步到Unity端
function M:syncPosToUnity(force)
    if self.helperArr ~= nil then
        --同步位置
        if self.position ~= nil then
            self.helperArr[1] = self.position.x;
            self.helperArr[2] = self.position.y;
            self.helperArr[3] = self.position.z;
        end
        --是否强制设置位置
        if force ~= nil and force == true then
            self.helperArr[8] = 1
        else
            self.helperArr[8] = 0
        end
    end
end

function M:syncDirToUnity(force)
    if self.helperArr ~= nil then
        --同步方向
        if self.bulletDir ~= nil then
            self.helperArr[4] = self.bulletDir.x
            self.helperArr[5] = self.bulletDir.y
            self.helperArr[6] = self.bulletDir.z
        end
        --是否强制设置方向
        if force ~= nil and force == true then
            self.helperArr[10] = 1
        else
            self.helperArr[10] = 0
        end
    end
end

-- 子弹死亡
function M:dead()
    --延迟0.2秒销毁，保证和表现一致
    self.isDestroy = true
    local delayTimebySpeed = self.speed / 20 * 0.1;
    TimeTools:delayTimeUnity(delayTimebySpeed, function()
        if self.mesh ~= nil and IsNull(self.mesh) == false then
            self.mesh:SetActive(false);
        end
    end)
    TimeTools:delayTimeUnity(self.parDestroyTime + delayTimebySpeed, function()
        self:destroy();
        self.player.bulletMgr:removeBullet(self.model)
    end)
end

--销毁子弹
function M:destroy()
    if self.obj ~= nil and IsNull(self.obj) == false then
        ResourceUtil:ReturnItem(self.obj);
        self.obj = nil
    else
        --Logger.logError(" 视图销毁预制体失败 ~！！！！！！！！！！！！！ " )
    end
    --GameMain.removeUpdate("Bullet_View_Update")
end

--更新
function M:update(dt)
    if self.isDestroy then
        self.parDestroyTime = self.parDestroyTime - dt
        if self.parDestroyTime <= 0 then
            self:destroy()
            self.player.bulletMgr:removeBullet(self.model)
        end
    end
    if self.player == nil or IsNull(self.player.obj) then
        self:destroy()
        self.player.bulletMgr:removeBullet(self.model)
    end
end

--特殊效果处理
function M:special(player,attackData)
    if player ~= nil then
        if player.camp == self.player.camp then
            if self.data["SpecialParam"] == "addBlood" then
                if self.data.specialAudio ~= nil and self.data.specialAudio ~= "" then
                    StateSoundManager:playSkillSound(self.data.specialAudio, self.player)
                end

                local effect = self.data["Effect"]
                for i = 1, table.nums(effect) do
                    local effect_data = effect[i]
                    local effectData = {}

                    effectData["prefab"] = effect_data["prefab"]
                    effectData["autodestoryTime"] = effect_data["effectDestroyTime"]
                    effectData["isPutUpInParent"] = effect_data["isParent"]
                    effectData["parent"] = effect_data["effectParent"]

                    local prefabTrans = {}
                    prefabTrans["useUserSet"] = true

                    prefabTrans["position"] = {
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
                    player:playEffect( effectData,  self.player, self.player )
                end
            end
        end
    end
end


--播放爆炸特效
function M:playHitEffect()
    for k,v in ipairs(self.bombEffectList) do
        local effectData = {}
        effectData["prefab"] = v.prefab
        effectData["isPutUpInParent"] = false
        effectData["autodestoryTime"] = v.autoDestroy
        local prefabTrans = {}
        effectData["prefabTrans"] = prefabTrans
        effectData["parent"] = v.parent
        if self.minHitPlayer ~= nil and self.shootFixPoint then
            if self.minHitPlayer ~= nil then
                self.minHitPlayer:playInjureEffect( effectData, self.minHitPlayer, self.player )
            end
        else
            effectData["isPutUpInParent"] = false
            effectData["directionType"] = "world"
            effectData["scaleType"] = "world"
            effectData["positionType"] = "worldFix"

            prefabTrans["useUserSet"] = true
            local pos = self.model:get_position():toVector3()
            prefabTrans["position"] = {pos.x + v.position.x, pos.y + v.position.y, pos.z + v.position.z}
            prefabTrans["rotation"] = {v.eulerAngle.x,v.eulerAngle.y,v.eulerAngle.z}
            prefabTrans["scale"] = {v.scale.x,v.scale.y,v.scale.z}
            if self.player ~= nil then
                self.player:playEffect( effectData, self.player , self.player )
            end
        end
    end
end

--播放爆炸特效
function M:playDelayBoomEffect()
    for k,v in ipairs(self.dalayBoomEffectList) do
        local effectData = {}
        effectData["prefab"] = v.prefab
        effectData["isPutUpInParent"] = false
        effectData["autodestoryTime"] = v.autoDestroy
        local prefabTrans = {}
        effectData["prefabTrans"] = prefabTrans
        effectData["parent"] = v.parent

        effectData["isPutUpInParent"] = false
        effectData["directionType"] = "world"
        effectData["scaleType"] = "world"
        effectData["positionType"] = "worldFix"

        prefabTrans["useUserSet"] = true
        local pos = self.position
        prefabTrans["position"] = {pos.x + v.position.x, pos.y + v.position.y, pos.z + v.position.z}
        prefabTrans["rotation"] = {v.eulerAngle.x,v.eulerAngle.y,v.eulerAngle.z}
        prefabTrans["scale"] = {v.scale.x,v.scale.y,v.scale.z}
        local effect = nil
        if self.player ~= nil then
            effect = self.player:playEffect( effectData, self.player , self.player )
        end

        
        
        if IsNull(effect) == false then
            table.insert(self.delayBoomEffect, effect)
        end
    end
end

--清除延迟爆炸特效
function M:clearDelayBoomEffect()
    if #self.delayBoomEffect > 0 then
        for k,v in ipairs(self.delayBoomEffect) do
            if IsNull(v.m_obj) == false then
                ResourceUtil:ReturnItem(v.m_obj)
            end
        end
        self.delayBoomEffect = {}
    end
end

return M;