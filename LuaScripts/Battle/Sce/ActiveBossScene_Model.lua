--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:32:47
]]

--挂机场景
---@class ActiveBossScene_Model : SceneArrayBase_Model @
---@field super SceneArrayBase_Model @SceneArrayBase_Model
local M = class("ActiveBossScene_Model",Battle.SceneArrayBase_Model)

--初始化场景
function M:init()
    M.super.init(self)
    self.isNeedResetCamera = false;
end

--进入场景
function M:enter( data )
    self.m_mode = data.m_mode;
    self.m_status = "idle"

    self.world_boss= ConfigManager:getCfgByName("active_world_boss")
    local open_cfg = self.world_boss[data.m_open_id] or {}
    self.world_cfg = open_cfg[data.m_version] or {}
    if data and data.m_data and data.m_data.max_hp and data.m_data.last_damage then
        if data.m_data.last_damage >= data.m_data.max_hp then
            self.m_status = "die"
        end
    end

    self:setBossState(data.state);
    M.super.enter(self, data )
end

function M:getCurSceneName()
    self:createSceneConfig(109)
    return self.scene_info.resource;
end

function M:getCurSceneObjName()
    return "fightscene_data_w";
end

--子类重写
function M:getCurCameraInfoName()
    return self:getCurSceneName()
end


--boss场景的状态 
--1 表示显示状态 
--2 表示布阵战斗状态
function M:setBossState( state )
    self.bossState = state
end


--刷新状态 
function M:refreshState()
    if self.bossState == 1 then
        self:setBossDir(0)
    elseif self.bossState == 2 then
        self:setBossDir(1)
        StateSoundManager:playBGM(Battle.BattleGlobalConfig.BATTLE_MODE.WORLD_BOSS)
    end
end


function M:createEnemyFinish()
    M.super.createEnemyFinish(self)
    self:refreshState();
end

function M:setPlayerScale(ply, _showid)
    local ply_view_pool = SceneManager:getCurSceneView().plyMgr:GetPlayerViewByModel(ply)
    if ply_view_pool.obj == nil then
        ply.loadPlayerViewFinish = function(ply_view)
            if not IsNull(ply_view.body) then
                self:setBossViewScale(ply_view, _showid)
            end
        end
    else
        self:setBossViewScale(ply_view_pool, _showid)
    end
end

function M:setBossViewScale( view,_showid )
    local scale = view.body.transform.localScale
    local scele_value = 0.6;
    if _showid == 1 then
        scele_value = 0.6
    end
    scale.x = scele_value
    scale.y = scele_value
    scale.z = scele_value
    view.playerHelperArr[12] = -0.6
    view.body.transform.localScale = scale
end

function M:setBossAiStatus()
    local enemys = SceneManager.curScene.plyMgr:getPlayers(-1);
    for i=1,enemys.Count do
        local ply = enemys:get(i-1);
        if ply then
            local ply_view = SceneManager:getCurSceneView().plyMgr:GetPlayerViewByModel(ply)
            if ply_view ~= nil and ply_view.luaViewHelper ~= nil then
                ply_view.luaViewHelper:ShaderChange(LODUtil.lodLevel)
            end
            ply.animator:changeState(self.m_status)
            --ply.aiEngine:changeState(self.m_status)
        end
    end
end

