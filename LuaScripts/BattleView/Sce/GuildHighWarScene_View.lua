--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:32:47
]]

---@class GuildHighWarScene_View : Scene_View @
---@field super Scene_View @Scene_View
local M = class("GuildHighWarScene_View",Battle.Scene_View)

--初始化场景
function M:init(model)
    M.super.init(self,model)
end

function M:getCurSceneName()
    self:createSceneConfig(137)
    return self.scene_info.resource;
end

function M:getCurSceneObjName()
    return "";
end

--进入场景
function M:enter(data)
    M.super.enter(self, data)
end


function M:destroy( nextScene)
end

return M;
