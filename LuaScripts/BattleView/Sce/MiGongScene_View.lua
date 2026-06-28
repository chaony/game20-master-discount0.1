
--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:48:33
]]

--异界迷宫
---@class MiGongScene_View : Scene_View @
---@field super Scene_View @Scene_View
local M = class("MiGongScene_View",Battle.Scene_View)

function M:init(model)
    M.super.init(self,model)
end

function M:getCurSceneObjName()
    return "migongscene_data"
end

--进入场景
function M:enter( data )
    M.super.enter(self, data)
end


function M:sceneLoadFinish()
    
end

--迷宫场景
function M:getCurSceneName()
    self:createSceneConfig(103)
    return self.scene_info.resource;
end


return M