function M:loadFinish( data )
    M.super.loadFinish(self,data);
    
    if self.battleCameraConfig.useCodeValue == "1" then
		self.useCodeValue = true;
	else
		self.useCodeValue = false;
	end

	local boss_zd_position = self.battleCameraConfig.boss_zd_position;
	local boss_zd_pos = Vector3( tonumber(boss_zd_position.x),tonumber(boss_zd_position.y),tonumber(boss_zd_position.z))
    
    local boss_zd_rotation = self.battleCameraConfig.boss_zd_rotation;
    local boss_zd_rot = Vector3( tonumber(boss_zd_rotation.x),tonumber(boss_zd_rotation.y),tonumber(boss_zd_rotation.z))
    
    local boss_bz_position = self.battleCameraConfig.boss_bz_position;
    local boss_bz_pos = Vector3( tonumber(boss_bz_position.x),tonumber(boss_bz_position.y),tonumber(boss_bz_position.z))
    
    local boss_bz_rotation = self.battleCameraConfig.boss_bz_rotation;
    local boss_bz_rot = Vector3( tonumber(boss_bz_rotation.x),tonumber(boss_bz_rotation.y),tonumber(boss_bz_rotation.z))
    
    local boss_zs_position = self.battleCameraConfig.boss_zs_position;
    local boss_zs_pos = Vector3( tonumber(boss_zs_position.x),tonumber(boss_zs_position.y),tonumber(boss_zs_position.z))
    
    local boss_zs_rotation = self.battleCameraConfig.boss_zs_rotation;
	local boss_zs_rot = Vector3( tonumber(boss_zs_rotation.x),tonumber(boss_zs_rotation.y),tonumber(boss_zs_rotation.z))

    self.camera_bz_pos = boss_bz_pos;
    self.camera_bz_rot = boss_bz_rot

    self.camera_zd_pos = boss_zd_pos;
    self.camera_zd_rot = boss_zd_rot

    self.cameraShowBossRot = boss_zs_rot
    self.cameraShowBoss = boss_zs_pos
    
    --SceneManager:getCurSceneView().cameraController.Camera_3D.transform.rotation = Quaternion.Euler(self.cameraShowBossRot.x, self.cameraShowBossRot.y, self.cameraShowBossRot.z);
    self.sceneObj = U3DUtil:GameObject_Find("prefabs")
    self.gameover = false;
    
    local battle_id = self.world_cfg.battle_id
    self:createEnemyTeam(battle_id, true, "stage_battle");
    CS.GameObjectClickMgr.Inst:Register("ClickObj",handler(self,self.clickObject))
    self:setBossAiStatus()
    
    static_rootControl:updateMsg("guide_check",nil,"Activities.WorldBoss")
end

--加载场景
function M:loadScene()
    M.super.loadScene(self)
end

--点击到3D物体
function M:clickObject( obj, data, id )
    -- GameUtil:playBtnSound("Main/Outskirts/" .. obj.name)
    -- local pos = Vector3.New(3.5,5.15,-8)
    local pos = UIUtil.UITo3D(self.treasure.transform.position);
    local shutiao = obj.transform:Find("LOD0 _Boss_BaoXiang_07").transform:Find("Fx_Boss_BaoXiang_04")
    shutiao.gameObject:SetActive(false)
    
    local scale = obj.transform.localScale
    scale.x = 0.5
    scale.y = 0.5
    scale.z = 0.5
    obj.transform.localScale = scale
    self:MoveToPath(obj,obj.transform.position,pos,0,0.4, false,function( ... )
         ResourceUtil:ReturnItem(obj)
         if self.dataList ~= nil then
            self.dataList:remove(obj)
         end
         self:sendEvent("addCount",{count = 1 , list_data = self.dataList},"GamePanel")    
        if self.treasure ~= nil  then
            local slot_anim = ResourceUtil:GetUIEffectItem("WorldBossPop/UI_WorldBossPop_BaoDian", self.treasure)
            --slot_anim.transform:SetParent(self.treasure.transform, false)
        end 
    end)
end


function M:DoPath(obj,dataList,treasure,callBack)
    local enemys = SceneManager:getCurSceneView().plyMgr:getPlayers(-1);
    local ply = enemys:get(0)
    if ply ~= nil then
        obj.transform.position = ply.spine.transform.position
        local BaoDian_obj = ResourceUtil:LoadCommonEffect("Fx_Boss_BaoXiang_BaoDian",nil)
        local x = math.random(-5,0) 
        local z = math.random(-3,-1) 
        local dir = Vector3.New(x,0,z)
        --dir = Vector3.Normalize(dir)
        local target = (dir +ply.tran.position) --
        local startPos = obj.transform.position
        local targetPos = target --*
        obj.transform:SetParent(self.sceneObj.transform);
        BaoDian_obj.transform.position = ply.spine.transform.position
         --pos.y = 0 
        self.dataList = dataList
        self.treasure = treasure
        local speed = 0.7
       self:MoveToPath(obj,startPos,targetPos,2.5,speed,true,function( ... )
        end)
       --ResourceUtil:ReturnItem(BaoDian_obj)
        CS.GameObjectClickMgr.Inst:GetListeners()
    end
