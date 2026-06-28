--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:32:47
]]

--工會boss场景
---@class UnionBossScene_View : SceneArrayBase_View @
---@field super SceneArrayBase_View @SceneArrayBase_View
local M = class("UnionBossScene_View",Battle.SceneArrayBase_View)

--初始化场景
function M:init(model)
    M.super.init(self,model)
end

--进入场景
function M:enter( data )
    M.super.enter(self, data ) 
end

--更新场景
function M:update(dt,unsdt)
    M.super.update(self) 
end

function M:getCurSceneName()
    self:createSceneConfig(106)
    return self.scene_info.resource;
end

function M:getCurSceneObjName()
    -- return "unionbossscene_data";
    return "bossscene_data";
end

function M:updateAlways(dt)
	M.super.updateAlways(self,dt)
end

function M:createPlayerAndEnemyFinish()
    M.super.createPlayerAndEnemyFinish(self)
   --local ply = self.plyMgr.enemy_list:get(0);
   --if ply ~= nil then
   --   ply:SetAnimator(true);
   --end
end

function M:arraying_players_set()
    M.super.arraying_players_set(self)
    self.positionShow.gameObject:SetActive(true);
    local list = self.plyMgr:getPlayers(1)
    local enemy = SceneManager.curScene.plyMgr:getEnemyByIndex(0);
    if enemy then
        for i=1,list.Count do
            local ply = list:get(i-1);
            local dir = GlobalTools:Dir(enemy.position,ply.position);
            ply:setForward(dir);
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

    self:setCameraPos(self.cameraShowBoss);
    self.cameraController.Camera_3D.transform.rotation = Quaternion.Euler(self.cameraShowBossRot.x, self.cameraShowBossRot.y, self.cameraShowBossRot.z);

    self.union_boss_model = data;
    self.union_boss_cfg = ConfigManager:getCfgByName("guild_boss")[self.union_boss_model.guild_boss_id]
    local battle_id = self.union_boss_cfg.battle_id
    local arrays =  {}
    if next(UserDataManager.hero_data:getTeamByKey("guild_boss")) == nil then
        arrays = table.copy(UserDataManager.hero_data:getTeamByKey("stage"))
    else
        arrays = table.copy(UserDataManager.hero_data:getTeamByKey("guild_boss"))	
    end	
    -- self:createPlayerTeam(arrays, true);
    self.gameover = false;
    self:createEnemyTeam(battle_id);
    if self.union_boss_model.m_init_function then
        self.union_boss_model.m_init_function()
    end
end

function M:resetCamera()
    --销毁场景
    -- self:destroy(nil);
    local heros = SceneManager.curScene.plyMgr:getPlayers(1);
    for i=1,heros.Count do
        local ply = heros:get(i-1);
        ply:destroy();
    end
    --if self.world_boss_cycle ~= nil then
        --local battle_id = self.world_boss_cycle.battle_id;
        -- self:createEnemyTeam(battle_id);
    --end
    
    self:setCameraPos(self.cameraShowBoss);
    self.cameraController.Camera_3D.transform.rotation = Quaternion.Euler(self.cameraShowBossRot.x, self.cameraShowBossRot.y, self.cameraShowBossRot.z);
end

--加载场景
function M:loadScene()
    M.super.loadScene(self)
    self.positionShow = self.obj.transform:Find("PositionShow")
    self.positionShow.gameObject:SetActive(true);
end

function M:battleConfigCall()
    M.super.battleConfigCall(self)
    self:dataAddition()
end

function M:battleOnce()
    M.super.battleOnce(self)
    
    for i = 1, self.plyMgr.enemy_list.Count do
        local ply = self.plyMgr.enemy_list:get(i-1)
        if ply:get_master() == nil then
            ply:setBoss(true)
        end
    end
    
    self:dataAddition()
    self.positionShow.gameObject:SetActive(false);
end

function M:setCameraPos( vec_pos )
    local vec = self.cameraController.Camera_3D.transform.position
    vec.x = vec_pos.x;
    vec.y = vec_pos.y;
    vec.z = vec_pos.z;
    self.cameraController.Camera_3D.transform.position = vec
end

function M:setCameraPosition(isZhanDou)
    if isZhanDou then
        self:setCameraPos(self.camera_zd_pos);
        self.cameraController.Camera_3D.transform.rotation = Quaternion.Euler(self.camera_zd_rot.x, self.camera_zd_rot.y, self.camera_zd_rot.z);
	else
        self:setCameraPos(self.camera_bz_pos);
        self.cameraController.Camera_3D.transform.rotation = Quaternion.Euler(self.camera_bz_rot.x, self.camera_bz_rot.y, self.camera_bz_rot.z);
    end
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
    --[[local data = self.world_cfg
    for i = 1, self.plyMgr.hero_list.Count do
        local ply = self.plyMgr.hero_list:get(i - 1)
        local key = table.keyof(data.goodness_race, ply.plyData.race)
        if key ~= nil then
            ply.data.battleAtkAddPercent = ply.data.battleAtkAddPercent + data.goodness_atkparam[key]
        end
    end]]
end

return M