--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:32:47
]]

--郊外场景
---@class JiaoWaiScene_View : Scene_View @
---@field super Scene_View @Scene_View
local M = class("JiaoWaiScene_View",Battle.Scene_View)

function M:getCurSceneName()
    self:createSceneConfig(102)
    return self.scene_info.resource;
end

function M:getCurSceneObjName()
    return "";
end

--初始化场景
function M:init(model)
    M.super.init(self,model)
    self.isNeedResetCamera = false;
end

function M:initScene()
    CS.GameObjectClickMgr.Inst:Register("ClickObj",handler(self,self.clickObject))
    static_rootControl:updateMsg("guide_check",nil ,"Main.Outskirts");
    self:loadFinish();
    SceneManager:setData("show_loading_black", false)
    static_rootControl:updateMsg("close_battle_loading")
end

function M:clickObject( obj, data, id )
    Logger.log(" 点击某个物体 ~~~~~~~~~~~~~~~~~~ ".. tostring(obj.name) )
    static_rootControl:updateMsg(obj.name,nil,"Main.Outskirts");
    GameUtil:playBtnSound("Main/Outskirts/" .. obj.name)
end

--进入场景
function M:enter( data )
    M.super.enter(self, data )
end

--更新场景
function M:update(dt,unsdt)
    M.super.update(self)
end


function M:updateAlways(dt)
    M.super.updateAlways(self,dt)
end


function M:createPlayerAndEnemyFinish()
    M.super.createPlayerAndEnemyFinish(self)
end

function M:loadFinish( data )
    M.super.loadFinish(self,data);
end

function M:resetCamera()
    
end

--加载场景
function M:loadScene()
    M.super.loadScene(self)
end

function M:battleConfigCall()
    
end

function M:battleOnce()
   
end

function M:setCameraPos( vec_pos )
    
end


function M:setCameraPosition(isZhanDou)
    
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
   
end

function M:registerHeroAndEnemyPos()
    
end


return M;