end

function M:MoveToPath( obj,startPos, targetPos, dir,speed,ismove,callBack )
    local pos = startPos + ((targetPos - startPos)/2 + CS.UnityEngine.Vector3.up * dir)
    -- local pos = startPos - targetPos
    -- pos = pos +  CS.UnityEngine.Vector3.up * dir
    local path = {startPos,pos, targetPos}

    -- local tween = obj.transform:DOPath(path, speed, Tweening.PathType.CatmullRom, Tweening.PathMode.Ignore)
    local tween = obj.transform:DOPath(path, speed, Tweening.PathType.CatmullRom, Tweening.PathMode.Ignore)
    if ismove == true then
        local baoxiang_move  = obj:GetComponent("baoxiang_move")
        baoxiang_move:Play()
    end
    tween:OnComplete(callBack)
end


function M:resetCamera(isDie)
    SceneManager:getCurSceneView():setBGMusic()
    SceneManager:getCurSceneView():setCameraInfo(false)
    --销毁场景
    -- self:destroy(nil);
    SceneManager.curScene.plyMgr:clearHideList()
    local heros = SceneManager.curScene.plyMgr:getPlayers(1);
    for i=1,heros.Count do
        local ply = heros:get(i-1);
        if ply then
            ply:destroy();
        end
    end
    if SceneManager.curScene.plyMgr.attacker_petMgr and SceneManager.curScene.plyMgr.attacker_petMgr.curPet then
        local curPet = SceneManager.curScene.plyMgr.attacker_petMgr.curPet;
        curPet:destroy();
    end
    self:setBossState(1)
    self:refreshState();
    local status = "idle"
    if isDie then
        status = "die"
    end
    local enemys = SceneManager.curScene.plyMgr:getPlayers(-1);
    for i=1,enemys.Count do
        local ply = enemys:get(i-1);
        if ply then
            if status == "die" then
                ply:spawn()
            end
            --ply.aiEngine:changeState(status)
            local ply_view = SceneManager:getCurSceneView().plyMgr:GetPlayerViewByModel(ply)
            if ply_view ~= nil and ply_view.luaViewHelper ~= nil then
                ply_view.luaViewHelper:ShaderChange(LODUtil.lodLevel)
            end
            ply.animator:changeState(status)
        end
    end
    SceneManager:getCurSceneView():deleteStandEffect();
end



function M:battleConfigCall()
    M.super.battleConfigCall(self)
    self:dataAddition()
end

function M:battleOnce()
    M.super.battleOnce(self)
    SelectTargetTool:resetFixPoint()
    for i = 1, self.plyMgr.enemy_list.Count do
        local ply = self.plyMgr.enemy_list:get(i-1)
        if ply:get_master() == nil then
            ply:setBoss(true)
            if ply.tranformHelper ~= nil then
                local ply_showEffect = ply.tranformHelper:FindObj(ply.tran, "show_effect")
                if ply_showEffect ~= nil then
                    ply_showEffect:SetActive(false)
                end
            end
        end
    end
    self:dataAddition()
    --self.positionShow.gameObject:SetActive(false);
end


function M:setCameraPos( vec_pos )
    local vec = self.cameraController.Camera_3D.transform.position
    vec.x = vec_pos.x;
    vec.y = vec_pos.y;
    vec.z = vec_pos.z;
    self.cameraController.Camera_3D.transform.position = vec
end


--加载场景Item
function M:loadSceneItem()
    self.guide = nil
end

--设定位置
function M:setPosition()
    M.super.setPosition(self)
end

--属性加成
--战斗开始创建玩家后调用
function M:dataAddition()
    local data = self.world_cfg;
    for i = 1, self.plyMgr.hero_list.Count do
        local ply = self.plyMgr.hero_list:get(i - 1)
        local key = table.keyof(data.goodness_race or {}, ply.plyData.race)
        if key ~= nil then
            ply.data.atk:addToMulList(data.goodness_atkparam[key])  
        end
    end
end

return M