--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-05-15 11:26:21
]]

--时光之巅场景
---@class ShiGuangScene_Model : Scene_Model @
---@field super Scene_Model @Scene_Model
local M = class("ShiGuangScene_Model",Battle.Scene_Model)

M.currentScale = nil
M.camera = nil
--初始化场景
function M:init()
    M.super.init(self)
end

--时光之巅场景
function M:getCurSceneName()
    return "shiguangzhidian";
end

function M:getCurSceneObjName()
    return "shiguangzhidianscene_data";
end

--进入场景
function M:enter( data )
    M.super.enter(self, data)
end

--设定服务器数据
function M:setServerData( map_id, net_data )
    --服务器，开始的时候传来的数据
    --Logger.log(net_data," 时光之巅服务器来的数据 ")
    self.net_data = net_data;
    self.map_id = map_id;
    self.chapterData = ConfigManager:getCfgByName("roleplaying_chapter")[self.map_id];
    local block_net_data = SceneManager:getData("shiguang_block_net_data")
    if block_net_data == nil then
        block_net_data = self.net_data;
        block_net_data.chapter_id = map_id;
        SceneManager:setData("shiguang_block_net_data",block_net_data)
    end
end


function M:getBlockDataByID( block_id )
    if self.shiguangmap ~= nil then
        return self.shiguangmap:getBlockDataByID(block_id)
    end
end


function M:rpgChioceOption( net_data )
    if self.shiguangmap ~= nil then
        self.shiguangmap:rpgChioceOption(net_data)
    end
end

function M:rpgClickObj( net_data )
    if self.shiguangmap ~= nil then
        self.shiguangmap:rpgClickObj(net_data)
    end
end

--前往地图
function M:rpgGoto( net_data )
    if self.shiguangmap ~= nil then
        self.shiguangmap:rpgGoto(net_data)
    end
end

--地图-重置
function M:rpgMapReset( net_data )
    if self.shiguangmap ~= nil then
        self.shiguangmap:rpgMapReset(net_data)
    end
end

--地图-战斗开始
function M:rpgBattleStart( net_data )
    if self.shiguangmap ~= nil then
        self.shiguangmap:rpgBattleStart(net_data)
    end
end

--地图-战斗结束
function M:rpgBattleEnd( net_data )
    self.battle_end_net_data = net_data
end


--更新场景
--受到时间 TimeScale 影响的 更新函数
function M:update_dt(dt)
    M.super.update_dt(self,dt)
    if self.shiguangmap ~= nil then
        self.shiguangmap:update_dt(dt)
    end
end


function M:battleEnd(data)
    if self.shiguangmap ~= nil then
        self.shiguangmap:battleEnd(data)
    end
end


--加载场景
function M:loadScene()
    M.super.loadScene(self)
    self.gridRoot = self.obj.transform:Find("gridRoot");

    if SceneManager.eventMgr == nil then
        SceneManager.eventMgr = require("Battle.Sce.Tools.SceneEventManager").new()
        SceneManager.eventMgr:init()
    end
    
    --时光之巅地图
    self:loadMap()
    if SceneManager.curScene.cameraController.Camera_3D.orthographic == true then
        self.currentScale = SceneManager.curScene.cameraController.Camera_3D.orthographicSize
    else
        self.currentScale = SceneManager.curScene.cameraController.Camera_3D.fieldOfView
    end
end

function M:loadMap()
    local shiguangmap = require("Battle.Sce.ShiGuangZhiDian.ShiGuangMap")
    self.shiguangmap = shiguangmap.new()
    self.shiguangmap:load(self)
    if self.battle_end_net_data ~= nil then
        self.shiguangmap:rpgBattleEnd(self.battle_end_net_data)
        self.battle_end_net_data = nil;
    end
    GameMain.addUpdate("ShiGuang_MouseEvent",handler(self.shiguangmap,self.shiguangmap.MouseEvent));
end

function M:loadFinish( data )
    M.super.loadFinish(self, data)
end


--销毁
function M:destroy( nextScene )
    M.super.destroy(self,nextScene);
    if self.shiguangmap ~= nil then
        self.shiguangmap:destroy();
        self.shiguangmap = nil;
    end
    GameMain.removeUpdate("ShiGuang_MouseEvent");
end
return M