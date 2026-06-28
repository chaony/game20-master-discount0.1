
--聚宝山场景
---@class JuBaoShanScene_View : Scene_View @
---@field super Scene_View @Scene_View
local M = class("JuBaoShanScene_View",Battle.Scene_View)

--初始化场景
function M:init(model)
    M.super.init(self,model)
end

--进入场景
function M:enter( data )
    M.super.enter(self, data )
    Logger.log(data, " JuBaoShanScene_View 服务器数据 ")
end

function M:getCurSceneName()
    --self:createSceneConfig(107)
    --return self.scene_info.resource;
    return "jubaoshan"
end

function M:getCurSceneObjName()
    return "jubaoshan_data";
end

function M:sceneLoadFinish()
    
end

function M:updateAlways(dt)
    M.super.updateAlways(self,dt)
end

return M;