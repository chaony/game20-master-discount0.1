--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:27:50
]]

--盗帅迷踪场景
---@class VoyageScene_Model : Scene_Model @
---@field super Scene_Model @Scene_Model
local M = class("VoyageScene_Model",Battle.Scene_Model)

--初始化场景
function M:init()
    M.super.init(self)
end

--子类重写
function M:getCurSceneName()
    self:createSceneConfig(999)
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
    --场景AStar数据
    --self.aStar = require("Battle.Data.AStarSix").new();
    --self.aStar:init();
    
    self.hang_plys = Battle.List.new()
    --近战
    self.jinzhan_pls = Battle.List.new()
    --远程
    self.yuancheng_pls = Battle.List.new()
    --要创建的玩家
    self.create_pls = Battle.List.new()
    
    --制作人说这个活动只用锦衣
    local player = self.plyMgr:createPlayer({id = 104},1,0)
    if player.data ~= nil then
        player.data.radius = GlobalTools.base0_2;
    end
    self.hang_plys:add(player)
    --视图加载完成
    player.loadPlayerViewFinish = function( player_view )
        player.moveEffect = ResourceUtil:LoadCommonEffect("Skill_DaoShuaiMiGong_01",player_view.obj)
        player.moveEffect.transform.localPosition = Vector3(0,0,0)
        player.moveEffect:SetActive(false);
        if not IsNull(player_view.obj) then -- GPM issue_id: ff909d45d4699196c562c5bb4b4855e8
            player_view.obj:SetActive(false);
        end
        self:playerCreateFinish();
    end
    
end

--人物加载完成
function M:playerCreateFinish()
    if self.isDestoryMe then
        return;
    end
    --找到战力最高的 近战英雄
    self.mainPlayer = self.hang_plys:get(self.hang_plys.Count - 1)
    
    --别的英雄重新排位
    for i = 1, self.hang_plys.Count do
        local player = self.hang_plys:get(i-1)
        player.data:set_moveSpeed( GlobalTools.base4 );
    end
    self.hang_plys:clear();

    self.talkList = Battle.List.new();
    local talk = ConfigManager:getCfgByName("random_lines")
    for k,v in pairs(talk) do
        local type = v["type"]
        if type == 1 then
            self.talkList:add(v)
        else
            local hero_id = v["hero_detail_id"];
            local player = self.plyMgr:getPlayerByPlayerID(hero_id, 1)
            if player ~= nil then
                self.talkList:add(v)
            end
        end
    end
    
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
    local idle_type = 3
    self.guide:init( self, idle_type )
    self.guide:play()
end

--进入场景
function M:enter( data )
    M.super.enter(self, data)
    TimeManager:set_baseUpdateDelaTime(TimeManager.hangUpUpdateDelteTime)
end


function M:destroy( nextScene )
    if not IsNull(self.mainPlayer) and self.mainPlayer.moveEffect ~= nil then
        U3DUtil:GameObjectDestroy(self.mainPlayer.moveEffect)
        self.mainPlayer.moveEffect = nil;
    end
    M.super.destroy( self, nextScene )
    self.mainPlayer = nil;
    if self.hang_plys ~= nil then
        self.hang_plys:clear();
    end
end

--受到时间 TimeScale 影响的 更新函数
function M:update_dt(dt)
    M.super.update_dt(self,dt)
end


return M