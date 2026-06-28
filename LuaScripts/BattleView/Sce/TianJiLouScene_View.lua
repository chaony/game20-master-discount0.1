--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:33:07
]]

--挂机场景
--直接在天机楼场景进行战斗
---@class TianJiLouScene_View : Scene_View @
---@field super Scene_View @Scene_View
local M = class("TianJiLouScene_View",Battle.Scene_View)

M.plyMoveSpeed = 0;
--初始化场景
function M:init(model)
    M.super.init(self,model)
    self.plyMoveSpeed = 6;
end

function M:enter( data )
    M.super.enter(self,data)
    self.linkSceneId = 7;
end


function M:getCurSceneName()
    return "tianjilou";
end

function M:getCurSceneObjName()
    return "tianjilou_data";
end

--加载场景
function M:loadScene()
    M.super.loadScene(self)
    
    self.heroStartPoslist = Battle.List.new()
    --获取玩家根节点
    self.heroStartRoot = self.obj.transform:Find("HeroPosStart")
    for i=1,self.heroStartRoot.childCount,1 do
        self.heroStartPoslist:add(self.heroStartRoot:GetChild(i-1).position)
    end
    self:loadSceneItem()
end


function M:loadFinish( data )
    self.m_data = data;
    -- local data = 
    -- {
    --     atk_team = tower_team,
    --     atk_heros = {},
    --     def_taam = {},
    --     def_heros = {},
    --     mode = 1,
    --     move_type = 1,
    --     race = 0,
    -- }
    --第一次进入
    if self.isUseConfig then
        --英雄
        local heros = self.battleConfig["heros"]
        for k,v in pairs(heros) do
            local p_id = tonumber( v["Id"] )
            local PosIndex = tonumber( v["PosIndex"] )
            local playerData = { id = p_id, evo = 1 }
            local player = self.plyMgr:createPlayer(playerData,1,PosIndex)
            player.data:set_moveSpeed(self.plyMoveSpeed);
        end
        --敌人
        local enemys = self.battleConfig["enemys"]
        for k,v in pairs(enemys) do
            local p_id = tonumber( v["Id"] )
            local PosIndex = tonumber( v["PosIndex"] )
            local playerData = { id = p_id, evo = 1 }
            local player = self.plyMgr:createPlayer(playerData,-1,PosIndex)
        end
        
    else
        local race = self.m_data.race or 0
        local atk_team = UserDataManager.hero_data:getTeamByKey("tower", "stage")
        if race > 0 then
            atk_team = UserDataManager.hero_data:getTeamByKey("race_tower_" .. race)
        end
        --创建玩家队伍
        self:createPlayerTeam(atk_team, false);
        
        local battle_id = -1
        local tower_floor = UserDataManager:getRaceFloorByRace(race)
        local tower_stage_item, is_max = ConfigManager:getTowerStageCfgByRaceAndId(race, tower_floor)
        if is_max then
            self.m_data.move_type = 1
        end
        battle_id = tower_stage_item.battle_id or -1
        --创建敌人队伍
        self:createEnemyTeam(battle_id)
    end
end

function M:createPlayerAndEnemyFinish()
    if self.isUseConfig == false then
        local players = self.plyMgr:getPlayers(1);
        for i=1,players.Count do
            local player = players:get(i-1)
            player.data:set_moveSpeed(self.plyMoveSpeed);
            player.data:set_hp(100);
            if self.m_data.move_type == 1 then
                local pos = self.heroStartPoslist:get(player.index)
                player:setPos( GlobalTools:ToFixVector3(pos) )
            end
        end
    
        local enemys = self.plyMgr:getPlayers(-1);
        for i=1,enemys.Count do
            local enemy = enemys:get(i-1)
            enemy.data:set_hp( 100 );
            local pos = self:findSpawnPosition(-1,i-1)
            enemy:setPos( pos );
        end
    end
    
    self.gameover = false
    self:set_sceneState(3)
    if self.m_data ~= nil then
        if self.m_data.move_type == 1 then
            self.guide.position = FixVector3(-3.81, 0, 0.36)
            self.guide.sceneGuideTran.rotation = Quaternion.Euler(0,0,0)
            self.cameraController.camera_move = false;
            local pos = self.cameraController.points[self.cameraController.points.Count-1];
            self.cameraController.transform.position = pos.pos.position;
            self.cameraController.transform.forward = pos.pos.forward;
        else
            self.cameraController:ResetStart();
            self:resetPlayerMovePath();
            self.plyMgr:playerSpawnCamp(1)
            self.guide.sceneGuideScript:Init();
            self.guide.position = FixVector3(-22.07, -5.8, 1.16)
            self.guide.sceneGuideTran.rotation = Quaternion.Euler(0,124,0)
            self.guide:play()
        end
    end
end



function M:resetPlayerMovePath()
    local list = self.plyMgr:getPlayers(1)
    for i=1,list.Count do
        local ply = list:get(i-1);
        ply.tianjilou_move_index = 0;
    end
end


--加载场景Item
function M:loadSceneItem()
    if self.obj ~= nil then
        --获取导航
        local guideObj = self.obj.transform:Find("Guide")

        self.heroPathlist = Battle.List.new()
        local heroPath = self.obj.transform:Find("HeroPath");
        if heroPath ~= nil then
            for i=1,heroPath.childCount,1 do
                local list = Battle.List.new();
                local pos = heroPath:GetChild(i-1)
                for j=1,pos.childCount,1 do
                    list:add( FixVector3.New(pos:GetChild(j-1).position.x,pos:GetChild(j-1).position.y,pos:GetChild(j-1).position.z) );
                end
                self.heroPathlist:add(list)
            end
        end

        if guideObj ~= nil then
            local guideCls = require("Battle.Sce.Guide.TianJiLouSceneGuide")
            self.guide = guideCls.new()
            self.guide:init(guideObj, self)
        end
    end
end


function M:getPathPosition(index, path_index)
    local list = self.heroPathlist:get(index);
    if list.Count > path_index then
        return list:get(path_index)
    end
end


--切换到战斗
function M:changeToBattle()

end


--进入场景
function M:enter(data)
    M.super.enter(self, data)
    
end

--更新场景
function M:updateUnScaleDelay(unsdt)
    M.super.updateUnScaleDelay(self,unsdt)
end

--受到时间 TimeScale 影响的 更新函数
function M:updateDelay(dt)
    M.super.updateDelay(self,dt)
end

--设定位置
function M:setPosition(dt,unsdt)
    M.super.setPosition(self,dt,unsdt)
end

return M