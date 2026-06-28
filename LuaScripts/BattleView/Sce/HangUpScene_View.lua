--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:27:50
]]

--挂机场景视图
---@class HangUpScene_View : Scene_View @
---@field super Scene_View @Scene_View
local M = class("HangUpScene_View",Battle.Scene_View)

--初始化场景
function M:init(model)
    M.super.init(self, model)
    self.use_hov = U3DUtil:IsHov();
    self.use_foot_effect = false;
    self.curTalkDelayTime = 3;
    self.curTalkTime = math.random( 8,12 )
    self:addEventListener_Local(Battle.EventType.MV_SceneGuideModelCreateFinish,{self,self.SceneGuideModelCreateFinish})
end

--场景向导 创建完成
function M:SceneGuideModelCreateFinish(eventName, data) 
    local sceneGuideMode = data;
    self:initGuide( sceneGuideMode );
end

--初始化场景向导
function M:initGuide( model )
    self.guide = Battle.SceneGuide_View.new()
    self.guide:init( self.guideObj, self, model)
end

--加载场景
function M:initSceneObjectsFinish( data )
    M.super.initSceneObjectsFinish(self)
    if self.obj ~= nil then
        self.gridRoot = self.obj.transform:Find("gridRoot");
        self.guideObj = self.obj.transform:Find("Guide")
        self.heroPosObj = self.obj.transform:Find("HeroPos")
    end
end

--视图更新
function M:view_update(dt, unsdt)
    M.super.view_update(self, dt, unsdt);
    if dt > 0.3 then
        dt = 0.3;
    end
    if SceneManager.scene_pause == false then
        if self.cameraControllerHasTarget ~= nil and self.cameraControllerHasTarget == false then
            local mode = self.model.guide:get_mode()
            if mode == 1 then
                local mainPlayer = self.model:get_mainPlayer();
                if mainPlayer ~= nil then
                    local player_view = self.plyMgr:GetPlayerViewByModel( mainPlayer );
                    if player_view ~= nil and player_view.tran ~= nil then
                        self.cameraController.Target = player_view.tran;
                        self.cameraControllerHasTarget = true;
                    end
                end
            elseif mode == 2 then
                if not IsNull(self.heroPosObj) then
                    self.cameraController.Target = self.heroPosObj.transform;
                    self.cameraControllerHasTarget = true;
                end
            end
        end
        self:check_talk(dt);
        --Logger.logError(" view_update "..dt.." self.curTalkTime "..self.curTalkTime )
    end
end


--检测聊天
function M:check_talk( dt )
    if self.curTalkDelayTime > 0 then
        self.curTalkDelayTime = self.curTalkDelayTime - dt;
        if self.curTalkDelayTime <= 0 then
            self:talk();
        end
    else
        if self.curTalkTime > 0 then
            self.curTalkTime = self.curTalkTime - dt
            if self.curTalkTime <= 0 then
                self:talk();
                self.curTalkTime = math.random( 8,12 )
            end
        end
    end
end


--弹出聊天框
function M:talk()
    if self.talkList ~= nil and self.talkList.Count > 0 then
        local index = 0
        if self.talkList.Count >= 2 then
            index = math.random(0,self.talkList.Count-1);
        end
        local talk_content = self.talkList:get(index);
        if talk_content["type"] == 1 then
            local ply_index = 0
            if self.plyMgr.hero_list.Count >= 2 then
                ply_index = math.random(0,self.plyMgr.hero_list.Count-1);
            end
            local player = self.plyMgr.hero_list:get(ply_index);
            if player ~= nil then
                player:talk( Language:getTextByKey(talk_content["lines"]),talk_content.show_time)
            end
        else
            if talk_content["type"] == 2 then
                local player = self.plyMgr:getPlayerByPlayerID(talk_content["hero_detail_id"],1)
                if player ~= nil then
                    player:talk( Language:getTextByKey(talk_content["lines"]), talk_content.show_time )
                end
            end
        end
    end
end


--进入场景
function M:enter( data )
    M.super.enter(self, data )
end


-- 初始化完成
function M:initFinish()
    self.cameraControllerHasTarget = false
    self.talkList = Battle.List.new();
    local talk = ConfigManager:getCfgByName("random_lines")
    for k,v in pairs(talk) do
        local type = v["type"]
        if type == 1 then
            self.talkList:add(v)
        else
            if type == 2 then
                local hero_id = v["hero_detail_id"];
                --羁绊
                local team = v["team"];
                if team ~= 0 then
                    local player = self.plyMgr:getPlayerByPlayerID(hero_id, 1)
                    local teamPly = self.plyMgr:getPlayerByPlayerID(team, 1)
                    if player ~= nil and teamPly ~= nil then
                        self.talkList:add(v)
                    end
                else
                    local player = self.plyMgr:getPlayerByPlayerID(hero_id, 1)
                    if player ~= nil then
                        self.talkList:add(v)
                    end
                end
            end
        end
    end
    --Logger.logError( " self.talkList.Count  数据 "..self.talkList.Count )
end


return M