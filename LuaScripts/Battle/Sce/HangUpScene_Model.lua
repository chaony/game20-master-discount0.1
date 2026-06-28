--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:27:50
]]

---@class HangUpScene_Model : Scene_Model 挂机场景
local M = class("HangUpScene_Model",Battle.Scene_Model)

--初始化场景
function M:init()
    M.super.init(self)
end

--子类重写
function M:getCurSceneName()
    local level = UserDataManager:getBattleStage();
    self.chapter = ConfigManager:getCfgByName("stage")[level];
    self:createSceneConfig(tonumber(self.chapter.battle_scene))
    return self.scene_info.resource;
end

--子类重写
function M:getCurSceneObjName()
    return "hangUpscene_data_w";
end

function M:loadFinish()
    if self.isDestoryMe then
        return;
    end

    --初始化一次种子,使用真随机
    WRandom:setSeed(0,-1, false);

    --场景AStar数据
    self.aStar = require("Battle.Data.AStarSix").new();
    self.aStar:init();
    --挂机玩家人物
    local hangUpNum = 3
    --挂机阵容
    local hangUpDataFromView = UserDataManager.hero_data:getTeamByKey("view", "best") or {}
    local hangUpData = UserDataManager.hero_data:getStagePassTeam()
    self.hang_plys = Battle.List.new()
    --近战
    self.jinzhan_pls = Battle.List.new()
    --远程
    self.yuancheng_pls = Battle.List.new()
    --要创建的玩家
    self.create_pls = Battle.List.new()

    if hangUpDataFromView and next(hangUpDataFromView) then
        for k,v in pairs(hangUpDataFromView) do
            if v ~= "" and hangUpNum >= 0 then
                local data,_ = UserDataManager.hero_data:getHeroDataById(v)
                if data then
                    local hero_table_data = ConfigManager:getCfgByName("hero_detail")[data.id];
                    if hero_table_data ~= nil then
                        self.create_pls:add(data)
                    end
                    hangUpNum = hangUpNum - 1 --只取前三个位置上的，有空缺就空着
                    if hangUpNum == 0 then
                        break;
                    end
                end
            end
        end
        if hangUpNum < 3 then --至少得取到一个侠客
            hangUpNum = 0 --若view队伍有侠客，只取view队伍的侠客，即使只有一个侠客
        end
    end

    if hangUpNum > 0 then
        for k,v in pairs(hangUpData) do
            if v ~= "" then
                local data,_ = UserDataManager.hero_data:getHeroDataById(v)
                if data then
                    local hero_table_data = ConfigManager:getCfgByName("hero_detail")[data.id];
                    if hero_table_data ~= nil then
                        if hero_table_data.fight_type == 1 then
                            self.jinzhan_pls:add(data)
                        else
                            self.yuancheng_pls:add(data)
                        end
                    end
                end
            end
        end
        
        --先检测远程
        for i = 1, self.yuancheng_pls.Count, 1 do
            local data = self.yuancheng_pls:get(i-1)
            self.create_pls:add(data)
            hangUpNum = hangUpNum - 1;
            if hangUpNum == 1 then
                break;
            end
        end
        
        --再检测近战
        for i = 1, self.jinzhan_pls.Count, 1 do
            local data = self.jinzhan_pls:get(i-1)
            self.create_pls:add(data)
            hangUpNum = hangUpNum - 1;
            if hangUpNum == 0 then
                break;
            end
        end

        --全部检测完成了还是没有把挂机人数消耗完
        if hangUpNum > 0 then
            if self.create_pls.Count < self.yuancheng_pls.Count then
                local player = self.yuancheng_pls:get(self.create_pls.Count)
                self.create_pls:add(player)
                hangUpNum = hangUpNum - 1
            end
        end
        self.yuancheng_pls:clear();
        self.jinzhan_pls:clear();
    end
    
    local index = self.create_pls.Count;
    for i = 1,self.create_pls.Count, 1 do
        local data = self.create_pls:get(i-1)
        index = index - 1;
        local player = self.plyMgr:createPlayer(data,1,index)
        player:set_playerInstanceId(data.oid)
        if player.data ~= nil then
            player.data.radius = GlobalTools.base0_2;
            local attrs = GlobalTools:FloatToFixTable(data.attrs);
            self:setPlayerAttrubute(player, attrs)
        end
        self.hang_plys:add(player)
    end
    
    if IsNull(self.hangUpSceneConfig) then
        --加载挂机场景配置
        ResourceUtil:LoadConfigObject("HangUpSceneConfig", function(sceneConfig)
            self.hangUpSceneConfig = sceneConfig;
            self:playerCreateFinish();
        end)
    else
        self:playerCreateFinish();
    end
end

--获取挂机场景配置
function M:getHangUpConfig()
    if self.hangUpSceneConfig == nil then
        return nil
    else
        for i, v in pairs(self.hangUpSceneConfig.configs) do
            if v.sceneName == self.scene_name then
                return v;
            end
        end
        return self.hangUpSceneConfig.mDefaultConfig;
    end
end


function M:getHandUpSceneConfig()
    return self.hangUpSceneConfig;
end


--人物加载完成
function M:playerCreateFinish()
    if self.isDestoryMe then
        return;
    end
    --找到战力最高的 近战英雄
    if self.mainPlayer == nil and self.hang_plys.Count > 0 then
        self.mainPlayer = self.hang_plys:get(self.hang_plys.Count - 1)
    end
    --别的英雄重新排位
    for i = 1, self.hang_plys.Count do
        local player = self.hang_plys:get(i-1)
        player.data:set_moveSpeed( GlobalTools.base4 );
    end
    self.hang_plys:clear();
    
    --挂机直接进入运行阶段
    self:set_sceneState(3)
    self.gameover = false
    self.curTalkDelayTime = 3
    self.curTalkTime = math.random(8,12);
    
    self.plyMgr:playerSpawn()
    --初始化向导
    self:initGuide();
    --初始化完成
    self:initFinish();
end

--设定主要玩家 
function M:get_mainPlayer()
    return self.mainPlayer;
end

--初始化场景向导
function M:initGuide()
    self.guide = Battle.SceneGuide_Model.new()
    local idle_type = self.scene_info.idle_type or 1
    if LODUtil:getSceneLod() <= 1 then
        idle_type = 2;
    end
    self.guide:init( self, idle_type )
    self.guide:play()
end

--进入场景
function M:enter( data )
    M.super.enter(self, data)
    TimeManager:set_baseUpdateDelaTime(TimeManager.hangUpUpdateDelteTime)
    UserDataManager:setTempData("worldScene_stage", nil)
    LODUtil:recordLodLevel();
    CS.wt.framework.AssetLoaderHelper.Inst:SetEffectLOD(0);
    LODUtil:setShaderLOD(0)
end


function M:destroy( nextScene )
    M.super.destroy( self, nextScene )
    self.mainPlayer = nil;
    if self.hang_plys ~= nil then
        self.hang_plys:clear();
    end
    LODUtil:resetLodLevel()
end

--受到时间 TimeScale 影响的 更新函数
function M:update_dt(dt)
    M.super.update_dt(self,dt)
end


return M